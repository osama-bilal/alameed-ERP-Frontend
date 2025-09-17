
import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';

class Category extends BaseModel {
  int? id;
  String name;
  String description;

  Category({
    this.id,
    required this.name,
    required this.description,
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

  factory Category.fromMap(Map<String, dynamic> map) {
    final c = Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
    c.baseFromMap(map);
    return c;
  }

  String toJson() => json.encode(toMap());
  factory Category.fromJson(String s) => Category.fromMap(json.decode(s));
}