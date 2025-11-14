//  sale invoice and its return and item model is here

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/models/invoices/invoice.dart';
import 'package:ponit_of_sales/models/invoices/invoiceitem.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/utils/main.dart';

class ReturnSale {
  int? id;
  int saleItemId;
  int quantity;
  DateTime? returnDate;
  String returnType;
  String? reason;
  int? createdById;

  ReturnSale({
    this.id,
    required this.saleItemId,
    required this.quantity,
    this.returnDate,
    required this.returnType,
    this.reason,
    this.createdById,
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
  List<SaleItem> _items;
  @override
  List<SaleItem> get items => _items;
  @override
  set items(covariant List<SaleItem> value) {
    _items = value;
  }

  SaleInvoice({
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
    this.customerId,
    List<SaleItem> items = const [],
  }) : _items = items;

  factory SaleInvoice.fromMap(Map<String, dynamic> map) {
    final item = map['items'] as List;

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
      exchangeWith: map['exchange_with'],
      notes: map['notes'],
      returnBarcode: map['return_code'],
      customerId: map['customer'],
      items: item.map((e) => SaleItem.fromMap(e)).toList(),
    );
    s.baseFromMap(map);

    return s;
  }
  double get totals => items.fold(0.0, (sum, item) => sum + item.total);

  @override
  Map<String, dynamic> toMap() {
    final m = super.toMap();
    m['customer'] = customerId;
    return m;
  }

  Map<String, dynamic> toView(BuildContext ctx) {
    final customer = ctx
        .read<AppParties>()
        .customers
        .firstWhere(
          (element) => element.id == customerId,
          orElse: () => ViewParty(id: customerId ?? 0, name: "$customerId"),
        )
        .name;
    final user = ctx
        .read<AppParties>()
        .users
        .firstWhere(
          (element) => element.id == userId,
          orElse: () => ViewParty(id: userId ?? 0, name: "$userId"),
        )
        .name;

    final method = ctx
        .read<AppParties>()
        .payMethods
        .firstWhere(
          (element) => element.id == paymentMethodId,
          orElse: () =>
              ViewParty(id: paymentMethodId ?? 0, name: "$paymentMethodId"),
        )
        .name;
    return {
      'id': id,
      'date': formatDateTimeSmart(date),
      'customer': customer,
      'status': status,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paid': paid,
      'payment_method': method,
      'refund_status': refundStatus,
      'exchange_with': exchangeWith,
      'notes': notes,
      'user': user,
    };
  }

  static List<String> get columnsName => [
    "ID",
    'Date',
    'Customer',
    'Status',
    'Subtotal',
    'tax',
    'Discount',
    'Total',
    'Paid',
    'Payment Method',
    'Refund status',
    'Exchange Invoice',
    'Notes',
    'User',
  ];
  @override
  String toString() {
    return "Number: $id";
  }
}

class SaleItem extends InvoiceItem {
  int invoiceId;
  String? tempId;
  SaleItem({
    super.id,
    required super.variantId,
    super.quantity,
    required super.unitPrice,
    this.tempId,
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
    'Notes',
    'Invoice',
  ];
  @override
  String toString() {
    return "$id, $variantId, $unitPrice, $invoiceId";
  }
}
