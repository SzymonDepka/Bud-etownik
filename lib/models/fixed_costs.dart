import 'package:hive/hive.dart';

part 'fixed_costs.g.dart';

@HiveType(typeId: 2)
enum FixedCostPeriod {
  @HiveField(0)
  monthly,
  @HiveField(1)
  yearly,
}

@HiveType(typeId: 3)
class FixedCost extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category; // już dodane

  @HiveField(4)
  FixedCostPeriod period;

  @HiveField(5)
  DateTime startDate;

  FixedCost({
    required this.id,
    required this.name,
    required this.amount,
    required this.category, // wymuszamy podanie kategorii
    required this.period,
    required this.startDate,
  });

  int get startYear => startDate.year;
  int get startMonth => startDate.month;

  bool appliesToYear(int year) => startYear <= year;

  bool appliesToMonth(int year, int month) {
    if (year < startYear) return false;
    if (year == startYear && month < startMonth) return false;
    return true;
  }

  double yearlyAmount() {
    if (period == FixedCostPeriod.yearly) return amount;
    return amount * 12;
  }

  double monthlyAmount() {
    if (period == FixedCostPeriod.monthly) return amount;
    return amount / 12;
  }

  /// Dodany getter do kwoty w zadanym zakresie (opcjonalny)
  double amountForPeriod(FixedCostPeriod targetPeriod) {
    if (targetPeriod == FixedCostPeriod.monthly) {
      return monthlyAmount();
    } else {
      return yearlyAmount();
    }
  }
}