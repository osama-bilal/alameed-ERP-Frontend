import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/core/timestamped.dart';
import 'package:ponit_of_sales/utils/main.dart';

class StockMovement extends BaseModel {
  int? id;
  int variantId;
  int quantity;
  String movementType; // sale/purchase/return_in/return_out/adjustment
  int? userId; // FK to User
  DateTime? movementDate;
  String? notes;
  int? sourceContentType;
  int? sourceId;

  StockMovement({
    this.id,
    required this.variantId,
    required this.quantity,
    required this.movementType,
    this.userId,
    this.movementDate,
    this.notes,
    this.sourceContentType,
    this.sourceId,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    ...baseToMap(),
    'id': id,
    'variant': variantId,
    'quantity': quantity,
    'movement_type': movementType,
    'user': userId,
    'movement_date': dateTimeToIso(movementDate),
    'notes': notes,
    'source_ct': sourceContentType,
    'source_id': sourceId,
  };

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    final s = StockMovement(
      id: map['id'],
      variantId: map['variant'],
      quantity: map['quantity'] ?? 0,
      movementType: map['movement_type'],
      userId: map['user'],
      movementDate: parseDateTime(map['movement_date']),
      notes: map['notes'],
      sourceContentType: map['source_ct'],
      sourceId: map['source_id'],
    );
    s.baseFromMap(map);
    return s;
  }

  String toJson() => json.encode(toMap());
  factory StockMovement.fromJson(String s) =>
      StockMovement.fromMap(json.decode(s));

  Map<String, dynamic> toView(BuildContext ctx) {
    String product = "$variantId";
    try {
      product = ctx
          .read<ProductsProvider>()
          .pros
          .firstWhere((element) => element.id == variantId)
          .name;
    } catch (_) {}
    String contentType = "$sourceContentType";
    try {
      contentType = ctx
          .read<AppParties>()
          .contentTypes
          .firstWhere((element) => element.id == sourceContentType)
          .name;
    } catch (_) {}
    return {
      'id': id,
      'variant': product,
      'quantity': quantity,
      'movement_type': movementType.replaceAll("_", " "),
      'movement_date': formatDateTimeSmart(movementDate),
      'notes': notes,
      'source_ct': contentType,
      'source_id': sourceId,
    };
  }

  static List<String> get columnsName => [
    'ID',
    'Variant',
    'Quantity',
    'Movement Type',
    'Movement Date',
    'Notes',
    'Source CT',
    'Source ID',
  ];

  @override
  String toString() =>
      'variant: $variantId, quantity: $quantity, Type: $movementType, Date: $movementDate';
}
