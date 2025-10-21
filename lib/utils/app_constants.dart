import 'package:flutter/material.dart';

class AppConstants {
  // Box names
  static const String categoriesBox = 'categories';
  static const String accountsBox = 'accounts';
  static const String transactionsBox = 'transactions';

  // Default categories
  static final List<Map<String, dynamic>> defaultCategories = [
    // Expense Categories
    {
      'title': 'Food & Dining',
      'iconCode': Icons.restaurant.codePoint,
      'colorValue': Colors.orange.value,
      'type': 0,
    },
    {
      'title': 'Shopping',
      'iconCode': Icons.shopping_bag.codePoint,
      'colorValue': Colors.pink.value,
      'type': 0,
    },
    {
      'title': 'Transportation',
      'iconCode': Icons.directions_car.codePoint,
      'colorValue': Colors.blue.value,
      'type': 0,
    },
    {
      'title': 'Entertainment',
      'iconCode': Icons.movie.codePoint,
      'colorValue': Colors.purple.value,
      'type': 0,
    },
    {
      'title': 'Bills & Utilities',
      'iconCode': Icons.receipt_long.codePoint,
      'colorValue': Colors.red.value,
      'type': 0,
    },
    {
      'title': 'Health',
      'iconCode': Icons.local_hospital.codePoint,
      'colorValue': Colors.green.value,
      'type': 0,
    },
    {
      'title': 'Education',
      'iconCode': Icons.school.codePoint,
      'colorValue': Colors.indigo.value,
      'type': 0,
    },
    // Income Categories
    {
      'title': 'Salary',
      'iconCode': Icons.attach_money.codePoint,
      'colorValue': Colors.teal.value,
      'type': 1,
    },
    {
      'title': 'Investment',
      'iconCode': Icons.trending_up.codePoint,
      'colorValue': Colors.lightGreen.value,
      'type': 1,
    },
    {
      'title': 'Gift',
      'iconCode': Icons.card_giftcard.codePoint,
      'colorValue': Colors.amber.value,
      'type': 1,
    },
    {
      'title': 'Freelance',
      'iconCode': Icons.work.codePoint,
      'colorValue': Colors.deepPurple.value,
      'type': 1,
    },
  ];

  // Available icons for selection
  static final List<IconData> availableIcons = [
    Icons.restaurant,
    Icons.shopping_bag,
    Icons.directions_car,
    Icons.movie,
    Icons.receipt_long,
    Icons.local_hospital,
    Icons.school,
    Icons.attach_money,
    Icons.trending_up,
    Icons.card_giftcard,
    Icons.home,
    Icons.flight,
    Icons.fitness_center,
    Icons.phone,
    Icons.laptop,
    Icons.pets,
    Icons.sports_soccer,
    Icons.book,
    Icons.music_note,
    Icons.camera_alt,
  ];

  // Available colors for selection
  static final List<Color> availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];
}
