import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/data/models/order.dart';
import 'package:quail_order_app/data/models/product.dart';
import 'package:quail_order_app/data/repositories/order_repository.dart';
import 'package:quail_order_app/data/repositories/product_repository.dart';
import 'package:quail_order_app/services/api_client.dart';
import 'package:quail_order_app/services/notification_service.dart';

class AdminController extends GetxController {
  static AdminController get to => Get.find();

  // ── Orders ────────────────────────────────────────────────────────────────
  final RxList<Order> orders = <Order>[].obs;
  final RxString filterStatus = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  // ── Products ──────────────────────────────────────────────────────────────
  final RxList<Product> products = <Product>[].obs;
  final RxBool isProductsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    loadProducts();
  }

  // ── Order methods ─────────────────────────────────────────────────────────

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final data = await ApiClient.instance.get('/orders') as List;
      final all = data
          .map((j) => Order.fromJson(j as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
      orders.value = filterStatus.value == 'all'
          ? all
          : all.where((o) => o.status == filterStatus.value).toList();
    } catch (_) {
      // keep current list on network error
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter(String status) {
    filterStatus.value = status;
    loadOrders();
  }

  Order? findById(String id) => orders.firstWhereOrNull((o) => o.id == id);

  Future<void> updateStatus(String orderId, String newStatus) async {
    isUpdating.value = true;
    try {
      await OrderRepository.instance.updateStatus(orderId, newStatus);
      await loadOrders();
    } finally {
      isUpdating.value = false;
    }

    await NotificationService.instance.showOrderUpdate(
      orderId: orderId,
      newStatus: newStatus,
    );

    Get.back();

    Get.snackbar(
      'Status updated',
      'Order set to $newStatus',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  // ── Product methods ───────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    isProductsLoading.value = true;
    try {
      final data = await ApiClient.instance.get('/products') as List;
      products.value = data
          .map((j) => Product.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // keep current list on network error
    } finally {
      isProductsLoading.value = false;
    }
  }

  Future<void> addProduct(Product product) async {
    isUpdating.value = true;
    try {
      final created = await ProductRepository.instance.create(product);
      products.add(created);
      Get.back();
      Get.snackbar(
        'Product added',
        created.name,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on ApiException catch (e) {
      _showApiError(e, 'Failed to add product');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> updateProduct(Product product) async {
    isUpdating.value = true;
    try {
      final updated = await ProductRepository.instance.update(product);
      final i = products.indexWhere((p) => p.id == product.id);
      if (i != -1) products[i] = updated;
      Get.back();
      Get.snackbar(
        'Product updated',
        updated.name,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on ApiException catch (e) {
      _showApiError(e, 'Failed to update product');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    isUpdating.value = true;
    try {
      await ProductRepository.instance.delete(id);
      products.removeWhere((p) => p.id == id);
      Get.snackbar(
        'Product deleted',
        '',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on ApiException catch (e) {
      _showApiError(e, 'Failed to delete product');
    } finally {
      isUpdating.value = false;
    }
  }

  void _showApiError(ApiException e, String fallback) {
    String msg = fallback;
    try {
      final body = jsonDecode(e.message) as Map<String, dynamic>;
      msg = (body['error'] as String?) ?? fallback;
    } catch (_) {}
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFCF3B3B),
      colorText: Colors.white,
    );
  }
}
