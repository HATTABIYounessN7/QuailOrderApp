import 'package:get/get.dart';
import 'package:quail_order_app/features/orders/controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrdersController());
  }
}
