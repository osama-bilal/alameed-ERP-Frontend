import 'package:ponit_of_sales/utils/main.dart';

class BaseModel {
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  BaseModel({this.createdAt, this.updatedAt, this.deletedAt});

  Map<String, dynamic> baseToMap() {
    return {
      if (createdAt != null) 'created_at': dateTimeToIso(createdAt),
      if (deletedAt != null) 'updated_at': dateTimeToIso(updatedAt),
    };
  }

  void baseFromMap(Map<String, dynamic> map) {
    createdAt = parseDateTime(map['created_at']);
    updatedAt = parseDateTime(map['updated_at']);
    deletedAt = parseDateTime(map['deleted_at']);
  }
}
