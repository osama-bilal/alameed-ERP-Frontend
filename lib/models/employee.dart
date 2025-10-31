import 'dart:convert';

import 'package:intl/intl.dart';
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
      'birth_date': DateFormat("yyyy-MM-dd").format(birthDate),
      'email': email,
      'position': position,
      'salary': salary,
      'hire_date': DateFormat("yyyy-MM-dd").format(hireDate),
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
  static List<String> get columnsName => [
    'ID',
    'First Name',
    'Last Name',
    'Birth Date',
    'Email',
    'Position',
    'Salary',
    'Hire Date',
  ];
  String toJson() => json.encode(toMap());
  factory Employee.fromJson(String s) => Employee.fromMap(json.decode(s));

  @override
  String toString() => "$id, $firstName $lastName, $position, salary: $salary";
}
