import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../utils/app_theme.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SpendingView extends StatelessWidget {
  const SpendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionVM = Get.find<TransactionViewModel>();
    final categoryVM = Get.find<CategoryViewModel>();
    final selectedCategoryType = 0.obs; // 0 for expense, 1 for income

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (transactionVM.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalIncome = transactionVM.getTotalIncome();
        final totalExpense = transactionVM.getTotalExpense();
        final totalBudget = totalIncome; // Budget equals total income
        final remaining = totalBudget - totalExpense;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Overview Card
              Container(
                width: Get.width,
                padding: const EdgeInsets.all(16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Income',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          'Rs ${totalIncome.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Expense',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          'Rs ${totalExpense.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Remaining Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rs ${remaining.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: remaining >= 0
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Type Toggle Buttons
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => CustomButton(
                        text: 'Expense',
                        icon: Icons.arrow_upward,
                        onPressed: () => selectedCategoryType.value = 0,
                        backgroundColor: selectedCategoryType.value == 0
                            ? AppColors.expense
                            : Colors.grey[300],
                        textColor: selectedCategoryType.value == 0
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
                        icon: Icons.arrow_downward,
                        onPressed: () => selectedCategoryType.value = 1,
                        backgroundColor: selectedCategoryType.value == 1
                            ? AppColors.income
                            : Colors.grey[300],
                        textColor: selectedCategoryType.value == 1
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Transaction Button
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => CustomButton(
                        text: selectedCategoryType.value == 0
                            ? 'Add Expense'
                            : 'Add Income',
                        icon: Icons.add,
                        onPressed: () => _showAddTransactionDialog(context, selectedCategoryType.value,),
                        backgroundColor: selectedCategoryType.value == 0
                            ? AppColors.expense
                            : AppColors.income,
                        textColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Categories Section Header
              Obx(
                () => Text(
                  selectedCategoryType.value == 0
                      ? 'Expense Categories'
                      : 'Income Categories',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Obx(() {
                final categoriesByType = selectedCategoryType.value == 0
                    ? transactionVM.getExpensesByCategory()
                    : transactionVM.getIncomeByCategory();
                final totalAmount = selectedCategoryType.value == 0
                    ? totalExpense
                    : totalIncome;

                if (categoriesByType.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedCategoryType.value == 0
                                ? 'No expenses yet'
                                : 'No income yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoriesByType.length,
                  itemBuilder: (context, index) {
                    final categoryId = categoriesByType.keys.elementAt(index);
                    final amount = categoriesByType[categoryId]!;
                    final category = categoryVM.getCategoryById(categoryId);

                    if (category == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.all(12),
                          //   decoration: BoxDecoration(
                          //     color: Color(
                          //       category.colorValue,
                          //     ).withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   child: Icon(
                          //     IconData(
                          //       category.iconCode,
                          //       fontFamily: 'MaterialIcons',
                          //     ),
                          //     color: Color(category.colorValue),
                          //     size: 28,
                          //   ),
                          // ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  totalAmount > 0
                                      ? '${((amount / totalAmount) * 100).toStringAsFixed(1)}% of total'
                                      : '0% of total',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rs ${amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: selectedCategoryType.value == 0
                                  ? AppColors.expense
                                  : AppColors.income,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      }),
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
}
