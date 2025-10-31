import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';
import 'account_viewmodel.dart';

class TransactionViewModel extends GetxController {
  var transactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var selectedType = 0.obs; // 0 for expense, 1 for income

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    try {
      isLoading.value = true;
      final box = HiveService.transactionsBox;
      transactions.value = box.values.toList();
      // Sort by date descending
      transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<TransactionModel> get filteredTransactions {
    return transactions.where((t) => t.type == selectedType.value).toList();
  }

  List<TransactionModel> get expenseTransactions {
    return transactions.where((t) => t.isExpense).toList();
  }

  List<TransactionModel> get incomeTransactions {
    return transactions.where((t) => t.isIncome).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await HiveService.addTransaction(transaction);
      loadTransactions();
      // Reload accounts to update balances
      Get.find<AccountViewModel>().loadAccounts();
      Get.back();
      Get.snackbar(
        'Success',
        'Transaction added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add transaction: $e');
    }
  }

  Future<void> updateTransaction(
    String id,
    TransactionModel transaction,
  ) async {
    try {
      await HiveService.updateTransaction(id, transaction);
      loadTransactions();
      Get.back();
      Get.snackbar(
        'Success',
        'Transaction updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await HiveService.deleteTransaction(id);

      loadTransactions();
      // Reload accounts to update balances
      Get.find<AccountViewModel>().loadAccounts();
      Get.snackbar(
        'Success',
        'Transaction deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete transaction: $e');
    }
  }

  double getTotalExpense() {
    return expenseTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  double getTotalIncome() {
    return incomeTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  Map<String, double> getExpensesByCategory() {
    Map<String, double> categoryExpenses = {};
    for (var transaction in expenseTransactions) {
      categoryExpenses[transaction.categoryId] =
          (categoryExpenses[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return categoryExpenses;
  }

  Map<String, double> getIncomeByCategory() {
    Map<String, double> categoryIncome = {};
    for (var transaction in incomeTransactions) {
      categoryIncome[transaction.categoryId] =
          (categoryIncome[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return categoryIncome;
  }
}
