class User {
  final int? id;
  final String username;
  final String? password;
  final String? email;
  final String? firstName;
  final String? lastName;
  final List<String> groups; // "admin", "cashier", "manager", "employee", etc.
  final List<String> permissions;
  final bool isSuper;

  User({
    this.id,
    required this.username,
    this.password,
    this.email,
    this.firstName,
    this.lastName,
    this.groups = const [],
    this.permissions = const [],
    this.isSuper = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'groups': groups,
      'permissions': permissions,
      'is_active': isSuper ? 1 : 0,
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
      groups: map['groups'],
      permissions: map['permissions'],
      isSuper: map['is_superuser'],
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
