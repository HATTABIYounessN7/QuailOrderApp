import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/data/models/order.dart';
import 'package:quail_order_app/data/repositories/order_repository.dart';
import 'package:quail_order_app/services/api_client.dart';
import 'package:quail_order_app/services/notification_service.dart';

class AdminController extends GetxController {
  static AdminController get to => Get.find();

  final RxList<Order> orders = <Order>[].obs;
  final RxString filterStatus = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

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
      await loadOrders(); // awaited — list is fresh before we navigate away
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
}
