import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/core/theme/app_theme.dart';
import 'package:quail_order_app/features/orders/controllers/orders_controller.dart';
import 'package:quail_order_app/features/orders/widgets/order_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OrdersController.to;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                controller.loadOrders();

                if (controller.orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your placed orders will appear here',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => controller.loadOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.orders.length,
                    itemBuilder: (_, i) {
                      final order = controller.orders[i];
                      return OrderCard(
                        order: order,
                        onTap: () => Get.toNamed(Routes.order(order.id)),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
