import 'dart:convert';

class User {
  final int? id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final List<String> groups; // "admin", "cashier", "manager", "employee", etc.
  final List<String> permissions;
  final bool isAdmin;
  final bool isActive;
  final String _pass;
  User({
    this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.groups = const [],
    this.permissions = const [],
    this.isAdmin = false,
    required this.isActive,
    String pass = "",
  }): _pass=pass;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'groups': groups,
      'user_permissions': permissions,
      'is_admin': isAdmin,
      'is_active': isActive,
      if(_pass.isNotEmpty) 'password': _pass,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      groups: List<String>.from(map['groups'] ?? []),
      permissions: List<String>.from(map['user_permissions'] ?? []),
      isAdmin: map['is_admin'] == 1 || map['is_admin'] == true,
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
  }

  String toJson() => json.encode(toMap());
  factory User.fromJson(String s) => User.fromMap(json.decode(s));

  static List<String> get columnsName => [
    'ID',
    'Username',
    'Email',
    'First Name',
    'Last Name',
    'Groups',
    // 'Permissions',
    'Is Admin',
    'Is Active',
  ];
  @override
  String toString() =>
      "$username, $email, $firstName $lastName";
}

enum UserRole { admin, manager, cashier, employee }

class PermissionManager {
  static bool canView(UserRole role) {
    return role == UserRole.admin || role == UserRole.manager;
  }

  static bool canAdd() {
    return true;
  }

  static bool canEdit() {
    return true;
  }

  static bool canDelete() {
    return true;
  }

  static bool canManageEmployees(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canCreateInvoice(UserRole role) {
    return role == UserRole.admin || role == UserRole.cashier;
  }
}
