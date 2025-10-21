import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int iconCode;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  int type; // 0 for expense, 1 for income

  CategoryModel({
    required this.id,
    required this.title,
    required this.iconCode,
    required this.colorValue,
    this.type = 0, // default to expense
  });

  bool get isExpense => type == 0;
  bool get isIncome => type == 1;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'type': type,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      iconCode: json['iconCode'],
      colorValue: json['colorValue'],
      type: json['type'] ?? 0,
    );
  }
}
