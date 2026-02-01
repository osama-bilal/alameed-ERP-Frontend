import 'dart:convert';

import '/models/core/timestamped.dart';

class Supplier extends BaseModel {
  int? id;
  String name;
  String phone;
  String? email;
  String address;

  Supplier({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    ...baseToMap(),
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
  };

  factory Supplier.fromMap(Map<String, dynamic> map) {
    final s = Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'] ?? '',
    );
    s.baseFromMap(map);
    return s;
  }

  String toJson() => json.encode(toMap());
  factory Supplier.fromJson(String s) => Supplier.fromMap(json.decode(s));

  static List<String> get columnsName => [
    'ID',
    'Name',
    'Phone',
    'Email',
    'Address',
  ];

  @override
  String toString() => "$name, $phone, $email, $address ";
}
