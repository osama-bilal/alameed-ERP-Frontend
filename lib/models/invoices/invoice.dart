// invoice model is here

import 'dart:convert';

import 'package:ponit_of_sales/utils/main.dart';

import '../core/timestamped.dart';

class Invoice extends BaseModel {
  int? id;
  int? userId;
  DateTime? date;
  String status; // choices in STATUS_CHOICES
  String refundStatus;
  int? paymentMethodId;
  String? subtotal;
  String? tax;
  String? discount;
  String? total;
  String? paid;
  int? relatedInvoiceId;
  String? notes;
  String? returnBarcode;

  Invoice({
    this.id,
    this.userId,
    this.date,
    this.status = "draft",
    this.refundStatus = "not_refunded",
    this.paymentMethodId,
    this.subtotal,
    this.tax,
    this.discount,
    this.total,
    this.paid,
    this.relatedInvoiceId,
    this.notes,
    this.returnBarcode,
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
      subtotal: map['subtotal']?.toString(),
      tax: map['tax']?.toString(),
      discount: map['discount']?.toString(),
      total: map['total']?.toString(),
      paid: map['paid']?.toString(),
      relatedInvoiceId: map['related_invoice'],
      notes: map['notes'],
      returnBarcode: map['return_code'],
    );
    inv.baseFromMap(map);
    return inv;
  }

  String toJson() => json.encode(toMap());
  factory Invoice.fromJson(String s) => Invoice.fromMap(json.decode(s));

  static List<String> get columnsName => [
    "ID",
    'User',
    'Date',
    'Status',
    'Refund status',
    'Payment Method',
    'Subtotal',
    'tax',
    'Discount',
    'Total',
    'Paid',
    'Related Invoice',
    'Notes',
  ];
  @override
  String toString() {
    return "Number: $id";
  }
}
