import 'dart:convert';
import 'package:ponit_of_sales/utils/main.dart';
import 'package:ponit_of_sales/models/core/timestamped.dart';

class Debt extends BaseModel {
  int? id;
  String partyType; // choices: "customer","supplier","employee"
  int partyId; // points to customer/supplier/employee id
  String kind; // choices: "product","cash","previous"
  String?
  sourceContentType; // source_ct -> store content type as string identifier
  int? sourceId;
  String amount; // decimal stored as String
  String paid;
  String returned;
  DateTime? dueDate;
  String status; // unpaid/partial/paid/cancelled/overdue
  String? notes;

  // constructor
  Debt({
    this.id,
    required this.partyType,
    required this.partyId,
    required this.kind,
    this.sourceContentType,
    this.sourceId,
    required this.amount,
    required this.paid,
    required this.returned,
    this.dueDate,
    required this.status,
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
      'due_date': dueDate?.toIso8601String(),
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
      amount: map['amount']?.toString() ?? '0.00',
      paid: map['paid']?.toString() ?? '0.00',
      returned: map['returned']?.toString() ?? '0.00',
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      status: map['status'],
      notes: map['notes'],
    );
    d.baseFromMap(map);
    return d;
  }

  String toJson() => json.encode(toMap());
  factory Debt.fromJson(String source) => Debt.fromMap(json.decode(source));
}

class DebtPayment {
  int? id;
  int debtId;
  String amount;
  int? methodId; // FK to PaymentMethod
  DateTime? createdAt;
  int? createdById;
  int? shiftId;

  DebtPayment({
    this.id,
    required this.debtId,
    required this.amount,
    this.methodId,
    this.createdAt,
    this.createdById,
    this.shiftId,
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
    );
  }

  String toJson() => json.encode(toMap());
  factory DebtPayment.fromJson(String s) => DebtPayment.fromMap(json.decode(s));
}
