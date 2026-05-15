import 'cart_item_model.dart';

enum OrderStatus {
  processing,
  shipped,
  delivered,
  cancelled
}

class OrderModel {
  final String orderId;
  final DateTime date;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;

  OrderModel({
    required this.orderId,
    required this.date,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.processing,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'date': date.millisecondsSinceEpoch,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.index,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      items: List<CartItem>.from(map['items']?.map((x) => CartItem.fromMap(x)) ?? []),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values[map['status'] ?? 0],
    );
  }
}
