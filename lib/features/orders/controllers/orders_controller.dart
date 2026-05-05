import 'package:get/get.dart';
import 'package:quail_order_app/data/models/order.dart';
import 'package:quail_order_app/data/repositories/order_repository.dart';
import 'package:quail_order_app/features/auth/controllers/auth_controller.dart';

class OrdersController extends GetxController {
  static OrdersController get to => Get.find();

  final RxList<Order> orders = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  void loadOrders() {
    final userId = AuthController.to.currentUser.value?.id ?? '';
    orders.value = OrderRepository.instance.getForUser(userId);
  }

  Order? findById(String id) => orders.firstWhereOrNull((o) => o.id == id);
}
