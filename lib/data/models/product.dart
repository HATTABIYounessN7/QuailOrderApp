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

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] as String,
    name: j['name'] as String,
    description: j['description'] as String,
    price: (j['price'] as num).toDouble(),
    category: j['category'] as String,
    imageUrl: j['imageUrl'] as String,
    inStock: j['inStock'] as bool,
    stockCount: j['stockCount'] as int,
    unit: j['unit'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'imageUrl': imageUrl,
    'inStock': inStock,
    'stockCount': stockCount,
    'unit': unit,
  };
}
