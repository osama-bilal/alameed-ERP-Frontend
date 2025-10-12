import 'dart:convert';

class ViewParty<T> {
  final int id;
  final String name;
  ViewParty({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'ID': id, 'representation': name};
  }

  factory ViewParty.fromJson(String j) =>
      ViewParty.fromMap(json.decode(j));

  factory ViewParty.fromMap(Map<String, dynamic> map) {
    return ViewParty(id: map['id'] ?? 0, name: map['representation'] ?? '');
  }

  String toJson() => json.encode(toMap());

  static List<String> get columnsName => ['ID', 'Representation'];
  @override
  String toString() => name;
}
