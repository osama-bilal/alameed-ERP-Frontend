import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';
import 'package:ponit_of_sales/utils/main.dart';

class SalaryPayment extends BaseModel {
  int? id;
  int employeeId;
  String amount; // decimal as String
  DateTime? paymentDate;
  int? paymentMethodId;
  String? notes;
  int? createdById;
  int? updatedById;

  SalaryPayment({
    this.id,
    required this.employeeId,
    required this.amount,
    this.paymentDate,
    this.paymentMethodId,
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
      'amount': amount,
      'payment_date': dateTimeToIso(paymentDate),
      'payment_method': paymentMethodId,
      'notes': notes,
      'created_by': createdById,
      'updated_by': updatedById,
    };
  }

  factory SalaryPayment.fromMap(Map<String, dynamic> map) {
    final s = SalaryPayment(
      id: map['id'],
      employeeId: map['employee'],
      amount: map['amount']?.toString() ?? '0.00',
      paymentDate: parseDateTime(map['payment_date']),
      paymentMethodId: map['payment_method'],
      notes: map['notes'],
      createdById: map['created_by'],
      updatedById: map['updated_by'],
    );
    s.baseFromMap(map);
    return s;
  }

  String toJson() => json.encode(toMap());
  factory SalaryPayment.fromJson(String s) => SalaryPayment.fromMap(json.decode(s));

  static List<String> get columnsName => [
        'ID',
        'Employee ID',
        'Amount',
        'Payment Date',
        'Payment Method ID',
        'Notes',
      ];

  @override
  String toString() => 'id: $id, employeeId: $employeeId, amount: $amount, paymentDate: $paymentDate, paymentMethodId: $paymentMethodId, notes: $notes';
}