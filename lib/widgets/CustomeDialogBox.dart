import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../widgets/custom_button.dart';

import '../utils/app_theme.dart';
import 'custom_text_field.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionModel transaction;
  final int index;

  const EditTransactionPage({
    Key? key,
    required this.transaction,
    required this.index,
  }) : super(key: key);

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final transactionVM = Get.find<TransactionViewModel>();
  final categoryVM = Get.find<CategoryViewModel>();

  late TextEditingController amountController;
  late TextEditingController noteController;

  late Rx<String> selectedCategory;
  late Rx<DateTime> selectedDate;
  late Rx<int> selectedType;

  @override
  void initState() {
    super.initState();
    amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    noteController = TextEditingController(text: widget.transaction.note ?? '');
    selectedCategory = Rx<String>(widget.transaction.categoryId);
    selectedDate = Rx<DateTime>(widget.transaction.date);
    selectedType = Rx<int>(widget.transaction.type);
  }

  void _deleteTransaction() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              transactionVM.deleteTransaction(widget.transaction.id);
              Get.back(); // close dialog
              Get.back(); // close page
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveTransaction() {
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter amount',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final updatedTransaction = TransactionModel(
      id: widget.transaction.id,
      title: '',
      amount: double.parse(amountController.text),
      categoryId: selectedCategory.value,
      accountId: widget.transaction.accountId,
      date: selectedDate.value,
      type: selectedType.value,
      note: noteController.text.isEmpty ? null : noteController.text,
    );

    transactionVM.updateTransaction(widget.transaction.id, updatedTransaction);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _deleteTransaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            Row(
              children: [
                Expanded(
                  child: Obx(() => CustomButton(
                    text: 'Expense',
                    onPressed: () => selectedType.value = 0,
                    backgroundColor: selectedType.value == 0
                        ? AppColors.expense
                        : Colors.grey[300],
                    textColor: selectedType.value == 0
                        ? Colors.white
                        : Colors.black87,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => CustomButton(
                    text: 'Income',
                    onPressed: () => selectedType.value = 1,
                    backgroundColor: selectedType.value == 1
                        ? AppColors.income
                        : Colors.grey[300],
                    textColor: selectedType.value == 1
                        ? Colors.white
                        : Colors.black87,
                  )),
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              prefixIcon: const Icon(Icons.attach_money),
            ),
            const SizedBox(height: 16),

            // Category dropdown
            Obx(() {
              final categories =
              categoryVM.getCategoriesByType(selectedType.value);
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(hintText: 'Select category'),
                value: categories.any((c) => c.id == selectedCategory.value)
                    ? selectedCategory.value
                    : null,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(
                          IconData(category.iconCode,
                              fontFamily: 'MaterialIcons'),
                          color: Color(category.colorValue),
                        ),
                        const SizedBox(width: 8),
                        Text(category.title),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedCategory.value = value;
                },
              );
            }),
            const SizedBox(height: 16),

            // Date picker
            Obx(() {
              return InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) selectedDate.value = picked;
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
                    onPressed: _saveTransaction,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
