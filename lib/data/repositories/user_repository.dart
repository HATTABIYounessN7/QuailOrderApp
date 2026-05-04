import 'package:quail_order_app/data/models/app_user.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final List<AppUser> _users = const [
    AppUser(
      id: 'admin1',
      name: 'Admin',
      email: 'admin@test.com',
      password: '1234',
      role: UserRole.admin,
      phone: '+212600000000',
      address: 'Quail Store, City1',
    ),
    AppUser(
      id: 'user1',
      name: 'Youssef Nazih',
      email: 'youssef.nazih@test.com',
      password: '1234',
      role: UserRole.customer,
      phone: '+212611111111',
      address: '123 Rue1, City1',
    ),
    AppUser(
      id: 'user2',
      name: 'Youssef Rahioui',
      email: 'youssef.rahioui@test.com',
      password: '1234',
      role: UserRole.customer,
      phone: '+212622222222',
      address: '123 Rue1, City2',
    ),
  ];

  AppUser? login(String email, String password) {
    try {
      return _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  AppUser? findById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}
