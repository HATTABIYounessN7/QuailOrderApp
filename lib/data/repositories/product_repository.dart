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

  Future<Product> create(Product product) async {
    final data = await ApiClient.instance.post('/products', product.toJson());
    return Product.fromJson(data as Map<String, dynamic>);
  }

  Future<Product> update(Product product) async {
    final data = await ApiClient.instance.put('/products/${product.id}', product.toJson());
    return Product.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await ApiClient.instance.delete('/products/$id');
  }
}
