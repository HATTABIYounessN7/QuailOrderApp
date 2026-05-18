import 'package:quail_order_app/data/models/app_user.dart';
import 'package:quail_order_app/services/api_client.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  Future<AppUser?> login(String email, String password) async {
    try {
      final data = await ApiClient.instance.post('/auth/login', {
        'email': email,
        'password': password,
      });
      return AppUser.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
