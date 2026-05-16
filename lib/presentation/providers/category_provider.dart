import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_provider.dart';
import '../../domain/models/product_model.dart';

// Defines available sorting options
enum ProductSort {
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
}

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

// Notifier to handle sorting selection
class SortSelectionNotifier extends Notifier<ProductSort> {
  @override
  ProductSort build() => ProductSort.priceLowToHigh;

  void setSort(ProductSort sort) {
    state = sort;
  }
}

// Tracks the currently selected sort option
final sortingProvider = NotifierProvider<SortSelectionNotifier, ProductSort>(() {
  return SortSelectionNotifier();
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

// Derives sorted product list based on filtered products and current sort selection
final sortedProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final filteredAsync = ref.watch(filteredProductsProvider);
  final currentSort = ref.watch(sortingProvider);

  return filteredAsync.whenData((products) {
    final sortedList = List<Product>.from(products);
    switch (currentSort) {
      case ProductSort.priceLowToHigh:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSort.priceHighToLow:
        sortedList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSort.ratingHighToLow:
        sortedList.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return sortedList;
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
