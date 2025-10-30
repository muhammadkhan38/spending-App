class CategoryModel {
  String id;

  String title;

  int iconCode;

  int colorValue;

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

  // SQLite helpers
  Map<String, dynamic> toMap() => toJson();

  factory CategoryModel.fromMap(Map<String, dynamic> map) =>
      CategoryModel.fromJson(map.cast<String, dynamic>());
}
