import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/controllers/provider/parties.dart';
import '/utils/main.dart';

class Shift {
  int? id;
  int? openedById;
  int? closedById;
  String openingBalance; // decimal string
  String expectedCash;
  String countedCash;
  bool processedAsAttendance;
  DateTime? openedAt = DateTime.now();
  DateTime? closedAt;

  Shift({
    this.id,
    this.openedById,
    this.closedById,
    required this.openingBalance,
    this.expectedCash = '0.00',
    this.countedCash = '0.00',
    this.processedAsAttendance = false,
    this.openedAt,
    this.closedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'opened_by': openedById,
    'closed_by': closedById,
    'opening_balance': openingBalance,
    'expected_cash': expectedCash,
    'counted_cash': countedCash,
    'processed_as_attendance': processedAsAttendance ? 1 : 0,
    'opened_at': dateTimeToIso(openedAt),
    'closed_at': dateTimeToIso(closedAt),
  };

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'],
      openedById: map['opened_by'],
      closedById: map['closed_by'],
      openingBalance: map['opening_balance']?.toString() ?? '0.00',
      expectedCash: map['expected_cash']?.toString() ?? '0.00',
      countedCash: map['counted_cash']?.toString() ?? '0.00',
      processedAsAttendance:
          map['processed_as_attendance'] == 1 ||
          map['processed_as_attendance'] == true,
      openedAt: parseDateTime(map['opened_at']),
      closedAt: parseDateTime(map['closed_at']),
    );
  }

  String toJson() => json.encode(toMap());
  factory Shift.fromJson(String s) => Shift.fromMap(json.decode(s));

  Map<String, dynamic> toView(BuildContext ctx) {
    final open =
        ctx
            .read<AppParties>()
            .users
            .where((element) => element.id == openedById)
            .firstOrNull
            ?.name ??
        openedById;
    final close =
        ctx
            .read<AppParties>()
            .users
            .where((element) => element.id == closedById)
            .firstOrNull
            ?.name ??
        closedById;
    return {
      'id': id,
      'opened_at': formatDateTimeSmart(openedAt),
      'opened_by': open,
      'opening_balance': openingBalance,
      'expected_cash': expectedCash,
      'closed_at': formatDateTimeSmart(closedAt),
      'closed_by': close,
      'counted_cash': countedCash,
      'is_attendance': processedAsAttendance ? 1 : 0,
    };
  }

  static List<String> get columnsName => [
    "ID",
    "Opened At",
    "Opened By",
    "Opening Balance",
    "Expected Cash",
    "Closed At",
    "Closed By",
    "Counted Cash",
    "Is Attendance",
  ];

  @override
  String toString() =>
      "Shift $id, opened by: $openedById, closed by: $closedById,  opened at: $openedAt, closed at: $closedAt";
}
