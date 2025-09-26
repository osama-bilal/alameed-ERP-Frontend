

import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';
import 'package:ponit_of_sales/utils/main.dart';

class AccountTransaction extends BaseModel {
  int id; // primary key (non-null)
  String contentType; // store content type string
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
  factory AccountTransaction.fromJson(String s) => AccountTransaction.fromMap(json.decode(s));

  static List<String> get columnsName => [
        'ID',
        'Content Type',
        'Object ID',
        'Transaction Date',
        'Amount',
        'Transaction Type',
        'Notes',
      ];

  @override
  String toString() =>
      "$id, $contentType, Object ID: $objectId, Date: ${transactionDate.toString()}, Amount: $amount, Type: $transactionType";
}
