import 'dart:convert';

import 'package:quail_order_app/data/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepository {
  OrderRepository._();
  static final OrderRepository instance = OrderRepository._();

  final List<Order> _orders = [];

  List<Order> getAll() =>
      List.of(_orders)..sort((a, b) => b.placedAt.compareTo(a.placedAt));

  List<Order> getForUser(String userId) =>
      _orders.where((o) => o.userId == userId).toList()
        ..sort((a, b) => b.placedAt.compareTo(a.placedAt));

  Order? findById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addOrder(Order order) async {
    _orders.add(order);
    await _persist();
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    final order = findById(orderId);
    if (order == null) return;
    order.status = newStatus;
    order.updatedAt = DateTime.now();
    await _persist();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ordersData');
    if (raw == null) return;
    final list = jsonDecode(raw) as List;
    _orders
      ..clear()
      ..addAll(list.map((j) => Order.fromJson(j as Map<String, dynamic>)));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'ordersData',
      jsonEncode(_orders.map((o) => o.toJson()).toList()),
    );
  }
}
