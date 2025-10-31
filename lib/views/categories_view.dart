import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/category_model.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_widgets.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryVM = Get.find<CategoryViewModel>();
    final selectedType = (-1).obs; // -1 = All, 0 = Expense, 1 = Income

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (categoryVM.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryVM.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No categories yet',
                  style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap + to add your first category',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Toggle Buttons: Expense / Income
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: () => selectedType.value = 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedType.value == 0
                                ? AppColors.expense
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                color: selectedType.value == 0
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: () => selectedType.value = 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedType.value == 1
                                ? AppColors.income
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Income',
                              style: TextStyle(
                                color: selectedType.value == 1
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category list (filtered)
              Obx(() {
                final categoriesToShow = selectedType.value == -1
                    ? categoryVM.categories
                    : categoryVM.getCategoriesByType(selectedType.value);

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoriesToShow.length,
                  itemBuilder: (context, index) {
                    final category = categoriesToShow[index];

                    // If a type is selected (0 or 1) show compact view: icon + title only
                    final compact =
                        selectedType.value == 0 || selectedType.value == 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: CustomCard(
                        onTap: () => _showEditCategoryDialog(
                          context,
                          category,
                          categoryVM.categories.indexOf(category),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            CategoryIcon(
                              icon: IconData(
                                category.iconCode,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: Color(category.colorValue),
                              size: 15,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                category.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // In compact mode we show only icon+title, no badge or edit icon
                            if (!compact) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: category.isExpense
                                      ? AppColors.expense.withOpacity(0.1)
                                      : AppColors.income.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category.isExpense ? 'Expense' : 'Income',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: category.isExpense
                                        ? AppColors.expense
                                        : AppColors.income,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final categoryVM = Get.find<CategoryViewModel>();
    final titleController = TextEditingController();
    final selectedIcon = Rx<IconData>(Icons.category);
    final selectedColor = Rx<Color>(Colors.blue);
    final selectedType = 0.obs; // 0 for expense, 1 for income

    Get.dialog(

      Dialog(

        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Type Toggle
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => GestureDetector(
                          onTap: () => selectedType.value = 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType.value == 0
                                  ? AppColors.expense
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Expense',
                                style: TextStyle(
                                  color: selectedType.value == 0
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => GestureDetector(
                          onTap: () => selectedType.value = 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType.value == 1
                                  ? AppColors.income
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Income',
                                style: TextStyle(
                                  color: selectedType.value == 1
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                CustomTextField(
                  label: 'Category Name',
                  hint: 'Enter category name',
                  controller: titleController,
                ),
                const SizedBox(height: 20),

                // Icon Selection
                const Text(
                  'Select Icon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.availableIcons.map((icon) {
                      return IconSelector(
                        icon: icon,
                        isSelected: selectedIcon.value == icon,
                        onTap: () => selectedIcon.value = icon,
                      );
                    }).toList(),
                  ),
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
                        CategoryIcon(
                          icon: selectedIcon.value,
                          color: selectedColor.value,
                          size: 48,
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
                          if (titleController.text.isEmpty) {
                            Get.snackbar('Error', 'Please enter category name');
                            return;
                          }

                          final category = CategoryModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            title: titleController.text,
                            iconCode: selectedIcon.value.codePoint,
                            colorValue: selectedColor.value.value,
                            type: selectedType.value,
                          );

                          categoryVM.addCategory(category);
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

  void _showEditCategoryDialog(
    BuildContext context,
    CategoryModel category,
    int index,
  ) {
    final categoryVM = Get.find<CategoryViewModel>();
    final titleController = TextEditingController(text: category.title);
    final selectedIcon = Rx<IconData>(
      IconData(category.iconCode, fontFamily: 'MaterialIcons'),
    );
    final selectedColor = Rx<Color>(Color(category.colorValue));
    final selectedType = Rx<int>(category.type);

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
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
                      'Edit Category',
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

                        // Check if category is used in any transactions
                        final transactionVM = Get.find<TransactionViewModel>();
                        final hasTransactions = transactionVM.transactions.any(
                          (transaction) =>
                              transaction.categoryId == category.id,
                        );

                        if (hasTransactions) {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Cannot Delete Category'),
                              content: const Text(
                                'This category is being used by one or more transactions. Please delete or reassign those transactions first.',
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        Get.dialog(
                          AlertDialog(
                            title: const Text('Delete Category'),
                            content: const Text(
                              'Are you sure you want to delete this category?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  categoryVM.deleteCategory(index);
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
                        () => GestureDetector(
                          onTap: () => selectedType.value = 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType.value == 0
                                  ? AppColors.expense
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Expense',
                                style: TextStyle(
                                  color: selectedType.value == 0
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => GestureDetector(
                          onTap: () => selectedType.value = 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType.value == 1
                                  ? AppColors.income
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Income',
                                style: TextStyle(
                                  color: selectedType.value == 1
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                CustomTextField(
                  label: 'Category Name',
                  hint: 'Enter category name',
                  controller: titleController,
                ),
                const SizedBox(height: 20),

                // Icon Selection
                const Text(
                  'Select Icon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.availableIcons.map((icon) {
                      return IconSelector(
                        icon: icon,
                        isSelected: selectedIcon.value == icon,
                        onTap: () => selectedIcon.value = icon,
                      );
                    }).toList(),
                  ),
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
                        CategoryIcon(
                          icon: selectedIcon.value,
                          color: selectedColor.value,
                          size: 48,
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
                          if (titleController.text.isEmpty) {
                            Get.snackbar('Error', 'Please enter category name');
                            return;
                          }

                          final updatedCategory = CategoryModel(
                            id: category.id,
                            title: titleController.text,
                            iconCode: selectedIcon.value.codePoint,
                            colorValue: selectedColor.value.value,
                            type: selectedType.value,
                          );

                          categoryVM.updateCategory(index, updatedCategory);
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
