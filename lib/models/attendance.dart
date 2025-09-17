
import 'dart:convert';

import 'package:ponit_of_sales/models/core/owned.dart';
import 'package:ponit_of_sales/models/core/timestamped.dart';
class Attendance extends BaseModel with OwnedFields {
  int? id;
  int employeeId;
  DateTime date;
  bool isPresent;
  int workHours;
  int lateMinutes;
  String? notes;
  // Owned fields included via explicit fields:
  @override
  // ignore: overridden_fields
  int? createdById;
  @override
  // ignore: overridden_fields
  int? updatedById;

  Attendance({
    this.id,
    required this.employeeId,
    required this.date,
    required this.isPresent,
    required this.workHours,
    required this.lateMinutes,
    this.notes,
    this.createdById,
    this.updatedById,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'id': id,
      'employee': employeeId,
      'date': date.toIso8601String(),
      'is_present': isPresent ? 1 : 0,
      'work_hours': workHours,
      'late_minutes': lateMinutes,
      'notes': notes,
      'created_by': createdById,
      'updated_by': updatedById,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    final a = Attendance(
      id: map['id'],
      employeeId: map['employee'],
      date: DateTime.parse(map['date']),
      isPresent: map['is_present'] == 1 || map['is_present'] == true,
      workHours: map['work_hours'] ?? 0,
      lateMinutes: map['late_minutes'] ?? 0,
      notes: map['notes'],
      createdById: map['created_by'],
      updatedById: map['updated_by'],
    );
    a.baseFromMap(map);
    return a;
  }

  String toJson() => json.encode(toMap());
  factory Attendance.fromJson(String s) => Attendance.fromMap(json.decode(s));
}