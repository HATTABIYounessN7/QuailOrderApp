import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/data/models/cart_item.dart';
import 'package:quail_order_app/data/models/order.dart';
import 'package:quail_order_app/data/models/product.dart';
import 'package:quail_order_app/data/repositories/order_repository.dart';
import 'package:quail_order_app/features/auth/controllers/auth_controller.dart';
import 'package:quail_order_app/services/api_client.dart';

class CartController extends GetxController {
  static CartController get to => Get.find();

  final RxList<CartItem> items = <CartItem>[].obs;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get total => items.fold(0.0, (sum, i) => sum + i.subtotal);
  bool get isEmpty => items.isEmpty;

  void addItem(Product product, int quantity) {
    final existing = _findItem(product.id);
    if (existing != null) {
      existing.quantity += quantity;
      items.refresh();
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }

    Get.snackbar(
      'Added to cart',
      '${product.name} x$quantity',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void removeItem(String productId) {
    items.removeWhere((i) => i.product.id == productId);
  }

  void updateQuantity(String productId, int newQty) {
    if (newQty <= 0) {
      removeItem(productId);
      return;
    }
    final item = _findItem(productId);
    if (item == null) return;
    item.quantity = newQty;
    items.refresh();
  }

  void clearCart() => items.clear();

  Future<void> placeOrder({
    required String deliveryAddress,
    required String phone,
  }) async {
    final user = AuthController.to.currentUser.value!;

    final order = Order(
      id: _generateId(),
      userId: user.id,
      customerName: user.name,
      deliveryAddress: deliveryAddress,
      phone: phone,
      items: items.map(OrderItem.fromCartItem).toList(),
      placedAt: DateTime.now(),
      status: OrderStatus.pending,
    );

    try {
      await OrderRepository.instance.addOrder(order);
    } on ApiException catch (e) {
      String msg = 'Failed to place order. Please try again.';
      try {
        final body = jsonDecode(e.message) as Map<String, dynamic>;
        msg = (body['error'] as String?) ?? msg;
      } catch (_) {}
      Get.snackbar(
        'Order Failed',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    clearCart();
    Get.offAllNamed(Routes.home);
    Get.snackbar(
      'Order placed successfully!',
      'Your order #${order.id.substring(0, 6).toUpperCase()} is being prepared.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  CartItem? _findItem(String productId) {
    try {
      return items.firstWhere((i) => i.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  String _generateId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}';
  }
}
