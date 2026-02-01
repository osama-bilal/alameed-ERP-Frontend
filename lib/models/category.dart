import 'dart:convert';

import '/models/core/timestamped.dart';

class ProductCategory extends BaseModel {
  int? id;
  String name;

  ProductCategory({
    this.id,
    required this.name,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() => {...baseToMap(), 'id': id, 'name': name};

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    final c = ProductCategory(id: map['id'], name: map['name']);
    c.baseFromMap(map);
    return c;
  }

  String toJson() => json.encode(toMap());
  factory ProductCategory.fromJson(String s) =>
      ProductCategory.fromMap(json.decode(s));

  static List<String> get columnsName => ['ID', 'Name'];

  @override
  String toString() => name;
}
