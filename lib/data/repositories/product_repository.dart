import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/data/models/product.dart';
import 'package:quail_order_app/services/api_client.dart';

class ProductRepository {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();

  Future<List<Product>> getAll({String category = ProductCategory.all}) async {
    final params = (category != ProductCategory.all) ? {'category': category} : null;
    final data = await ApiClient.instance.get('/products', params: params) as List;
    return data.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Product?> findById(String id) async {
    try {
      final data = await ApiClient.instance.get('/products/$id');
      return Product.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
