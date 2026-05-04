enum UserRole { customer, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String phone;
  final String address;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
    required this.address,
  });
}
