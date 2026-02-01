import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '/controllers/provider/parties.dart';
import '/models/core/timestamped.dart';
import '/utils/main.dart';
import 'package:provider/provider.dart';

class Attendance extends BaseModel {
  int? id;
  int employeeId;
  DateTime date;
  bool isPresent;
  int workHours;
  int lateMinutes;
  String? notes;
  int? createdById;
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
      'date': DateFormat("yyyy-MM-dd").format(date),
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
      workHours: map['work_hours'],
      lateMinutes: map['late_minutes'],
      notes: map['notes'],
      createdById: map['created_by'],
      updatedById: map['updated_by'],
    );
    a.baseFromMap(map);
    return a;
  }

  String toJson() => json.encode(toMap());
  factory Attendance.fromJson(String s) => Attendance.fromMap(json.decode(s));

  Map<String, dynamic> toView(BuildContext ctx) {
    final emp = ctx
        .read<AppParties>()
        .employees
        .where((element) => element.id == employeeId)
        .firstOrNull
        ?.name;
    return {
      'id': id,
      'employee': emp,
      'date': DateFormat("yyyy-MM-dd").format(date),
      'is_present': isPresent ? 1 : 0,
      'work_hours': workHours,
      'late_minutes': lateMinutes,
      'notes': notes,
    };
  }

  static List<String> get columnsName => [
    'ID',
    'Employee',
    'Date',
    'Is Present',
    'Work Hours',
    'Late Minutes',
    'Notes',
  ];

  @override
  String toString() {
    return 'employeeId: $employeeId, date: ${dateTimeToIso(date)}, isPresent: ${isPresent ? "Yes" : "No"}, workHours: $workHours, lateMinutes: $lateMinutes, notes: $notes';
  }
}
