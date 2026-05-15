import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_provider.dart';
import '../../domain/models/product_model.dart';

// Notifier to handle category selection
class CategorySelectionNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCategory(String? category) {
    state = category;
  }
}

// Tracks the currently selected category filter (null = All)
final selectedCategoryProvider = NotifierProvider<CategorySelectionNotifier, String?>(() {
  return CategorySelectionNotifier();
});

// Derives filtered product list based on selected category
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.whenData((products) {
    if (selectedCategory == null) return products;
    return products.where((p) => p.category == selectedCategory).toList();
  });
});

// Derives unique category list from loaded products
final categoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.whenData((products) {
    final categories = products.map((p) => p.category).toSet().toList();
    return categories;
  });
});
