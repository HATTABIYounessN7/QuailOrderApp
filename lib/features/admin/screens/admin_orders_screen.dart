import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/core/theme/app_theme.dart';
import 'package:quail_order_app/features/admin/controllers/admin_controller.dart';
import 'package:quail_order_app/features/orders/widgets/order_card.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AdminController.to;
    final filters = ['all', ...OrderStatus.all];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'All Orders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = filters[i];
                  return Obx(() {
                    final selected = controller.filterStatus.value == f;
                    final color = f == 'all'
                        ? AppColors.primary
                        : f.statusColor;

                    return GestureDetector(
                      onTap: () => controller.applyFilter(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? color : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          f == 'all' ? 'All' : f.statusLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
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
                        onTap: () => Get.toNamed(Routes.adminOrder(order.id)),
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
