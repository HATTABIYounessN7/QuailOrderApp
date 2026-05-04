import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/data/models/cart_item.dart';

class OrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String unit;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromCartItem(CartItem item) => OrderItem(
    productId: item.product.id,
    productName: item.product.name,
    unitPrice: item.product.price,
    quantity: item.quantity,
    unit: item.product.unit,
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'unit': unit,
  };

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    productId: j['productId'],
    productName: j['productName'],
    unitPrice: (j['unitPrice'] as num).toDouble(),
    quantity: j['quantity'],
    unit: j['unit'],
  );
}

class Order {
  final String id;
  final String userId;
  final String customerName;
  final String deliveryAddress;
  final String phone;
  final List<OrderItem> items;
  final DateTime placedAt;
  String status;
  DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.deliveryAddress,
    required this.phone,
    required this.items,
    required this.placedAt,
    this.status = OrderStatus.pending,
    this.updatedAt,
  });

  double get total => items.fold(0, (sum, i) => sum + i.subtotal);
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'customerName': customerName,
    'deliveryAddress': deliveryAddress,
    'phone': phone,
    'items': items.map((i) => i.toJson()).toList(),
    'placedAt': placedAt.toIso8601String(),
    'status': status,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: j['id'],
    userId: j['userId'],
    customerName: j['customerName'],
    deliveryAddress: j['deliveryAddress'],
    phone: j['phone'],
    items: (j['items'] as List)
        .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    placedAt: DateTime.parse(j['placedAt']),
    status: j['status'],
    updatedAt: j['updatedAt'] != null ? DateTime.parse(j['updatedAt']) : null,
  );
}
