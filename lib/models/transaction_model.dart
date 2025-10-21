import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

enum TransactionType { expense, income }

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  String accountId;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  int type; // 0 for expense, 1 for income

  @HiveField(7)
  String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.date,
    required this.type,
    this.note,
  });

  bool get isExpense => type == 0;
  bool get isIncome => type == 1;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'accountId': accountId,
      'date': date.toIso8601String(),
      'type': type,
      'note': note,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      note: json['note'],
    );
  }
}
