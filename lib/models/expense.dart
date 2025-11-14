import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/models/core/timestamped.dart';
import 'package:ponit_of_sales/models/party.dart';

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
        .firstWhere(
          (element) => element.id == takenByEmployeeId,
          orElse: () =>
              ViewParty(id: takenByEmployeeId ?? 0, name: "$takenByEmployeeId"),
        )
        .name;
    final user = ctx
        .read<AppParties>()
        .users
        .firstWhere(
          (element) => element.id == recordedById,
          orElse: () => ViewParty(id: recordedById ?? 0, name: "$recordedById"),
        )
        .name;

    final method = ctx
        .read<AppParties>()
        .payMethods
        .firstWhere(
          (element) => element.id == paymentMethodId,
          orElse: () =>
              ViewParty(id: paymentMethodId ?? 0, name: "$paymentMethodId"),
        )
        .name;
    return {
      'id': id,
      'amount': amount,
      'payment_method': method,
      'deposited_from': emp,
      'reason': reason,
      'shift': shiftId,
      'recorded_by': user,
      'notes': notes,
    };
  }

  static List<String> get columnsName => [
    'ID',
    'Amount',
    'Payment Method',
    'Deposited From',
    'Reason',
    'Shift',
    'Recorded By'
        'Notes',
  ];

  @override
  String toString() =>
      "$id, Shift: $shiftId, recorded by: $recordedById, reason: $reason, $paymentMethodId, taken by: $takenByEmployeeId, Amount: $amount";
}
