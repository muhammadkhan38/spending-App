import 'package:get/get.dart';
import '../models/category_model.dart';
import '../services/hive_service.dart';

class CategoryViewModel extends GetxController {
  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() {
    try {
      isLoading.value = true;
      final box = HiveService.categoriesBox;
      categories.value = box.values.toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await HiveService.addCategory(category);
      loadCategories();
      Get.back();
      Get.snackbar(
        'Success',
        'Category added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e');
    }
  }

  Future<void> updateCategory(int index, CategoryModel category) async {
    try {
      await HiveService.updateCategory(index, category);
      loadCategories();
      Get.back();
      Get.snackbar(
        'Success',
        'Category updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int index) async {
    try {
      await HiveService.deleteCategory(index);
      loadCategories();
      Get.snackbar(
        'Success',
        'Category deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e');
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  List<CategoryModel> get expenseCategories {
    return categories.where((cat) => cat.isExpense).toList();
  }

  List<CategoryModel> get incomeCategories {
    return categories.where((cat) => cat.isIncome).toList();
  }

  List<CategoryModel> getCategoriesByType(int type) {
    return categories.where((cat) => cat.type == type).toList();
  }
}
