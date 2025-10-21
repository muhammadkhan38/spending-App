import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../utils/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());

    // Open boxes
    await Hive.openBox<CategoryModel>(AppConstants.categoriesBox);
    await Hive.openBox<AccountModel>(AppConstants.accountsBox);
    await Hive.openBox<TransactionModel>(AppConstants.transactionsBox);

    // Initialize default data if boxes are empty
    await _initializeDefaultData();
  }

  static Future<void> _initializeDefaultData() async {
    final categoriesBox = Hive.box<CategoryModel>(AppConstants.categoriesBox);

    if (categoriesBox.isEmpty) {
      for (var category in AppConstants.defaultCategories) {
        final categoryModel = CategoryModel(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              category['title'],
          title: category['title'],
          iconCode: category['iconCode'],
          colorValue: category['colorValue'],
          type: category['type'] ?? 0,
        );
        await categoriesBox.add(categoryModel);
      }
    }
  }

  // Category operations
  static Box<CategoryModel> get categoriesBox =>
      Hive.box<CategoryModel>(AppConstants.categoriesBox);

  static Future<void> addCategory(CategoryModel category) async {
    await categoriesBox.add(category);
  }

  static Future<void> updateCategory(int index, CategoryModel category) async {
    await categoriesBox.putAt(index, category);
  }

  static Future<void> deleteCategory(int index) async {
    await categoriesBox.deleteAt(index);
  }

  // Account operations
  static Box<AccountModel> get accountsBox =>
      Hive.box<AccountModel>(AppConstants.accountsBox);

  static Future<void> addAccount(AccountModel account) async {
    await accountsBox.add(account);
  }

  static Future<void> updateAccount(int index, AccountModel account) async {
    await accountsBox.putAt(index, account);
  }

  static Future<void> deleteAccount(int index) async {
    await accountsBox.deleteAt(index);
  }

  // Transaction operations
  static Box<TransactionModel> get transactionsBox =>
      Hive.box<TransactionModel>(AppConstants.transactionsBox);

  static Future<void> addTransaction(TransactionModel transaction) async {
    await transactionsBox.add(transaction);

    // Update account balance
    final accountBox = accountsBox;
    for (int i = 0; i < accountBox.length; i++) {
      final account = accountBox.getAt(i);
      if (account?.id == transaction.accountId) {
        if (transaction.isExpense) {
          account!.balance -= transaction.amount;
        } else {
          account!.balance += transaction.amount;
        }
        await accountBox.putAt(i, account);
        break;
      }
    }
  }

  static Future<void> updateTransaction(
    int index,
    TransactionModel transaction,
  ) async {
    await transactionsBox.putAt(index, transaction);
  }

  static Future<void> deleteTransaction(int index) async {
    final transaction = transactionsBox.getAt(index);
    if (transaction != null) {
      // Update account balance
      final accountBox = accountsBox;
      for (int i = 0; i < accountBox.length; i++) {
        final account = accountBox.getAt(i);
        if (account?.id == transaction.accountId) {
          if (transaction.isExpense) {
            account!.balance += transaction.amount;
          } else {
            account!.balance -= transaction.amount;
          }
          await accountBox.putAt(i, account);
          break;
        }
      }
    }
    await transactionsBox.deleteAt(index);
  }
}
