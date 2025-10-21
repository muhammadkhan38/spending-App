import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 1)
class AccountModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
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
}
