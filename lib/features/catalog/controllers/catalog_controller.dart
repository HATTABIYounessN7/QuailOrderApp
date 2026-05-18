import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/data/models/product.dart';
import 'package:quail_order_app/data/repositories/product_repository.dart';

class CatalogController extends GetxController {
  static CatalogController get to => Get.find();

  final RxList<Product> products = <Product>[].obs;
  final RxString selectedCategory = ProductCategory.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final all = await ProductRepository.instance.getAll();
      products.value = all;
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  void search(String query) {
    searchQuery.value = query.toLowerCase().trim();
  }

  List<Product> get filteredProducts {
    // isLoading + selectedCategory + searchQuery are the reactive triggers;
    // when they change Obx rebuilds and we read products as a plain List.
    final all = List<Product>.from(products);
    var list = selectedCategory.value == ProductCategory.all
        ? all
        : all.where((p) => p.category == selectedCategory.value).toList();

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

  Product? getById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
