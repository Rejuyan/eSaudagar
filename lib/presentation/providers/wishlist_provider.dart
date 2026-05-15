import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../domain/models/product_model.dart';
import '../../core/providers/shared_prefs_provider.dart';

class WishlistNotifier extends Notifier<List<Product>> {
  static const _wishlistKey = 'wishlist_items';

  @override
  List<Product> build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final wishlistData = prefs.getString(_wishlistKey);
    if (wishlistData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(wishlistData);
        return decoded.map((e) => Product.fromMap(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  void _saveWishlist() {
    final prefs = ref.read(sharedPrefsProvider);
    final encoded = jsonEncode(state.map((e) => e.toMap()).toList());
    prefs.setString(_wishlistKey, encoded);
  }

  void toggleWishlist(Product product) {
    final isExist = state.any((item) => item.productId == product.productId);
    if (isExist) {
      state = state.where((item) => item.productId != product.productId).toList();
    } else {
      state = [...state, product];
    }
    _saveWishlist();
  }

  bool isInWishlist(String productId) {
    return state.any((item) => item.productId == productId);
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<Product>>(() {
  return WishlistNotifier();
});
