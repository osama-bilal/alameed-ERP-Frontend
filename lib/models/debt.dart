import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/utils/main.dart';
import 'package:ponit_of_sales/models/core/timestamped.dart';
import 'package:provider/provider.dart';

class Debt extends BaseModel {
  int? id;
  String? partyType; // choices: "customer","supplier","employee"
  int? partyId; // points to customer/supplier/employee id
  String? kind; // choices: "product","cash","previous"
  int?
  sourceContentType; // source_ct -> store content type as string identifier
  int? sourceId;
  String? amount; // decimal stored as String
  String? paid;
  String? returned;
  DateTime? dueDate;
  String status; // unpaid/partial/paid/cancelled/overdue
  String? notes;

  // constructor
  Debt({
    this.id,
    this.partyType,
    this.partyId,
    this.kind,
    this.sourceContentType,
    this.sourceId,
    this.amount,
    this.paid,
    this.returned,
    this.dueDate,
    this.status = "unpaid",
    this.notes,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  // computed property balance as String (amount - paid - returned) not calculated numerically here.
  // If you want numeric compute, parse the strings with Decimal package or double.
  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'id': id,
      'party_type': partyType,
      'party_id': partyId,
      'kind': kind,
      'source_ct': sourceContentType,
      'source_id': sourceId,
      'amount': amount,
      'paid': paid,
      'returned': returned,
      'due_date': dueDate == null
          ? null
          : DateFormat("yyyy-MM-dd").format(dueDate!),
      'status': status,
      'notes': notes,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    final d = Debt(
      id: map['id'],
      partyType: map['party_type'],
      partyId: map['party_id'],
      kind: map['kind'],
      sourceContentType: map['source_ct'],
      sourceId: map['source_id'],
      amount: map['amount'] ?? "0.00",
      paid: map['paid'] ?? "0.00",
      returned: map['returned'] ?? "0.00",
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      status: map['status'],
      notes: map['notes'],
    );
    d.baseFromMap(map);
    return d;
  }

  String toJson() => json.encode(toMap());
  factory Debt.fromJson(String source) => Debt.fromMap(json.decode(source));

  Map<String, String?> toView(BuildContext ctx) {
    String party = partyId.toString();
    try {
      switch (partyType) {
        case "customer":
          party =
              ctx
                  .read<AppParties>()
                  .customers
                  .where((element) => element.id == partyId)
                  .firstOrNull
                  ?.name ??
              party;
          break;
        case "supplier":
          party =
              ctx
                  .read<AppParties>()
                  .suppliers
                  .where((element) => element.id == partyId)
                  .firstOrNull
                  ?.name ??
              party;
          break;
        case "employee":
          party =
              ctx
                  .read<AppParties>()
                  .employees
                  .where((element) => element.id == partyId)
                  .firstOrNull
                  ?.name ??
              party;
          break;
        default:
      }
    } catch (_) {}
    String contentType = "$sourceContentType";
    try {
      contentType = ctx
          .read<AppParties>()
          .contentTypes
          .firstWhere((element) => element.id == sourceContentType)
          .name;
    } catch (_) {}

    return {
      'id': id.toString(),
      'party_type': partyType,
      'party_Name': party,
      'amount': amount,
      'paid': paid,
      'kind': kind,
      'source': contentType,
      'source_id': sourceId?.toString(),
      'returned': returned,
      'due_date': dueDate == null
          ? null
          : DateFormat("yyyy-MM-dd").format(dueDate!),
      'status': status,
      'notes': notes,
    };
  }

  static List<String> get columnsName => [
    'ID',
    'Party Type',
    'Party Name',
    'Amount',
    'Paid',
    'Kind',
    'Source',
    'Source ID',
    'Returned',
    'Due Date',
    'Status',
    'Notes',
  ];

  @override
  String toString() =>
      '$partyType, $partyId, $kind, $amount, paid: $paid, returned: $returned, status: $status';
}

class DebtPayment {
  int? id;
  int debtId;
  String? amount;
  int? methodId; // FK to PaymentMethod
  DateTime? createdAt;
  int? createdById;
  int? shiftId;
  String? notes;
  DebtPayment({
    this.id,
    required this.debtId,
    this.amount,
    this.methodId,
    this.createdAt,
    this.createdById,
    this.shiftId,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debt': debtId,
      'amount': amount,
      'method': methodId,
      'created_at': dateTimeToIso(createdAt),
      'created_by': createdById,
      'shift': shiftId,
      'notes': notes,
    };
  }

  factory DebtPayment.fromMap(Map<String, dynamic> map) {
    return DebtPayment(
      id: map['id'],
      debtId: map['debt'],
      amount: map['amount']?.toString() ?? '0.00',
      methodId: map['method'],
      createdAt: parseDateTime(map['created_at']),
      createdById: map['created_by'],
      shiftId: map['shift'],
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());
  factory DebtPayment.fromJson(String s) => DebtPayment.fromMap(json.decode(s));

  Map<String, dynamic> toView(BuildContext ctx) {
    final user = ctx
        .read<AppParties>()
        .users
        .where((element) => element.id == createdById)
        .firstOrNull
        ?.name;

    final method = ctx
        .read<AppParties>()
        .payMethods
        .where((element) => element.id == methodId)
        .firstOrNull
        ?.name;
    return {
      'id': id,
      'debt': debtId,
      'amount': amount,
      'method': method,
      'created_at': formatDateTimeSmart(createdAt),
      'created_by': user,
      'shift': shiftId,
      'notes': notes,
    };
  }

  static List<String> get columnsName => [
    'ID',
    'Debt',
    'Amount',
    'Payment Method',
    "Created At",
    "Created By",
    'Shift',
    'Notes',
  ];

  @override
  String toString() => '$id, for debt: $debtId, amount: $amount, $methodId';
}
