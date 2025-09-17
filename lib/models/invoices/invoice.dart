// invoice model is here

import 'dart:convert';

import 'package:ponit_of_sales/utils/main.dart';

import '../core/timestamped.dart';

class Invoice extends BaseModel {
  int? id;
  int userId;
  DateTime? date;
  String status; // choices in STATUS_CHOICES
  String refundStatus;
  int? paymentMethodId;
  String subtotal;
  String tax;
  String discount;
  String total;
  String paid;
  int? relatedInvoiceId;
  String? notes;

  Invoice({
    this.id,
    required this.userId,
    this.date,
    required this.status,
    required this.refundStatus,
    this.paymentMethodId,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paid,
    this.relatedInvoiceId,
    this.notes,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'id': id,
      'user': userId,
      'date': dateTimeToIso(date),
      'status': status,
      'refund_status': refundStatus,
      'payment_method': paymentMethodId,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paid': paid,
      'related_invoice': relatedInvoiceId,
      'notes': notes,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    final inv = Invoice(
      id: map['id'],
      userId: map['user'],
      date: parseDateTime(map['date']),
      status: map['status'],
      refundStatus: map['refund_status'],
      paymentMethodId: map['payment_method'],
      subtotal: map['subtotal']?.toString() ?? '0.00',
      tax: map['tax']?.toString() ?? '0.00',
      discount: map['discount']?.toString() ?? '0.00',
      total: map['total']?.toString() ?? '0.00',
      paid: map['paid']?.toString() ?? '0.00',
      relatedInvoiceId: map['related_invoice'],
      notes: map['notes'],
    );
    inv.baseFromMap(map);
    return inv;
  }

  String toJson() => json.encode(toMap());
  factory Invoice.fromJson(String s) => Invoice.fromMap(json.decode(s));
}