import 'dart:convert';

import 'package:ponit_of_sales/utils/main.dart';

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
  bool isClosed;

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
    this.isClosed = false,
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
    'is_closed': isClosed ? 1 : 0,
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
      isClosed: map['is_closed'] == 1 || map['is_closed'] == true,
    );
  }

  String toJson() => json.encode(toMap());
  factory Shift.fromJson(String s) => Shift.fromMap(json.decode(s));

  static List<String> get columnsName => [
    "ID",
    "Opened By",
    "Closed By",
    "Opening Balance",
    "Expected Cash",
    "Counted Cash",
    "Processed As Attendance",
    "Opened At",
    "Closed At",
    "Is Closed",
  ];

  @override
  String toString() =>
      "Shift $id, opened by: $openedById, closed by: $closedById, is closed: $isClosed, opened at: $openedAt, closed at: $closedAt";
}
