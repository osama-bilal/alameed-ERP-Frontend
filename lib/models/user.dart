import 'dart:convert';

class User {
  final int? id;
  final String username;
  final String? password;
  final String? email;
  final String? firstName;
  final String? lastName;
  final List groups; // "admin", "cashier", "manager", "employee", etc.
  final List permissions;
  final bool? isSuper;

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
      'is_superuser': isSuper,
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

  String toJson() => json.encode(toMap());
  factory User.fromJson(String s) => User.fromMap(json.decode(s));

  static List<String> get columnsName => [
        'ID',
        'Username',
        'Email',
        'First Name',
        'Last Name',
        'Groups',
        'Permissions',
        'Is Superuser',
      ];
  @override
  String toString() => "$username, $email, $firstName $lastName, Groups: $groups";
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
