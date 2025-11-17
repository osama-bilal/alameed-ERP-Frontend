import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/models/core/timestamped.dart';
import 'package:ponit_of_sales/utils/main.dart';

class SalaryPayment extends BaseModel {
  int? id;
  int? employeeId;
  String amount; // decimal as String
  DateTime? paymentDate;
  int paymentMethodId;
  String? notes;
  int? createdById;
  int? updatedById;

  SalaryPayment({
    this.id,
    required this.employeeId,
    required this.amount,
    this.paymentDate,
    required this.paymentMethodId,
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
      'payment_date': DateFormat(
        "yyyy-MM-dd",
      ).format(paymentDate ?? DateTime.now()),
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
  factory SalaryPayment.fromJson(String s) =>
      SalaryPayment.fromMap(json.decode(s));

  Map<String, dynamic> toView(BuildContext ctx) {
    final emp =
        ctx
            .read<AppParties>()
            .employees
            .where((element) => element.id == employeeId)
            .firstOrNull
            ?.name ??
        employeeId;
    final method = ctx
        .read<AppParties>()
        .payMethods
        .where((element) => element.id == paymentMethodId)
        .firstOrNull
        ?.name;
    return {
      'id': id,
      'employee': emp,
      'amount': amount,
      'date': DateFormat(
        "yyyy-MM-dd",
      ).format(paymentDate ?? DateTime.now()),
      'pay_method': method,
      'notes': notes,
    };
  }

  static List<String> get columnsName => [
    'ID',
    'Employee',
    'Amount',
    'Date',
    'Pay Method',
    'Notes',
  ];

  @override
  String toString() =>
      'id: $id, employeeId: $employeeId, amount: $amount, paymentDate: $paymentDate, paymentMethodId: $paymentMethodId, notes: $notes';
}
