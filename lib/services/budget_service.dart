//IMPORT PAKIETÓW I MODELI

import 'package:hive/hive.dart';
import '../models/transactions.dart';
import '../models/fixed_costs.dart';

class BudgetService {
  static final BudgetService _instance = BudgetService._internal();
  factory BudgetService() => _instance;
  BudgetService._internal();

  late Box<Transaction> _transactionsBox;
  late Box<FixedCost> _fixedCostsBox;

  /// INICJALIZACJA HIVE I POBRANIE BOXÓW
  Future<void> init() async {
    _transactionsBox = await Hive.openBox<Transaction>('transactions');
    _fixedCostsBox = await Hive.openBox<FixedCost>('fixedCosts');
  }

  /// Pobranie wszystkich transakcji i kosztów stałych
  List<Transaction> get transactions => _transactionsBox.values.toList();
  List<FixedCost> get fixedCosts => _fixedCostsBox.values.toList();

  // TRANZAKCJE
  
  Future<void> addTransaction(Transaction t) async {
    await _transactionsBox.put(t.id, t);
  }

  Future<void> editTransaction(String id, Transaction updated) async {
    if (_transactionsBox.containsKey(id)) {
      await _transactionsBox.put(id, updated);
    }
  }

  Future<void> deleteTransaction(String id) async {
    if (_transactionsBox.containsKey(id)) {
      await _transactionsBox.delete(id);
    }
  }

  
  // KOSZTY ZMIENNE
  
  Future<void> addFixedCost(FixedCost fc) async {
    await _fixedCostsBox.put(fc.id, fc);
  }

  Future<void> editFixedCost(String id, FixedCost updated) async {
    if (_fixedCostsBox.containsKey(id)) {
      await _fixedCostsBox.put(id, updated);
    }
  }

  Future<void> deleteFixedCost(String id) async {
    if (_fixedCostsBox.containsKey(id)) {
      await _fixedCostsBox.delete(id);
    }
  }

  
  // OBLICZENIA BUDŻETU

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

  
  // RAPORT KATEGORII
  
  Map<String, double> getTotalsByCategory({
    required DateTime start,
    required DateTime end,
  }) {
    final Map<String, double> totals = {};

    // KOSZTY STAŁE
    for (final fc in fixedCosts) {
      if (!fc.appliesToMonth(start.year, start.month) &&
          !fc.appliesToMonth(end.year, end.month)) {
        continue;
      }
      totals[fc.category] = (totals[fc.category] ?? 0) + fc.monthlyAmount();
    }

    // KOSZTY ZMIENNE
    for (final t in transactions.where((t) => t.type == TransactionType.expense)) {
      if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }

    return totals;
  }
}

/// TRYB WIDOKU BUDŻETU
enum BudgetViewMode { daily, monthly, yearly }



