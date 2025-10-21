import 'package:get/get.dart';
import '../models/account_model.dart';
import '../services/hive_service.dart';

class AccountViewModel extends GetxController {
  var accounts = <AccountModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  void loadAccounts() {
    try {
      isLoading.value = true;
      final box = HiveService.accountsBox;
      accounts.value = box.values.toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load accounts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAccount(AccountModel account) async {
    try {
      await HiveService.addAccount(account);
      loadAccounts();
      Get.back();
      Get.snackbar(
        'Success',
        'Account added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add account: $e');
    }
  }

  Future<void> updateAccount(int index, AccountModel account) async {
    try {
      await HiveService.updateAccount(index, account);
      loadAccounts();
      Get.back();
      Get.snackbar(
        'Success',
        'Account updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update account: $e');
    }
  }

  Future<void> deleteAccount(int index) async {
    try {
      await HiveService.deleteAccount(index);
      loadAccounts();
      Get.snackbar(
        'Success',
        'Account deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e');
    }
  }

  AccountModel? getAccountById(String id) {
    try {
      return accounts.firstWhere((acc) => acc.id == id);
    } catch (e) {
      return null;
    }
  }

  double getTotalBalance() {
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }
}
