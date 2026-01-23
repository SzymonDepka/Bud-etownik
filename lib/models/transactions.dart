import 'package:hive/hive.dart';

part 'transactions.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  TransactionType type;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String category; // już dodane

  @HiveField(5)
  String description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.category, // wymuszamy podanie kategorii
    required this.description,
  });

  int get year => date.year;
  int get month => date.month;
  int get day => date.day;

  String get dayKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String get monthKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}';

  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;
}
