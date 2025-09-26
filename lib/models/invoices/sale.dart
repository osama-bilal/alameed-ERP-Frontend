//  sale invoice and its return and item model is here

import 'dart:convert';

import 'package:ponit_of_sales/models/invoices/invoice.dart';
import 'package:ponit_of_sales/models/invoices/invoiceitem.dart';
import 'package:ponit_of_sales/utils/main.dart';

class ReturnSale {
  int? id;
  int saleItemId;
  int quantity;
  DateTime? returnDate;
  String returnType;
  String? reason;
  int createdById;

  ReturnSale({
    this.id,
    required this.saleItemId,
    required this.quantity,
    this.returnDate,
    required this.returnType,
    this.reason,
    required this.createdById,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_item': saleItemId,
      'quantity': quantity,
      'return_date': dateTimeToIso(returnDate),
      'return_type': returnType,
      'reason': reason,
      'created_by': createdById,
    };
  }

  factory ReturnSale.fromMap(Map<String, dynamic> map) {
    return ReturnSale(
      id: map['id'],
      saleItemId: map['sale_item'],
      quantity: map['quantity'] ?? 1,
      returnDate: parseDateTime(map['return_date']),
      returnType: map['return_type'],
      reason: map['reason'],
      createdById: map['created_by'],
    );
  }

  String toJson() => json.encode(toMap());
  factory ReturnSale.fromJson(String s) => ReturnSale.fromMap(json.decode(s));

  static List<String> get columnsName => [
    "ID",
    'Sale Item',
    'Quantity',
    'Return Date',
    'Return type',
    'Reason',
  ];
  @override
  String toString() {
    return "$id, $saleItemId, $returnDate, $reason, $returnType";
  }
}

class SaleInvoice extends Invoice {
  int? customerId;

  SaleInvoice({
    super.id,
    required super.userId,
    super.date,
    required super.status,
    required super.refundStatus,
    super.paymentMethodId,
    required super.subtotal,
    required super.tax,
    required super.discount,
    required super.total,
    required super.paid,
    super.relatedInvoiceId,
    super.notes,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    this.customerId,
  });

  factory SaleInvoice.fromMap(Map<String, dynamic> map) {
    final s = SaleInvoice(
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
      customerId: map['customer'],
    );
    s.baseFromMap(map);
    return s;
  }

  @override
  Map<String, dynamic> toMap() {
    final m = super.toMap();
    m['customer'] = customerId;
    return m;
  }

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
    'Customer',
  ];
  @override
  String toString() {
    return "Number: $id";
  }
}

class SaleItem extends InvoiceItem {
  int invoiceId;

  SaleItem({
    super.id,
    required super.variantId,
    required super.quantity,
    required super.unitPrice,
    super.returnedQuantity,
    super.notes,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    required this.invoiceId,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    final si = SaleItem(
      id: map['id'],
      variantId: map['variant'],
      quantity: map['quantity'] ?? 1,
      unitPrice: map['unit_price']?.toString() ?? '0.00',
      returnedQuantity: map['returned_quantity'] ?? 0,
      notes: map['notes'],
      invoiceId: map['invoice'],
    );
    si.baseFromMap(map);
    return si;
  }

  @override
  Map<String, dynamic> toMap() {
    final m = super.toMap();
    m['invoice'] = invoiceId;
    return m;
  }

  static List<String> get columnsName => [
    "ID",
    'Variant',
    'Quantity',
    'Unit Price',
    'Returned Quantity',
    'Notes',
    'Invoice',
  ];
  @override
  String toString() {
    return "$id, $variantId, $unitPrice, $returnedQuantity, $invoiceId";
  }
}
