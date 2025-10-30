class AccountModel {
  String id;

  String name;

  int colorValue;

  double balance;

  AccountModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.balance = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'balance': balance,
    };
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      name: json['name'],
      colorValue: json['colorValue'],
      balance: json['balance'] ?? 0.0,
    );
  }

  // SQLite helpers
  Map<String, dynamic> toMap() => toJson();

  factory AccountModel.fromMap(Map<String, dynamic> map) =>
      AccountModel.fromJson(map.cast<String, dynamic>());
}
