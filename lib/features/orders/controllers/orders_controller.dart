import 'package:get/get.dart';
import 'package:quail_order_app/data/models/order.dart';
import 'package:quail_order_app/features/auth/controllers/auth_controller.dart';
import 'package:quail_order_app/services/api_client.dart';

class OrdersController extends GetxController {
  static OrdersController get to => Get.find();

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> loadOrders() async {
    final userId = AuthController.to.currentUser.value?.id;
    if (userId == null) return;
    isLoading.value = true;
    try {
      final data = await ApiClient.instance.get(
        '/orders',
        params: {'userId': userId},
      ) as List;
      orders.value = data
          .map((j) => Order.fromJson(j as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    } catch (_) {
      // keep current list on network error
    } finally {
      isLoading.value = false;
    }
  }

  Order? findById(String id) => orders.firstWhereOrNull((o) => o.id == id);
}
