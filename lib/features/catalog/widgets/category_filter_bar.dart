import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/core/theme/app_theme.dart';
import 'package:quail_order_app/features/catalog/controllers/catalog_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CatalogController.to;

    final List<({Widget icon, String id, String label})> categories = [
      (
        id: ProductCategory.all,
        label: 'All',
        icon: Icon(Icons.grid_view_rounded),
      ),
      (
        id: ProductCategory.quail,
        label: 'Quails',
        icon: const FaIcon(FontAwesomeIcons.drumstickBite),
      ),
      (id: ProductCategory.eggs, label: 'Eggs', icon: Icon(Icons.egg_outlined)),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          return Obx(() {
            final selected = controller.selectedCategory.value == cat.id;

            return GestureDetector(
              onTap: () => controller.filterByCategory(cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        size: 16,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      child: cat.icon,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
