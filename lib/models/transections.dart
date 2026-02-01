import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/controllers/provider/parties.dart';
import '/models/core/timestamped.dart';
import '/utils/main.dart';

class AccountTransaction extends BaseModel {
  int id; // primary key (non-null)
  int contentType; // store content type string
  int objectId;
  DateTime? transactionDate;
  String amount; // string decimal
  String transactionType; // income/expense/deposit/withdraw
  String? notes;
  int? createdById;
  int? updatedById;

  AccountTransaction({
    required this.id,
    required this.contentType,
    required this.objectId,
    this.transactionDate,
    required this.amount,
    required this.transactionType,
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
      'content_type': contentType,
      'object_id': objectId,
      'transaction_date': dateTimeToIso(transactionDate),
      'amount': amount,
      'transaction_type': transactionType,
      'notes': notes,
      'created_by': createdById,
      'updated_by': updatedById,
    };
  }

  factory AccountTransaction.fromMap(Map<String, dynamic> map) {
    final at = AccountTransaction(
      id: map['id'],
      contentType: map['content_type'],
      objectId: map['object_id'],
      transactionDate: parseDateTime(map['transaction_date']),
      amount: map['amount']?.toString() ?? '0.00',
      transactionType: map['transaction_type'],
      notes: map['notes'],
      createdById: map['created_by'],
      updatedById: map['updated_by'],
    );
    at.baseFromMap(map);
    return at;
  }

  String toJson() => json.encode(toMap());
  factory AccountTransaction.fromJson(String s) =>
      AccountTransaction.fromMap(json.decode(s));
  Map<String, dynamic> toView(BuildContext ctx) {
    String contentName = "$contentType";
    try {
      contentName = ctx
          .read<AppParties>()
          .contentTypes
          .firstWhere((element) => element.id == contentType)
          .name;
    } catch (_) {}
    return {
      'id': id,
      'type': transactionType,
      'amount': amount,
      'source_type': contentName,
      'source_id': objectId,
      'date': formatDateTimeSmart(transactionDate),
      'notes': notes,
    };
  }

  static List<String> get columnsName => [
    'ID',
    'Type',
    'Amount',
    'Source Type',
    'Source ID',
    'Date',
    'Notes',
  ];

  @override
  String toString() =>
      "$contentType, Object ID: $objectId, Date: ${transactionDate.toString()}, Amount: $amount, Type: $transactionType";
}
