import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/features/admin/bindings/admin_binding.dart';
import 'package:quail_order_app/features/admin/screens/admin_order_detail_screen.dart';
import 'package:quail_order_app/features/admin/screens/admin_orders_screen.dart';
import 'package:quail_order_app/features/admin/screens/admin_shell.dart';
import 'package:quail_order_app/features/auth/bindings/auth_binding.dart';
import 'package:quail_order_app/features/auth/screens/login_screen.dart';
import 'package:quail_order_app/features/auth/screens/splash_screen.dart';
import 'package:quail_order_app/features/cart/bindings/cart_binding.dart';
import 'package:quail_order_app/features/cart/screens/cart_screen.dart';
import 'package:quail_order_app/features/cart/screens/checkout_screen.dart';
import 'package:quail_order_app/features/catalog/bindings/catalog_binding.dart';
import 'package:quail_order_app/features/catalog/screens/home_shell.dart';
import 'package:quail_order_app/features/catalog/screens/product_detail_screen.dart';
import 'package:quail_order_app/features/orders/bindings/orders_binding.dart';
import 'package:quail_order_app/features/orders/screens/order_detail_screen.dart';
import 'package:quail_order_app/features/orders/screens/orders_screen.dart';

class AppRouter {
  AppRouter._();

  static final List<GetPage> pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeShell(),
      bindings: [CatalogBinding(), CartBinding(), OrdersBinding()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailScreen(),
      binding: CatalogBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.cart,
      page: () => const CartScreen(),
      binding: CartBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.checkout,
      page: () => const CheckoutScreen(),
      binding: CartBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.orders,
      page: () => const OrdersScreen(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.orderDetail,
      page: () => const OrderDetailScreen(),
      binding: OrdersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.adminHome,
      page: () => const AdminShell(),
      binding: AdminBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.adminOrders,
      page: () => const AdminOrdersScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.adminOrderDetail,
      page: () => const AdminOrderDetailScreen(),
      binding: AdminBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
