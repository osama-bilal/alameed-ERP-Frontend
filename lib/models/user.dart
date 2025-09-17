class User {
  final int? id;
  final String username;
  final String? password;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? role; // "admin", "cashier", "manager", "employee", etc.
  final List<String> permissions;
  final bool isActive;

  User({
    this.id,
    required this.username,
    this.password,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.role,
    this.permissions = const [],
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'groups': [role],
      'permissions': permissions,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      phone: map['phone'],
      role: map['groups'][0][1],
      permissions: map['permissions'],
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
  }
}


enum UserRole { admin, manager, cashier, employee }

class PermissionManager {
  static bool canViewReports(UserRole role) {
    return role == UserRole.admin || role == UserRole.manager;
  }

  static bool canManageEmployees(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canCreateInvoice(UserRole role) {
    return role == UserRole.admin || role == UserRole.cashier;
  }
}
