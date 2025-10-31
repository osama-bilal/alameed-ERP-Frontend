//  invoice item here

import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';

class InvoiceItem extends BaseModel {
  int? id;
  int variantId; // FK to ProductVariant
  int quantity;
  String unitPrice; // decimal string
  // int returnedQuantity;
  String? notes;

  InvoiceItem({
    this.id,
    required this.variantId,
    this.quantity = 1,
    required this.unitPrice,
    // this.returnedQuantity = 0,
    this.notes,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'id': id,
      'variant': variantId,
      'quantity': quantity,
      'unit_price': unitPrice,
      // 'returned_quantity': returnedQuantity,
      'notes': notes,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    final i = InvoiceItem(
      id: map['id'],
      variantId: map['variant'],
      quantity: map['quantity'] ?? 1,
      unitPrice: map['unit_price']?.toString() ?? '0.00',
      // returnedQuantity: map['returned_quantity'] ?? 0,
      notes: map['notes'],
    );
    i.baseFromMap(map);
    return i;
  }
  double get total => quantity * double.parse(unitPrice);

  String toJson() => json.encode(toMap());
  factory InvoiceItem.fromJson(String s) => InvoiceItem.fromMap(json.decode(s));

  static List<String> get columnsName => [
    "ID",
    'Variant',
    'Quantity',
    'Unit Price',
    // 'Returned Quantity',
    'Notes',
  ];
  @override
  String toString() {
    return "$id, $variantId, $unitPrice";
  }
}

enum ItemType { refund, sale }

class GeneralInvoiceItem extends BaseModel {
  ItemType itemType;
  int? id;
  int variantOrItemId;
  int quantity;
  String unitPrice;
  String? notes;

  GeneralInvoiceItem._internal({
    required this.itemType,
    this.id,
    required this.variantOrItemId,
    this.quantity = 1,
    required this.unitPrice,
    // this.returnedQuantity = 0,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'id': id,
      itemType == ItemType.sale ? 'variant' : "original_item": variantOrItemId,
      'quantity': quantity,
      'unit_price': unitPrice,
      itemType == ItemType.sale ? 'notes' : 'reason': notes,
    };
  }

  factory GeneralInvoiceItem.fromMap(Map<String, dynamic> map, ItemType type) {
    final i = GeneralInvoiceItem._internal(
      itemType: type,
      id: map['id'],
      variantOrItemId: type == ItemType.sale
          ? map['variant']
          : map['original_item'],
      quantity: map['quantity'] ?? 1,
      unitPrice: map['unit_price']?.toString() ?? '0.00',
      notes: type == ItemType.sale ? map['notes'] : map['reason'],
    );
    i.baseFromMap(map);
    return i;
  }

  String toJson() => json.encode(toMap());
  factory GeneralInvoiceItem.fromJson(String s) =>
      GeneralInvoiceItem.fromMap(json.decode(s), ItemType.sale);

  static List<String> get columnsName => [
    "ID",
    'Variant',
    'Quantity',
    'Unit Price',
    'Notes',
  ];
  @override
  String toString() {
    return "$id, $variantOrItemId, $unitPrice";
  }
  double get total => quantity * double.parse(unitPrice);

  factory GeneralInvoiceItem.sale({
    int? id,
    required int variantId,
    int quantity = 1,
    required String unitPrice,
    String? notes,
  }) {
    return GeneralInvoiceItem._internal(
      itemType: ItemType.sale,
      id: id,
      variantOrItemId: variantId,
      quantity: quantity,
      unitPrice: unitPrice,
      notes: notes,
    );
  }

  factory GeneralInvoiceItem.refund({
    int? id,
    required int originalItemId,
    int quantity = 1,
    required String unitPrice,
    String? reason,
  }) {
    return GeneralInvoiceItem._internal(
      itemType: ItemType.refund,
      id: id,
      variantOrItemId: originalItemId,
      quantity: quantity,
      unitPrice: unitPrice,
      notes: reason,
    );
  }
}
