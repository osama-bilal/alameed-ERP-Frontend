// purchase invoice and its return and its item model is here


// PurchaseInvoice extends Invoice
import 'dart:convert';

import 'package:ponit_of_sales/models/invoices/invoice.dart';
import 'package:ponit_of_sales/models/invoices/invoiceitem.dart';
import 'package:ponit_of_sales/utils/main.dart';

class PurchaseInvoice extends Invoice {
  int? supplierId;

  PurchaseInvoice({
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
    this.supplierId,
  });

  factory PurchaseInvoice.fromMap(Map<String, dynamic> map) {
    final p = PurchaseInvoice(
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
      supplierId: map['supplier'],
    );
    p.baseFromMap(map);
    return p;
  }

  @override
  Map<String, dynamic> toMap() {
    final m = super.toMap();
    m['supplier'] = supplierId;
    return m;
  }
}

// PurchaseItem extends InvoiceItem and has invoice FK
class PurchaseItem extends InvoiceItem {
  int invoiceId; // FK to PurchaseInvoice

  PurchaseItem({
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

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    final pi = PurchaseItem(
      id: map['id'],
      variantId: map['variant'],
      quantity: map['quantity'] ?? 1,
      unitPrice: map['unit_price']?.toString() ?? '0.00',
      returnedQuantity: map['returned_quantity'] ?? 0,
      notes: map['notes'],
      invoiceId: map['invoice'],
    );
    pi.baseFromMap(map);
    return pi;
  }

  @override
  Map<String, dynamic> toMap() {
    final m = super.toMap();
    m['invoice'] = invoiceId;
    return m;
  }
}

class ReturnPurchase {
  int? id;
  int purchaseItemId;
  int quantity;
  DateTime? returnDate;
  String returnType; // refund/exchange
  String? reason;
  int createdById;

  ReturnPurchase({
    this.id,
    required this.purchaseItemId,
    required this.quantity,
    this.returnDate,
    required this.returnType,
    this.reason,
    required this.createdById,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_item': purchaseItemId,
      'quantity': quantity,
      'return_date': dateTimeToIso(returnDate),
      'return_type': returnType,
      'reason': reason,
      'created_by': createdById,
    };
  }

  factory ReturnPurchase.fromMap(Map<String, dynamic> map) {
    return ReturnPurchase(
      id: map['id'],
      purchaseItemId: map['purchase_item'],
      quantity: map['quantity'] ?? 1,
      returnDate: parseDateTime(map['return_date']),
      returnType: map['return_type'],
      reason: map['reason'],
      createdById: map['created_by'],
    );
  }

  String toJson() => json.encode(toMap());
  factory ReturnPurchase.fromJson(String s) => ReturnPurchase.fromMap(json.decode(s));
}
