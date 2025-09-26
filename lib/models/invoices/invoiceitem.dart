//  invoice item here

import 'dart:convert';

import 'package:ponit_of_sales/models/core/timestamped.dart';

class InvoiceItem extends BaseModel {
  int? id;
  int variantId; // FK to ProductVariant
  int quantity;
  String unitPrice; // decimal string
  int returnedQuantity;
  String? notes;

  InvoiceItem({
    this.id,
    required this.variantId,
    required this.quantity,
    required this.unitPrice,
    this.returnedQuantity = 0,
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
      'returned_quantity': returnedQuantity,
      'notes': notes,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    final i = InvoiceItem(
      id: map['id'],
      variantId: map['variant'],
      quantity: map['quantity'] ?? 1,
      unitPrice: map['unit_price']?.toString() ?? '0.00',
      returnedQuantity: map['returned_quantity'] ?? 0,
      notes: map['notes'],
    );
    i.baseFromMap(map);
    return i;
  }

  String toJson() => json.encode(toMap());
  factory InvoiceItem.fromJson(String s) => InvoiceItem.fromMap(json.decode(s));

    static List<String> get columnsName =>[
    "ID",
    'Variant',
    'Quantity',
    'Unit Price',
    'Returned Quantity',
    'Notes'
  ];
  @override
  String toString() {
    return "$id, $variantId, $unitPrice, $returnedQuantity";
  }
}