import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
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
}
