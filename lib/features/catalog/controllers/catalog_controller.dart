import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/data/models/product.dart';
import 'package:quail_order_app/data/repositories/product_repository.dart';

class CatalogController extends GetxController {
  static CatalogController get to => Get.find();

  final RxList<Product> products = <Product>[].obs;
  final RxString selectedCategory = ProductCategory.all.obs;
  final RxString searchQuery = ''.obs;

  void loadProducts() {
    products.value = ProductRepository.instance.getAll();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  void search(String query) {
    searchQuery.value = query.toLowerCase().trim();
  }

  List<Product> get filteredProducts {
    var list = selectedCategory.value == ProductCategory.all
        ? ProductRepository.instance.getAll()
        : ProductRepository.instance.getByCategory(selectedCategory.value);

    if (searchQuery.value.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(searchQuery.value) ||
                p.description.toLowerCase().contains(searchQuery.value),
          )
          .toList();
    }
    return list;
  }

  Product? getById(String id) => ProductRepository.instance.findById(id);
}
