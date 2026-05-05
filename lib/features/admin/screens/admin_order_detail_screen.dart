import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quail_order_app/core/theme/app_theme.dart';
import 'package:quail_order_app/data/models/order.dart';
import 'package:quail_order_app/features/admin/controllers/admin_controller.dart';
import 'package:quail_order_app/features/admin/widgets/status_update_sheet.dart';
import 'package:quail_order_app/features/orders/widgets/order_status_timeline.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  const AdminOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String id = Get.parameters['id'] ?? '';
    final Order? order = AdminController.to.findById(id);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 6).toUpperCase()}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Customer'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Name',
                  value: order.customerName,
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: order.phone,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Delivery address',
                  value: order.deliveryAddress,
                ),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Placed on',
                  value: DateFormat(
                    'dd MMM yyyy, HH:mm',
                  ).format(order.placedAt),
                ),
              ],
            ),

            const SizedBox(height: 28),

            _SectionTitle('Delivery Status'),
            const SizedBox(height: 12),
            Obx(() {
              final fresh = AdminController.to.findById(id);
              return OrderStatusTimeline(
                currentStatus: fresh?.status ?? order.status,
              );
            }),

            const SizedBox(height: 28),
            _SectionTitle('Items'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${item.unit}  x${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.subtotal.toStringAsFixed(2)} MAD',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)} MAD',
                      style: AppTextStyles.price,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => StatusUpdateSheet.show(
                  order.id,
                  AdminController.to.findById(id)?.status ?? order.status,
                ),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Update Status'),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
