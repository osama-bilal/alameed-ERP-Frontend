
import 'dart:convert';

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
  String? sourceContentType;
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
  factory StockMovement.fromJson(String s) => StockMovement.fromMap(json.decode(s));
}