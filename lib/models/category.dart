import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';

class ProductCategory extends BaseModel {
  int? id;
  String name;
  String? description;

  ProductCategory({
    this.id,
    required this.name,
    this.description,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    ...baseToMap(),
    'id': id,
    'name': name,
    'description': description,
  };

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    final c = ProductCategory(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
    c.baseFromMap(map);
    return c;
  }

  String toJson() => json.encode(toMap());
  factory ProductCategory.fromJson(String s) =>
      ProductCategory.fromMap(json.decode(s));

  static List<String> get columnsName => ['ID', 'Name', 'Description'];

  @override
  String toString() => name;
}
