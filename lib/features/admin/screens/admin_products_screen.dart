import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/core/theme/app_theme.dart';
import 'package:quail_order_app/data/models/product.dart';
import 'package:quail_order_app/features/admin/controllers/admin_controller.dart';
import 'package:quail_order_app/features/admin/widgets/product_form_sheet.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AdminController.to;

    return Obx(() {
      if (ctrl.isProductsLoading.value && ctrl.products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          _TableHeader(),
          if (ctrl.products.isEmpty)
            const Expanded(child: _EmptyState())
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: ctrl.loadProducts,
                child: ListView.builder(
                  itemCount: ctrl.products.length,
                  itemBuilder: (_, i) => _ProductRow(product: ctrl.products[i]),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          SizedBox(width: 48),
          Expanded(
            flex: 4,
            child: Text(
              'PRODUCT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'PRICE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'STOCK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(width: 76),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 40,
              child: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppColors.surfaceVariant),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 18,
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),

          // Name + category + unit
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _CategoryChip(product.category),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        product.unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Price
          Expanded(
            flex: 2,
            child: Text(
              '${product.price.toStringAsFixed(2)} MAD',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),

          // Stock
          Expanded(
            flex: 2,
            child: _StockBadge(product),
          ),

          // Actions
          SizedBox(
            width: 96,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionIcon(
                  icon: Icons.edit_outlined,
                  color: AppColors.primary,
                  onTap: () => ProductFormSheet.show(product),
                ),
                _ActionIcon(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.cancelled,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete "${product.name}"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              AdminController.to.deleteProduct(product.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.cancelled),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip(this.category);

  @override
  Widget build(BuildContext context) {
    final isEgg = category == 'eggs';
    final color = isEgg ? AppColors.accent : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isEgg ? 'Eggs' : 'Quail',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final Product product;
  const _StockBadge(this.product);

  @override
  Widget build(BuildContext context) {
    final color = product.inStock ? AppColors.delivered : AppColors.cancelled;
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '${product.stockCount}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18, color: color),
      onPressed: onTap,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'No products yet',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          SizedBox(height: 6),
          Text(
            'Tap + Add Product to get started',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
