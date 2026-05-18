import 'package:quail_order_app/data/models/order.dart';
import 'package:quail_order_app/services/api_client.dart';

// Write-only repository — controllers own their read data (fetched from API).
class OrderRepository {
  OrderRepository._();
  static final OrderRepository instance = OrderRepository._();

  Future<void> addOrder(Order order) async {
    await ApiClient.instance.post('/orders', order.toJson());
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    await ApiClient.instance.patch('/orders/$orderId/status', {'status': newStatus});
  }
}
