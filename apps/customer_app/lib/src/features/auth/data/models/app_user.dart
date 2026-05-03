enum AppUserRole {
  customer,
  admin,
  driver,
}

class AppUser {
  const AppUser({
    required this.id,
    required this.role,
    this.name,
    this.email,
    this.phone,
  });

  final String id;
  final AppUserRole role;
  final String? name;
  final String? email;
  final String? phone;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      role: _roleFromString(json['role'] as String?),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  static AppUserRole _roleFromString(String? role) {
    switch (role) {
      case 'ADMIN':
        return AppUserRole.admin;
      case 'DRIVER':
        return AppUserRole.driver;
      case 'CUSTOMER':
      default:
        return AppUserRole.customer;
    }
  }
}
