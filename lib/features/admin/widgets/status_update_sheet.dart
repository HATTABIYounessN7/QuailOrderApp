import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/core/theme/app_theme.dart';
import 'package:quail_order_app/features/admin/controllers/admin_controller.dart';

class StatusUpdateSheet extends StatelessWidget {
  final String orderId;
  final String currentStatus;

  const StatusUpdateSheet({
    super.key,
    required this.orderId,
    required this.currentStatus,
  });

  static void show(String orderId, String currentStatus) {
    Get.bottomSheet(
      StatusUpdateSheet(orderId: orderId, currentStatus: currentStatus),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Update Order Status',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Current: ${currentStatus.statusLabel}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          ...OrderStatus.all.map((status) {
            final isCurrent = status == currentStatus;
            final color = status.statusColor;

            return Obx(() {
              final isLoading = AdminController.to.isUpdating.value;

              return GestureDetector(
                onTap: isCurrent || isLoading
                    ? null
                    : () => AdminController.to.updateStatus(orderId, status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? color.withValues(alpha: 0.12)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent ? color : AppColors.divider,
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(status.statusIcon, size: 20, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          status.statusLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isCurrent ? color : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Icon(Icons.check_circle_rounded, size: 18, color: color)
                      else if (isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              );
            });
          }),
        ],
      ),
    );
  }
}
