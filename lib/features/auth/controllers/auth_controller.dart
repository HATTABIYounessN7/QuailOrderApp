import 'package:get/get.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';
import 'package:quail_order_app/data/models/app_user.dart';
import 'package:quail_order_app/data/repositories/order_repository.dart';
import 'package:quail_order_app/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);

  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => currentUser.value?.role == UserRole.admin;
  bool get isCustomer => currentUser.value?.role == UserRole.customer;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(PrefKeys.userId);

    if (userId != null) {
      final user = UserRepository.instance.findById(userId);
      if (user != null) {
        currentUser.value = user;
        await OrderRepository.instance.load();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    final user = UserRepository.instance.login(
      email.trim().toLowerCase(),
      password.trim(),
    );
    if (user == null) return false;

    currentUser.value = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys.userId, user.id);
    await prefs.setString(PrefKeys.userRole, user.role.name);

    await OrderRepository.instance.load();
    return true;
  }

  Future<void> logout() async {
    currentUser.value = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefKeys.userId);
    await prefs.remove(PrefKeys.userRole);

    Get.offAllNamed(Routes.login);
  }
}
