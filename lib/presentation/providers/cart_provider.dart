import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../domain/models/cart_item_model.dart';
import '../../domain/models/product_model.dart';
import '../../core/providers/shared_prefs_provider.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  static const _cartKey = 'cart_items';

  @override
  List<CartItem> build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final cartData = prefs.getString(_cartKey);
    if (cartData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cartData);
        return decoded.map((e) => CartItem.fromMap(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  void _saveCart() {
    final prefs = ref.read(sharedPrefsProvider);
    final encoded = jsonEncode(state.map((e) => e.toMap()).toList());
    prefs.setString(_cartKey, encoded);
  }

  void addProduct(Product product) {
    final existingIndex = state.indexWhere((item) => item.product.productId == product.productId);
    
    if (existingIndex >= 0) {
      // Increase quantity
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + 1);
      final newState = [...state];
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      // Add new item
      state = [...state, CartItem(product: product)];
    }
    _saveCart();
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.product.productId != productId).toList();
    _saveCart();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeProduct(productId);
      return;
    }

    final existingIndex = state.indexWhere((item) => item.product.productId == productId);
    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(quantity: newQuantity);
      final newState = [...state];
      newState[existingIndex] = updatedItem;
      state = newState;
      _saveCart();
    }
  }

  void clearCart() {
    state = [];
    _saveCart();
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (total, item) => total + item.totalPrice);
});
