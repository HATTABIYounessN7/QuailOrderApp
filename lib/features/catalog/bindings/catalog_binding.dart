import 'package:get/get.dart';
import 'package:quail_order_app/features/catalog/controllers/catalog_controller.dart';

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CatalogController(), fenix: true);
  }
}
