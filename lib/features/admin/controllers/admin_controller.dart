import 'package:get/get.dart';
import 'package:quail_order_app/data/models/order.dart';
import 'package:quail_order_app/data/repositories/order_repository.dart';
import 'package:quail_order_app/services/notification_service.dart';
import 'package:flutter/material.dart';

class AdminController extends GetxController {
  static AdminController get to => Get.find();

  final RxList<Order> orders = <Order>[].obs;
  final RxString filterStatus = 'all'.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    await OrderRepository.instance.load();

    final all = OrderRepository.instance.getAll();
    orders.value = filterStatus.value == 'all'
        ? all
        : all.where((o) => o.status == filterStatus.value).toList();
  }

  void applyFilter(String status) {
    filterStatus.value = status;
    loadOrders();
  }

  Order? findById(String id) => orders.firstWhereOrNull((o) => o.id == id);

  Future<void> updateStatus(String orderId, String newStatus) async {
    isUpdating.value = true;

    await OrderRepository.instance.updateStatus(orderId, newStatus);
    loadOrders();

    isUpdating.value = false;

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
