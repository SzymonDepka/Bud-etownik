import 'package:hive/hive.dart';
import '../models/transactions.dart';
import '../models/fixed_costs.dart';

class BudgetService {
  static final BudgetService _instance = BudgetService._internal();
  factory BudgetService() => _instance;
  BudgetService._internal();

  late Box<Transaction> _transactionsBox;
  late Box<FixedCost> _fixedCostsBox;

  Future<void> init() async {
    _transactionsBox = await Hive.openBox<Transaction>('transactions');
    _fixedCostsBox = await Hive.openBox<FixedCost>('fixedCosts');
  }

  List<Transaction> get transactions => _transactionsBox.values.toList();
  List<FixedCost> get fixedCosts => _fixedCostsBox.values.toList();

  void addTransaction(Transaction t) => _transactionsBox.put(t.id, t);
  void updateTransaction(Transaction t) => _transactionsBox.put(t.id, t);
  void removeTransaction(String id) => _transactionsBox.delete(id);

  void addFixedCost(FixedCost fc) => _fixedCostsBox.put(fc.id, fc);
  void updateFixedCost(FixedCost fc) => _fixedCostsBox.put(fc.id, fc);
  void removeFixedCost(String id) => _fixedCostsBox.delete(id);

  double calculateIncome(BudgetViewMode mode) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    return _normalizeValue(income, mode);
  }

  double calculateVariableExpenses(BudgetViewMode mode) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    return _normalizeValue(expenses, mode);
  }

  double calculateFixedCosts(BudgetViewMode mode) {
    double total = 0.0;
    for (final fc in fixedCosts) {
      if (mode == BudgetViewMode.yearly) {
        total += fc.period == FixedCostPeriod.monthly ? fc.amount * 12 : fc.amount;
      } else if (mode == BudgetViewMode.monthly) {
        total += fc.period == FixedCostPeriod.yearly ? fc.amount / 12 : fc.amount;
      } else {
        total += fc.period == FixedCostPeriod.monthly ? fc.amount / 30 : fc.amount / 365;
      }
    }
    return total;
  }

  double calculateBalance(BudgetViewMode mode) {
    return calculateIncome(mode) -
        calculateVariableExpenses(mode) -
        calculateFixedCosts(mode);
  }

  double _normalizeValue(double value, BudgetViewMode mode) {
    if (mode == BudgetViewMode.monthly) return value / 12;
    if (mode == BudgetViewMode.daily) return value / 365;
    return value;
  }

  /// Sumuje koszty według kategorii w zadanym zakresie dat
  /// Zwraca mapę {kategoria: suma kosztów}
  Map<String, double> getTotalsByCategory({
    required DateTime start,
    required DateTime end,
  }) {
    final Map<String, double> totals = {};

    // Koszty stałe
    for (final fc in fixedCosts) {
      if (!fc.appliesToMonth(start.year, start.month) &&
          !fc.appliesToMonth(end.year, end.month)) continue;

      totals[fc.category] = (totals[fc.category] ?? 0) + fc.monthlyAmount();
    }

    // Koszty zmienne (transakcje typu expense)
    for (final t in transactions.where((t) => t.type == TransactionType.expense)) {
      if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }

    return totals;
  }
}

// Enum do trybu budżetu (teraz tylko tutaj, używaj jednej definicji)
enum BudgetViewMode { daily, monthly, yearly }


