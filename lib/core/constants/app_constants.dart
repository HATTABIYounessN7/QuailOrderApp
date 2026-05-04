class Routes {
  Routes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/order/:id';
  static const String adminHome = '/admin';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/order/:id';

  static String product(String id) => '/product/$id';
  static String order(String id) => '/order/$id';
  static String adminOrder(String id) => '/admin/order/$id';
}

class PrefKeys {
  PrefKeys._();

  static const String userId = 'userId';
  static const String userRole = 'userRole';
  static const String cartData = 'cartData';
  static const String ordersData = 'ordersData';
}

class NotifChannel {
  NotifChannel._();

  static const String channelId = 'quail_shop_orders';
  static const String channelName = 'Order Updates';
  static const String channelDesc = 'Notifications for order status changes';
}

class ProductCategory {
  static const String quail = 'quail';
  static const String eggs = 'eggs';
  static const String all = 'all';
}

class OrderStatus {
  OrderStatus._();

  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String inRoute = 'in_route';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static const List<String> all = [
    pending,
    confirmed,
    inRoute,
    delivered,
    cancelled,
  ];
}
