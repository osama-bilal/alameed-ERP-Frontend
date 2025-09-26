import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';

class OptionsType extends BaseModel {
  int? id;
  String name;
  int categoryId; // FK to Category (default 4 in Django but keep as int)

  OptionsType({
    this.id,
    required this.name,
    required this.categoryId,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    ...baseToMap(),
    'id': id,
    'name': name,
    'category': categoryId,
  };

  factory OptionsType.fromMap(Map<String, dynamic> map) {
    final o = OptionsType(
      id: map['id'],
      name: map['name'],
      categoryId: map['category'] ?? 4,
    );
    o.baseFromMap(map);
    return o;
  }

  String toJson() => json.encode(toMap());
  factory OptionsType.fromJson(String s) => OptionsType.fromMap(json.decode(s));

  static List<String> get culomnsName => [
    "ID",
    "Name",
    "Category",
  ];

  @override
  String toString() => name;
}

class OptionsValue extends BaseModel {
  int? id;
  String name;
  int typeId; // FK to OptionsType

  OptionsValue({
    this.id,
    required this.name,
    required this.typeId,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    ...baseToMap(),
    'id': id,
    'name': name,
    'type': typeId,
  };

  factory OptionsValue.fromMap(Map<String, dynamic> map) {
    final v = OptionsValue(
      id: map['id'],
      name: map['name'],
      typeId: map['type'],
    );
    v.baseFromMap(map);
    return v;
  }

  String toJson() => json.encode(toMap());
  factory OptionsValue.fromJson(String s) =>
      OptionsValue.fromMap(json.decode(s));
  static List<String> get culomnsName => [
    "ID",
    "Name",
    "Type",
  ];

  @override
  String toString() => name;
}
