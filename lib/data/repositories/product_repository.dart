import 'package:quail_order_app/data/models/product.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';

class ProductRepository {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();

  final List<Product> _products = const [
    Product(
      id: 'q_001',
      name: 'Live Japanese Quail',
      description:
          'Healthy, farm-raised Japanese quail (Coturnix coturnix japonica). '
          'Ready for laying or meat production. Vaccinated and well-fed.',
      price: 35.00,
      category: ProductCategory.quail,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/8/8d/Coturnix_coturnix_%28Lmbuga%29_%28cropped%29.jpg?_=20180905162423',
      inStock: true,
      stockCount: 40,
      unit: 'per bird',
    ),
    Product(
      id: 'q_002',
      name: 'Laying Quail Hen',
      description:
          'Female quail selected for high egg production. '
          'Approx. 280-200 eggs per year. Age: 6-8 weeks.',
      price: 50.00,
      category: ProductCategory.quail,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/8/8d/Coturnix_coturnix_%28Lmbuga%29_%28cropped%29.jpg?_=20180905162423',
      inStock: true,
      stockCount: 20,
      unit: 'per bird',
    ),
    Product(
      id: 'q_003',
      name: 'Quail Pair (1M + 1F)',
      description:
          'One male and one female Japanese quail. '
          'Perfect for starting your own small flock.',
      price: 90.00,
      category: ProductCategory.quail,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/8/8d/Coturnix_coturnix_%28Lmbuga%29_%28cropped%29.jpg?_=20180905162423',
      inStock: true,
      stockCount: 10,
      unit: 'per pair',
    ),
    Product(
      id: 'e_001',
      name: 'Fresh Quail Eggs — Dozen',
      description:
          'Farm-fresh quail eggs, collected daily. '
          'Rich in protein and vitamins. Perfect for cooking or snacking.',
      price: 12.00,
      category: ProductCategory.eggs,
      imageUrl:
          'https://images.unsplash.com/photo-1645218167737-7e9c23137641?w=400&auto=format&fm=png',
      inStock: true,
      stockCount: 200,
      unit: 'per dozen (12)',
    ),
    Product(
      id: 'e_002',
      name: 'Fresh Quail Eggs — Tray',
      description:
          'Economy tray of 30 fresh quail eggs. '
          'Best value for families and small restaurants.',
      price: 28.00,
      category: ProductCategory.eggs,
      imageUrl:
          'https://images.unsplash.com/photo-1645218167737-7e9c23137641?w=400&auto=format&fm=png',
      inStock: true,
      stockCount: 150,
      unit: 'per tray (30)',
    ),
    Product(
      id: 'e_003',
      name: 'Hatching Eggs — Dozen',
      description:
          'Fertilised quail eggs ready for incubation. '
          'High hatch rate (~85%). Stored and handled with care.',
      price: 20.00,
      category: ProductCategory.eggs,
      imageUrl:
          'https://images.unsplash.com/photo-1645218167737-7e9c23137641?w=400&auto=format&fm=png',
      inStock: false,
      stockCount: 0,
      unit: 'per dozen (12)',
    ),
  ];

  List<Product> getAll() => List.unmodifiable(_products);

  List<Product> getByCategory(String category) {
    if (category == ProductCategory.all) return getAll();
    return _products.where((p) => p.category == category).toList();
  }

  Product? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
