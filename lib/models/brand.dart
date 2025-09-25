

import 'dart:convert';

class Brand {
  int? id;
  String name;

  Brand({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Brand.fromMap(Map<String, dynamic> map) =>
      Brand(id: map['id'], name: map['name']);
  String toJson() => json.encode(toMap());
  factory Brand.fromJson(String s) => Brand.fromMap(json.decode(s));

static List<String> get columnsName => [
        'id',
        'name',
      ];
  @override
  String toString() => name;
}