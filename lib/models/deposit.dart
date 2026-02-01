import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/controllers/provider/parties.dart';
import '/models/core/timestamped.dart';

class Deposit extends BaseModel {
  int? id;
  int shiftId;
  int? recordedById;
  int? paymentMethodId;
  int? depositedFromEmployeeId;
  String? reason; // admin_deposit/refund/other
  String amount;
  String? notes;

  Deposit({
    this.id,
    required this.shiftId,
    this.recordedById,
    this.paymentMethodId,
    this.depositedFromEmployeeId,
    this.reason,
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
      'payment_method': paymentMethodId,
      'deposited_from': depositedFromEmployeeId,
      'reason': reason,
      'amount': amount,
      'notes': notes,
    };
  }

  factory Deposit.fromMap(Map<String, dynamic> map) {
    final d = Deposit(
      id: map['id'],
      shiftId: map['shift'],
      recordedById: map['recorded_by'],
      paymentMethodId: map['payment_method'],
      depositedFromEmployeeId: map['deposited_from'],
      reason: map['reason'],
      amount: map['amount']?.toString() ?? '0.00',
      notes: map['notes'],
    );
    d.baseFromMap(map);
    return d;
  }

  String toJson() => json.encode(toMap());
  factory Deposit.fromJson(String s) => Deposit.fromMap(json.decode(s));

  Map<String, dynamic> toView(BuildContext ctx) {
    final emp = ctx
        .read<AppParties>()
        .employees
        .where((element) => element.id == depositedFromEmployeeId)
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
      'deposited_from': emp,
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
    'Deposited By',
    'Pay Method',
    'Recorded By',
    'Reason',
    'Shift',
    'Notes',
  ];

  @override
  String toString() =>
      "$recordedById, $paymentMethodId, from: $depositedFromEmployeeId, $reason, $amount, $notes";
}
