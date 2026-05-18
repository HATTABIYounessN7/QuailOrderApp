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

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] as String,
    name: j['name'] as String,
    email: j['email'] as String,
    password: (j['password'] as String?) ?? '',
    role: j['role'] == 'admin' ? UserRole.admin : UserRole.customer,
    phone: j['phone'] as String,
    address: j['address'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'role': role == UserRole.admin ? 'admin' : 'customer',
    'phone': phone,
    'address': address,
  };
}
