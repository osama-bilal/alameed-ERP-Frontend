import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/controllers/provider/parties.dart';
import '/models/core/timestamped.dart';

class Expense extends BaseModel {
  int? id;
  int shiftId;
  int? recordedById;
  String? reason; // office/refund/withdrawal/other
  int? paymentMethodId;
  int? takenByEmployeeId;
  String amount; // decimal string
  String? notes;

  Expense({
    this.id,
    required this.shiftId,
    this.recordedById,
    this.reason,
    this.paymentMethodId,
    this.takenByEmployeeId,
    required this.amount,
    this.notes,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'id': id,
      'shift': shiftId,
      'recorded_by': recordedById,
      'reason': reason,
      'payment_method': paymentMethodId,
      'taken_by': takenByEmployeeId,
      'amount': amount,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    final e = Expense(
      id: map['id'],
      shiftId: map['shift'],
      recordedById: map['recorded_by'],
      reason: map['reason'],
      paymentMethodId: map['payment_method'],
      takenByEmployeeId: map['taken_by'],
      amount: map['amount']?.toString() ?? '0.00',
      notes: map['notes'],
    );
    e.baseFromMap(map);
    return e;
  }

  String toJson() => json.encode(toMap());
  factory Expense.fromJson(String s) => Expense.fromMap(json.decode(s));

  Map<String, dynamic> toView(BuildContext ctx) {
    final emp = ctx
        .read<AppParties>()
        .employees
        .where((element) => element.id == takenByEmployeeId)
        .firstOrNull
        ?.name;
    final user = ctx
        .read<AppParties>()
        .users
        .where((element) => element.id == recordedById)
        .firstOrNull
        ?.name;

    final method = ctx
        .read<AppParties>()
        .payMethods
        .where((element) => element.id == paymentMethodId)
        .firstOrNull
        ?.name;
    return {
      'id': id,
      'amount': amount,
      'taken_by': emp,
      'pay_method': method,
      'recorded_by': user,
      'reason': reason,
      'shift': shiftId,
      'notes': notes,
    };
  }

  static List<String> get columnsName => [
    'ID',
    'Amount',
    'Taken By',
    'Pay Method',
    'Recorded By',
    'Reason',
    'Shift',
    'Notes',
  ];

  @override
  String toString() =>
      "$recordedById, $reason, $paymentMethodId, taken by: $takenByEmployeeId, $amount";
}
