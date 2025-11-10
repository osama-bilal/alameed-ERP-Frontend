// invoice model is here

import 'dart:convert';

import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/invoices/invoiceitem.dart';
import 'package:ponit_of_sales/services/general_services.dart';
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
  int? exchangeWith;
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
    this.exchangeWith,
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
      'exchange_with': exchangeWith,
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
      exchangeWith: map['exchange_with'],
      notes: map['notes'],
      returnBarcode: map['return_code'],
    );
    inv.baseFromMap(map);
    return inv;
  }


  double get remaining {
    final totalAmount = double.tryParse(total ?? '0.0') ?? 0.0;
    final paidAmount = double.tryParse(paid ?? '0.0') ?? 0.0;
    return paidAmount - totalAmount;
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
    'Exchange With',
    'Notes',
  ];
  @override
  String toString() {
    return "Number: $id";
  }
}







// ------------------------ new way -----------------------------------------------------
enum RefundStatus {
  // ignore: constant_identifier_names
  not_refunded,
  partial,
  refunded,
}

enum InvoiceType { sale, purchase, returnSale, returnPurchase, replacement }

class GeneralInvoice extends BaseModel {
  final InvoiceType type;
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
  String? notes;
  String? returnBarcode;
  int? otherParty;
  int? originalInvoice;
  int? exchangeWith;
  String? returnType; // refund | exchange
  List<GeneralInvoiceItem> items;

  GeneralInvoice._internal({
    required this.type,
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
    this.notes,
    this.returnBarcode,
    this.otherParty,
    this.originalInvoice,
    this.exchangeWith,
    this.returnType,
    this.items = const [],
  });

  double get totals => items.fold(0.0, (sum, item) => sum + item.total);

  double get remaining {
    final totalAmount = double.tryParse(total ?? '0.0') ?? 0.0;
    final paidAmount = double.tryParse(paid ?? '0.0') ?? 0.0;
    return paidAmount - totalAmount;
  }
  GeneralService<Object> get service {
    switch (type) {
      case InvoiceType.purchase:
        return AppService.purchaseInvoiceService;
      case InvoiceType.sale:
        return AppService.saleInvoiceService;
      case InvoiceType.returnPurchase:
        return AppService.returnPurchaseService;
      case InvoiceType.returnSale:
        return AppService.returnSaleService;
      case InvoiceType.replacement:
        return AppService.saleInvoiceService;
    }
  }

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
      'exchange_with': exchangeWith,
      'notes': notes,
      if (type == InvoiceType.sale || type == InvoiceType.returnSale)
        'customer': otherParty,
      if (type == InvoiceType.purchase || type == InvoiceType.returnPurchase)
        'supplier': otherParty,
      if (type == InvoiceType.returnSale || type == InvoiceType.returnPurchase)
        'original_invoice': originalInvoice,
      if (type == InvoiceType.returnSale || type == InvoiceType.returnPurchase)
        'return_type': returnType,
    };
  }

  factory GeneralInvoice.fromMap(Map<String, dynamic> map, InvoiceType type) {
    final item = map['items'] as List;
    final inv = GeneralInvoice._internal(
      type: type,
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
      exchangeWith: map['exchange_with'],
      notes: map['notes'],
      returnBarcode: map['return_code'],
      otherParty: map['customer'] ?? map['supplier'],
      originalInvoice: map['original_invoice'],
      returnType: map['return_type'],
      items: item
          .map(
            (e) => GeneralInvoiceItem.fromMap(
              e,
              [
                    InvoiceType.returnPurchase,
                    InvoiceType.returnSale,
                  ].contains(type)
                  ? ItemType.refund
                  : ItemType.sale,
            ),
          )
          .toList(),
    );
    inv.baseFromMap(map);
    return inv;
  }

  String toJson() => json.encode(toMap());
  factory GeneralInvoice.fromJson(String s, InvoiceType type) =>
      GeneralInvoice.fromMap(json.decode(s), type);

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

  factory GeneralInvoice.sale({
    int? id,
    required int userId,
    DateTime? date,
    String status = "draft",
    String refundStatus = "not_refunded",
    int? paymentMethodId,
    String subtotal = "0.0",
    String tax = "0.0",
    String discount = "0.0",
    String total = "0.0",
    String paid = "0.0",
    String? notes,
    String? returnBarcode,
    int? customerId,
  }) {
    return GeneralInvoice._internal(
      type: InvoiceType.sale,
      date: date ?? DateTime.now(),
      id: id,
      userId: userId,
      status: status,
      refundStatus: refundStatus,
      paymentMethodId: paymentMethodId,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      paid: paid,
      notes: notes,
      returnBarcode: returnBarcode,
      otherParty: customerId,
    );
  }

  factory GeneralInvoice.purchase({
    int? id,
    required int userId,
    DateTime? date,
    String status = "draft",
    String refundStatus = "not_refunded",
    int? paymentMethodId,
    String subtotal = "0.0",
    String tax = "0.0",
    String discount = "0.0",
    String total = "0.0",
    String paid = "0.0",
    String? notes,
    String? returnBarcode,
    int? supplierId,
  }) {
    return GeneralInvoice._internal(
      type: InvoiceType.purchase,
      date: date ?? DateTime.now(),
      id: id,
      userId: userId,
      status: status,
      refundStatus: refundStatus,
      paymentMethodId: paymentMethodId,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      paid: paid,
      notes: notes,
      returnBarcode: returnBarcode,
      otherParty: supplierId,
    );
  }

  factory GeneralInvoice.replacement({
    int? id,
    required int userId,
    DateTime? date,
    String status = "draft",
    String refundStatus = "not_refunded",
    int? paymentMethodId,
    String subtotal = "0.0",
    String tax = "0.0",
    String discount = "0.0",
    String total = "0.0",
    String paid = "0.0",
    String? notes,
    String? returnBarcode,
    int? customerId,
    required int exchangeWith,
  }) {
    return GeneralInvoice._internal(
      type: InvoiceType.replacement,
      date: date ?? DateTime.now(),
      id: id,
      userId: userId,
      status: status,
      refundStatus: refundStatus,
      paymentMethodId: paymentMethodId,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      paid: paid,
      notes: notes,
      returnBarcode: returnBarcode,
      otherParty: customerId,
      exchangeWith: exchangeWith,
    );
  }

  factory GeneralInvoice.returnPurchase({
    int? id,
    required int userId,
    DateTime? date,
    String status = "draft",
    String refundStatus = "not_refunded",
    int? paymentMethodId,
    String subtotal = "0.0",
    String tax = "0.0",
    String discount = "0.0",
    String total = "0.0",
    String paid = "0.0",
    String? notes,
    String? returnBarcode,
    int? supplierId,
    required int originalInvoice,
    required String returnType,
  }) {
    return GeneralInvoice._internal(
      type: InvoiceType.returnPurchase,
      date: date ?? DateTime.now(),
      id: id,
      userId: userId,
      status: status,
      refundStatus: refundStatus,
      paymentMethodId: paymentMethodId,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      paid: paid,
      notes: notes,
      returnBarcode: returnBarcode,
      otherParty: supplierId,
      originalInvoice: originalInvoice,
      returnType: returnType,
    );
  }

  factory GeneralInvoice.returnSale({
    int? id,
    required int userId,
    DateTime? date,
    String status = "draft",
    String refundStatus = "not_refunded",
    int? paymentMethodId,
    String subtotal = "0.0",
    String tax = "0.0",
    String discount = "0.0",
    String total = "0.0",
    String paid = "0.0",
    String? notes,
    String? returnBarcode,
    int? customerId,
    required int originalInvoice,
    required String returnType,
  }) {
    return GeneralInvoice._internal(
      type: InvoiceType.returnSale,
      date: date ?? DateTime.now(),
      id: id,
      userId: userId,
      status: status,
      refundStatus: refundStatus,
      paymentMethodId: paymentMethodId,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      paid: paid,
      notes: notes,
      returnBarcode: returnBarcode,
      otherParty: customerId,
      originalInvoice: originalInvoice,
      returnType: returnType,
    );
  }
}
