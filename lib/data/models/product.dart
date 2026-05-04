import 'package:quail_order_app/core/constants/app_constants.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool inStock;
  final int stockCount;
  final String unit; // e.g. "per bird", "per dozen", "per tray (30)"

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.inStock,
    required this.stockCount,
    required this.unit,
  });

  bool get isEgg => category == ProductCategory.eggs;
  bool get isQuail => category == ProductCategory.quail;
}
