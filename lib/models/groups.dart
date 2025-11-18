class Groups {
  int id;
  String name;
  List<int> permissions;
  Groups({required this.id, required this.name, required this.permissions});

  factory Groups.fromJson(Map<String, dynamic> json) {
    final perms = json["permissions"] as List?;
    return Groups(
      id: json["id"],
      name: json["name"] as String? ?? '',
      permissions: perms != null ? List<int>.from(perms) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'permissions': permissions};
  }
}

class Permissions {
  int id;
  String name;
  String codename;
  ContentType content_type;

  Permissions({
    required this.id,
    required this.name,
    required this.codename,
    required this.content_type,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      id: json['id'],
      name: json['name'],
      codename: json['codename'],
      content_type: ContentType.fromJson(json['content_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'codename': codename,
      'content_type': content_type.toJson(),
    };
  }
}

class ContentType {
  String appLabel;
  String model;

  ContentType({required this.appLabel, required this.model});

  factory ContentType.fromJson(Map<String, dynamic> json) {
    return ContentType(appLabel: json['app_label'], model: json['model']);
  }

  Map<String, dynamic> toJson() {
    return {'app_label': appLabel, 'model': model};
  }
}
