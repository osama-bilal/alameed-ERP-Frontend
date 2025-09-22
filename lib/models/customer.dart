import 'dart:convert';

import 'core/timestamped.dart' show BaseModel;

class Customer extends BaseModel {
  int? id;
  String name;
  String phone;
  String? email;
  String? address;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
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

  factory Customer.fromMap(Map<String, dynamic> map) {
    final c = Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'],
    );
    c.baseFromMap(map);
    return c;
  }

  String toJson() => json.encode(toMap());
  factory Customer.fromJson(String s) => Customer.fromMap(json.decode(s));

  static List<String> get columnNames => ['ID', 'Name', 'Phone', 'Email', 'Address'];
}
