import 'package:flutter/material.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/core/theme/app_theme.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String currentStatus;

  const OrderStatusTimeline({super.key, required this.currentStatus});

  static const List<String> _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.inRoute,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus == OrderStatus.cancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cancelled.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cancelled.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: AppColors.cancelled,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'This order has been cancelled.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.cancelled,
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _steps.indexOf(currentStatus);

    return Column(
      children: List.generate(_steps.length, (i) {
        final isDone = i <= currentIndex;
        final isActive = i == currentIndex;
        final isLast = i == _steps.length - 1;
        final stepColor = isDone ? AppColors.primary : AppColors.divider;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.primary : AppColors.surface,
                        border: Border.all(color: stepColor, width: 2),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: i < currentIndex
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _steps[i].statusLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isDone
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                    if (isActive)
                      const Text(
                        'Current status',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
