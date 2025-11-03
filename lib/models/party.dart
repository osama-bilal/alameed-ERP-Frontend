import 'dart:convert';

// import 'package:flutter/foundation.dart';

class ViewParty<T> {
  final Type type;
  final int id;
  final String name;
  ViewParty({required this.id, required this.name}): type = T;

  Map<String, dynamic> toMap() {
    return {'ID': id, 'representation': name};
  }

  factory ViewParty.fromJson(String j) =>
      ViewParty.fromMap(json.decode(j));

  factory ViewParty.fromMap(Map<String, dynamic> map) {
    return ViewParty<T>(id: map['id'] ?? 0, name: map['representation'] ?? '');
  }

  String toJson() => json.encode(toMap());

  static List<String> get columnsName => ['ID', 'Representation'];
  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ViewParty<T> && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
