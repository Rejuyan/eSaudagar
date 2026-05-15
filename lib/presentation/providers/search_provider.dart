import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product_model.dart';
import 'product_provider.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

final searchResultsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.whenData((products) {
    if (query.isEmpty) {
      return [];
    }
    
    // Fuzzy matching logic based on title, description, and tags
    return products.where((product) {
      final titleMatch = product.title.toLowerCase().contains(query);
      final descMatch = product.description.toLowerCase().contains(query);
      final tagMatch = product.searchTags.any((tag) => tag.toLowerCase().contains(query));
      
      return titleMatch || descMatch || tagMatch;
    }).toList();
  });
});
