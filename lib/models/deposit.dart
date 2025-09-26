
import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';

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

  static List<String> get columnsName => [
        'ID',
        'Shift',
        'Recorded By',
        'Payment Method',
        'Deposited From',
        'Reason',
        'Amount',
        'Notes',
      ];

  @override
  String toString() => "$id, Shift ID: $shiftId, Recorded By: $recordedById, Payment Method: $paymentMethodId, Deposited From: $depositedFromEmployeeId, Reason: $reason, Amount: $amount, Notes: $notes";
}