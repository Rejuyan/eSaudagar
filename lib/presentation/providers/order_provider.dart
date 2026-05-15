import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../domain/models/order_model.dart';
import '../../core/providers/shared_prefs_provider.dart';

class OrderNotifier extends Notifier<List<OrderModel>> {
  static const _ordersKey = 'order_history';

  @override
  List<OrderModel> build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final data = prefs.getString(_ordersKey);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.map((e) => OrderModel.fromMap(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  void addOrder(OrderModel order) {
    state = [order, ...state];
    _saveOrders();
  }

  void _saveOrders() {
    final prefs = ref.read(sharedPrefsProvider);
    final encoded = jsonEncode(state.map((e) => e.toMap()).toList());
    prefs.setString(_ordersKey, encoded);
  }
}

final orderProvider = NotifierProvider<OrderNotifier, List<OrderModel>>(() {
  return OrderNotifier();
});
