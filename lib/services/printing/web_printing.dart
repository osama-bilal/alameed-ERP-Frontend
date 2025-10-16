import 'package:flutter/material.dart';
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';

class ThermalPrinting extends StatefulWidget {
    const ThermalPrinting({
    super.key,
    required this.invoice,
    required this.customer,
    required this.products,
  });
  final SaleInvoice invoice;
  final List<POSView> products;
  final String customer;
  @override
  State<ThermalPrinting> createState() => _ThermalPrintingState();
}

class _ThermalPrintingState extends State<ThermalPrinting> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}