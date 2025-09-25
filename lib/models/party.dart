class ViewParty {
  final int id;
  final String name;
  final String type;
  ViewParty(this.type, {required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'representation': name,
      'Type': type,
    };
  }

  factory ViewParty.fromJson(Map<String, dynamic> json) {
    return ViewParty(
      json['type'] ?? '',
      id: json['id'] ?? 0,
      name: json['representation'] ?? '',
    );
  }
  factory ViewParty.fromMap(Map<String, dynamic> map) {
    return ViewParty(
      map['type'] ?? '',
      id: map['id'] ?? 0,
      name: map['representation'] ?? '',
    );
  }

  static List<String> get columnsName => [
        'ID',
        'Representation',
        'Type',
      ];
  @override
  String toString() => name;
}
