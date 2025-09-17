

import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';

class Employee extends BaseModel {
  int? id;
  String firstName;
  String lastName;
  DateTime birthDate;
  String email;
  String position;
  String salary; // decimal as String
  DateTime hireDate;
  int? userAccountId; // FK to User

  Employee({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.position,
    required this.salary,
    required this.hireDate,
    this.userAccountId,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate.toIso8601String(),
      'email': email,
      'position': position,
      'salary': salary,
      'hire_date': hireDate.toIso8601String(),
      'useraccount': userAccountId,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    final e = Employee(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      birthDate: DateTime.parse(map['birth_date']),
      email: map['email'],
      position: map['position'],
      salary: map['salary']?.toString() ?? '0.00',
      hireDate: DateTime.parse(map['hire_date']),
      userAccountId: map['useraccount'],
    );
    e.baseFromMap(map);
    return e;
  }

  String toJson() => json.encode(toMap());
  factory Employee.fromJson(String s) => Employee.fromMap(json.decode(s));
}