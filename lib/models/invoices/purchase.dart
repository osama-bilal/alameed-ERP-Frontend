// purchase invoice and its return and its item model is here

// PurchaseInvoice extends Invoice
import 'dart:convert';

import 'package:ponit_of_sales/models/invoices/invoice.dart';
import 'package:ponit_of_sales/models/invoices/invoiceitem.dart';
import 'package:ponit_of_sales/utils/main.dart';

class PurchaseInvoice extends Invoice {
  int? supplierId;

  // List<PurchaseItem> items;
  List<PurchaseItem> _items;
  @override
  List<PurchaseItem> get items => _items;
  @override
  set items(covariant List<PurchaseItem> value) {
    _items = value;
  }

  PurchaseInvoice({
    super.id,
    super.userId,
    super.date,
    super.status,
    super.refundStatus,
    super.paymentMethodId,
    super.subtotal,
    super.tax,
    super.discount,
    super.total,
    super.paid,
    super.exchangeWith,
    super.notes,
    super.returnBarcode,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    this.supplierId,
    List<PurchaseItem> items = const [],
  }) : _items = items;

  factory PurchaseInvoice.fromMap(Map<String, dynamic> map) {
    final item = map['items'] as List;
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
      exchangeWith: map['exchange_with'],
      notes: map['notes'],
      returnBarcode: map['return_code'],
      supplierId: map['supplier'],
      items: item.map((e) => PurchaseItem.fromMap(e)).toList(),
    );
    p.baseFromMap(map);
    return p;
  }
  double get totals => items.fold(0.0, (sum, item) => sum + item.total);

  @override
  Map<String, dynamic> toMap() {
    final m = super.toMap();
    m['supplier'] = supplierId;
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
    'Supplier',
  ];
  @override
  String toString() {
    return "Number: $id";
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

  static List<String> get columnsName => [
    "ID",
    'Variant',
    'Quantity',
    'Unit Price',
    'Notes',
    'Invoice',
  ];
  @override
  String toString() {
    return "$id, $variantId, $unitPrice, $invoiceId";
  }
}

class ReturnPurchase {
  int? id;
  int purchaseItemId;
  int quantity;
  DateTime? returnDate;
  String returnType; // refund/exchange
  String? reason;
  int? createdById;

  ReturnPurchase({
    this.id,
    required this.purchaseItemId,
    required this.quantity,
    this.returnDate,
    required this.returnType,
    this.reason,
    this.createdById,
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
  factory ReturnPurchase.fromJson(String s) =>
      ReturnPurchase.fromMap(json.decode(s));

  static List<String> get columnsName => [
    "ID",
    'Purchase Item',
    'Quantity',
    'Return Date',
    'Return type',
    'Reason',
  ];
  @override
  String toString() {
    return "$id, $purchaseItemId, $returnDate, $reason, $returnType";
  }
}
