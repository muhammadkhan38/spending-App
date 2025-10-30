class BudgetModel {
  String id;

  double amount;

  String categoryId;

  DateTime startDate;

  DateTime endDate;

  BudgetModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      amount: json['amount'],
      categoryId: json['categoryId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  // SQLite helpers
  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'categoryId': categoryId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };

  factory BudgetModel.fromMap(Map<String, dynamic> map) =>
      BudgetModel.fromJson(map.cast<String, dynamic>());
}
