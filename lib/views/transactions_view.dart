import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionVM = Get.find<TransactionViewModel>();
    final categoryVM = Get.find<CategoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (transactionVM.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (transactionVM.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap + to add your first transaction',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: transactionVM.transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactionVM.transactions[index];
            final category = categoryVM.getCategoryById(transaction.categoryId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: Key(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white, size: 32),
                ),
                confirmDismiss: (direction) async {
                  final result = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Delete Transaction'),
                      content: const Text(
                        'Are you sure you want to delete this transaction?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  
                  return result ?? false;
                },
                onDismissed: (direction) {
                  // Delete the transaction
                  transactionVM.deleteTransaction(index);
                },
                child: CustomCard(
                onTap: () =>
                    _showEditTransactionDialog(context, transaction, index),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Category Icon
                    if (category != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(category.colorValue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconData(
                            category.iconCode,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: Color(category.colorValue),
                          size: 24,
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Category and Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category != null ? category.title : '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(transaction.date),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount and Type
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${transaction.isExpense ? "-" : "+"}Rs ${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: transaction.isExpense
                                ? AppColors.expense
                                : AppColors.income,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: transaction.isExpense
                                ? AppColors.expense.withOpacity(0.1)
                                : AppColors.income.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.isExpense ? 'Expense' : 'Income',
                            style: TextStyle(
                              fontSize: 10,
                              color: transaction.isExpense
                                  ? AppColors.expense
                                  : AppColors.income,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Delete Button
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Delete Transaction'),
                            content: const Text(
                              'Are you sure you want to delete this transaction?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  transactionVM.deleteTransaction(index);
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
              ),
            ),
          );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionTypeDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  void _showTransactionTypeDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Transaction Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Income',
                      icon: Icons.arrow_downward,
                      onPressed: () {
                        Get.back();
                        _showAddTransactionDialog(context, 1); // 1 for income
                      },
                      backgroundColor: AppColors.income,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      text: 'Expense',
                      icon: Icons.arrow_upward,
                      onPressed: () {
                        Get.back();
                        _showAddTransactionDialog(context, 0); // 0 for expense
                      },
                      backgroundColor: AppColors.expense,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, int transactionType) {
    final transactionVM = Get.find<TransactionViewModel>();
    final categoryVM = Get.find<CategoryViewModel>();

    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final selectedType = transactionType.obs; // Use passed transaction type
    final selectedCategory = Rxn<String>();
    final selectedDate = DateTime.now().obs;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add ${transactionType == 1 ? "Income" : "Expense"}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                CustomTextField(
                  label: 'Amount',
                  hint: 'Enter amount',
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                const SizedBox(height: 16),

                // Category Dropdown - Only show categories of selected type
                Obx(() {
                  final filteredCategories = categoryVM.getCategoriesByType(
                    selectedType.value,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          hintText: 'Select category',
                        ),
                        value: selectedCategory.value,
                        items: filteredCategories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  IconData(
                                    category.iconCode,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  color: Color(category.colorValue),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    category.title,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => selectedCategory.value = value,
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // Date Picker
                Obx(() {
                  return InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        selectedDate.value = pickedDate;
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(selectedDate.value),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Note
                CustomTextField(
                  label: 'Note (Optional)',
                  hint: 'Enter note',
                  controller: noteController,
                  maxLines: 3,
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
                          if (amountController.text.isEmpty ||
                              selectedCategory.value == null) {
                            Get.snackbar(
                              'Error',
                              'Please fill all required fields',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          final transaction = TransactionModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            title: '',
                            amount: double.parse(amountController.text),
                            categoryId: selectedCategory.value!,
                            accountId: '',
                            date: selectedDate.value,
                            type: selectedType.value,
                            note: noteController.text.isEmpty
                                ? null
                                : noteController.text,
                          );

                          transactionVM.addTransaction(transaction);
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

  void _showEditTransactionDialog(
    BuildContext context,
    TransactionModel transaction,
    int index,
  ) {
    final transactionVM = Get.find<TransactionViewModel>();
    final categoryVM = Get.find<CategoryViewModel>();

    final amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    final noteController = TextEditingController(text: transaction.note ?? '');
    final selectedCategory = Rx<String>(transaction.categoryId);
    final selectedDate = Rx<DateTime>(transaction.date);
    final selectedType = Rx<int>(transaction.type);

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
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
                      'Edit Transaction',
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
                            title: const Text('Delete Transaction'),
                            content: const Text(
                              'Are you sure you want to delete this transaction?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  transactionVM.deleteTransaction(index);
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

                // Type Toggle
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => CustomButton(
                          text: 'Expense',
                          onPressed: () => selectedType.value = 0,
                          backgroundColor: selectedType.value == 0
                              ? AppColors.expense
                              : Colors.grey[300],
                          textColor: selectedType.value == 0
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => CustomButton(
                          text: 'Income',
                          onPressed: () => selectedType.value = 1,
                          backgroundColor: selectedType.value == 1
                              ? AppColors.income
                              : Colors.grey[300],
                          textColor: selectedType.value == 1
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount
                CustomTextField(
                  label: 'Amount',
                  hint: 'Enter amount',
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                Obx(() {
                  final categories = categoryVM.getCategoriesByType(
                    selectedType.value,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          hintText: 'Select category',
                        ),
                        value:
                            categories.any(
                              (c) => c.id == selectedCategory.value,
                            )
                            ? selectedCategory.value
                            : null,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  IconData(
                                    category.iconCode,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  color: Color(category.colorValue),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    category.title,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCategory.value = value;
                          }
                        },
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // Date Picker
                Obx(() {
                  return InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        selectedDate.value = pickedDate;
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(selectedDate.value),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Note
                CustomTextField(
                  label: 'Note (Optional)',
                  hint: 'Enter note',
                  controller: noteController,
                  maxLines: 3,
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
                          if (amountController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please enter amount',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          final updatedTransaction = TransactionModel(
                            id: transaction.id,
                            title: '',
                            amount: double.parse(amountController.text),
                            categoryId: selectedCategory.value,
                            accountId: transaction.accountId,
                            date: selectedDate.value,
                            type: selectedType.value,
                            note: noteController.text.isEmpty
                                ? null
                                : noteController.text,
                          );

                          transactionVM.updateTransaction(
                            index,
                            updatedTransaction,
                          );
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
