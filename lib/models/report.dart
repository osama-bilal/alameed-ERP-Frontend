
// ignore_for_file: overridden_fields

import 'dart:convert';

import 'package:ponit_of_sales/models/core/owned.dart';
import 'core/timestamped.dart';
class Report extends BaseModel with OwnedFields {
  int id;
  DateTime startDate;
  DateTime endDate;
  String reportType; // weekly/monthly/yearly/daily/custom
  String totalSales;
  String totalDeposits;
  String totalExpenses;
  String totalWithdraws;
  String netProfit;
  int totalInvoices;
  int totalProductsSold;
  @override
  int? createdById;
  @override
  int? updatedById;

  Report({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reportType,
    required this.totalSales,
    required this.totalDeposits,
    required this.totalExpenses,
    required this.totalWithdraws,
    required this.netProfit,
    required this.totalInvoices,
    required this.totalProductsSold,
    this.createdById,
    this.updatedById,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'report_type': reportType,
      'total_sales': totalSales,
      'total_deposits': totalDeposits,
      'total_expenses': totalExpenses,
      'total_withdraws': totalWithdraws,
      'net_profit': netProfit,
      'total_invoices': totalInvoices,
      'total_products_sold': totalProductsSold,
      'created_by': createdById,
      'updated_by': updatedById,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    final r = Report(
      id: map['id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      reportType: map['report_type'],
      totalSales: map['total_sales']?.toString() ?? '0.00',
      totalDeposits: map['total_deposits']?.toString() ?? '0.00',
      totalExpenses: map['total_expenses']?.toString() ?? '0.00',
      totalWithdraws: map['total_withdraws']?.toString() ?? '0.00',
      netProfit: map['net_profit']?.toString() ?? '0.00',
      totalInvoices: map['total_invoices'] ?? 0,
      totalProductsSold: map['total_products_sold'] ?? 0,
      createdById: map['created_by'],
      updatedById: map['updated_by'],
    );
    r.baseFromMap(map);
    return r;
  }

  String toJson() => json.encode(toMap());
  factory Report.fromJson(String s) => Report.fromMap(json.decode(s));
}