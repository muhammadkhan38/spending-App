import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/account_model.dart';
import '../viewmodels/account_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_widgets.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountVM = Get.find<AccountViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (accountVM.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Card
              CustomCard(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${accountVM.getTotalBalance().toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${accountVM.accounts.length} ${accountVM.accounts.length == 1 ? "Account" : "Accounts"}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Accounts List
              if (accountVM.accounts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No accounts yet',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap + to add your first account',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Accounts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: accountVM.accounts.length,
                      itemBuilder: (context, index) {
                        final account = accountVM.accounts[index];

                        return CustomCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () =>
                              _showEditAccountDialog(context, account, index),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color(
                                    account.colorValue,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    color: Color(account.colorValue),
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Balance',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${account.balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: account.balance >= 0
                                      ? AppColors.income
                                      : AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAccountDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final accountVM = Get.find<AccountViewModel>();
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    final selectedColor = Rx<Color>(Colors.blue);

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                CustomTextField(
                  label: 'Account Name',
                  hint: 'e.g., Cash, Bank, Credit Card',
                  controller: nameController,
                ),
                const SizedBox(height: 16),

                // Initial Balance
                CustomTextField(
                  label: 'Initial Balance',
                  hint: 'Enter initial balance',
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                const SizedBox(height: 20),

                // Color Selection
                const Text(
                  'Select Color',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppConstants.availableColors.map((color) {
                      return ColorCircle(
                        color: color,
                        isSelected: selectedColor.value == color,
                        onTap: () => selectedColor.value = color,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Preview
                Obx(
                  () => Center(
                    child: Column(
                      children: [
                        const Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: selectedColor.value.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: selectedColor.value,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Add',
                        onPressed: () {
                          if (nameController.text.isEmpty) {
                            Get.snackbar('Error', 'Please enter account name');
                            return;
                          }

                          final account = AccountModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text,
                            colorValue: selectedColor.value.value,
                            balance:
                                double.tryParse(balanceController.text) ?? 0,
                          );

                          accountVM.addAccount(account);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditAccountDialog(
    BuildContext context,
    AccountModel account,
    int index,
  ) {
    final accountVM = Get.find<AccountViewModel>();
    final nameController = TextEditingController(text: account.name);
    final selectedColor = Rx<Color>(Color(account.colorValue));

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        Get.back();
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                              'Are you sure you want to delete this account?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  accountVM.deleteAccount(index);
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name
                CustomTextField(
                  label: 'Account Name',
                  hint: 'e.g., Cash, Bank, Credit Card',
                  controller: nameController,
                ),
                const SizedBox(height: 16),

                // Current Balance (Read-only)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        '\$${account.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: account.balance >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Color Selection
                const Text(
                  'Select Color',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppConstants.availableColors.map((color) {
                      return ColorCircle(
                        color: color,
                        isSelected: selectedColor.value == color,
                        onTap: () => selectedColor.value = color,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Preview
                Obx(
                  () => Center(
                    child: Column(
                      children: [
                        const Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: selectedColor.value.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: selectedColor.value,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Save',
                        onPressed: () {
                          if (nameController.text.isEmpty) {
                            Get.snackbar('Error', 'Please enter account name');
                            return;
                          }

                          final updatedAccount = AccountModel(
                            id: account.id,
                            name: nameController.text,
                            colorValue: selectedColor.value.value,
                            balance: account.balance,
                          );

                          accountVM.updateAccount(index, updatedAccount);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
