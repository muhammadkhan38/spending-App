enum TransactionType { expense, income }

class TransactionModel {
  String id;

  String title;

  double amount;

  String categoryId;

  String accountId;

  DateTime date;

  int type; // 0 for expense, 1 for income

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

  // For SQLite mapping
  Map<String, dynamic> toMap() => toJson();

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel.fromJson(map.cast<String, dynamic>());
}
