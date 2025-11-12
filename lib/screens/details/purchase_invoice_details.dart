import 'package:flutter/material.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/controllers/provider/pos_view.dart';
import 'package:ponit_of_sales/models/invoices/purchase.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/models/supplier.dart';
import 'package:ponit_of_sales/utils/main.dart';
import 'package:provider/provider.dart';

import 'package:ponit_of_sales/services/printing/thermal_printer.dart'
    if (dart.library.html) 'package:ponit_of_sales/services/printing/web_printing.dart';

class SaleInvoiceDetailsPage extends StatelessWidget {
  final PurchaseInvoice invoice;

  const SaleInvoiceDetailsPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${invoice.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Invoice',
            onPressed: () async {
              await Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ThermalPrinting(
                        key: UniqueKey(),
                        customer: context
                            .read<AppParties>()
                            .suppliers
                            .firstWhere(
                              (c) => c.id == invoice.supplierId,
                              orElse: () =>
                                  ViewParty<Supplier>(id: -1, name: ''),
                            )
                            .name,
                        invoice: invoice,
                      ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        // Example: Scale transition
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.fastOutSlowIn,
                            ),
                          ),
                          child: child,
                        );
                      },
                  transitionDuration: Duration(milliseconds: 500),
                ),
              );
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Printing not implemented yet.')),
              // );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInvoiceHeader(context),
            const SizedBox(height: 24),
            _buildPartyInfo(context, 'Supplier'),
            const SizedBox(height: 24),
            Text('Items', style: Theme.of(context).textTheme.titleLarge),
            const Divider(thickness: 1.5),
            _buildItemsList(context, productsProvider),
            const SizedBox(height: 24),
            _buildTotals(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context, 'Invoice ID:', '#${invoice.id}'),
            _buildInfoRow(
              context,
              'Date:',
              formatDateTimeSmart(invoice.date, showTime: true) ?? 'N/A',
            ),
            _buildInfoRow(
              context,
              'Status:',
              invoice.status,
              chipColor: _getStatusColor(invoice.status),
            ),
            _buildInfoRow(context, 'Refund Status:', invoice.refundStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyInfo(BuildContext context, String title) {
    final customerName = context
        .read<AppParties>()
        .suppliers
        .firstWhere(
          (c) => c.id == invoice.supplierId,
          orElse: () => ViewParty<Supplier>(id: -1, name: ''),
        )
        .name;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow(context, 'Name:', customerName),
            // You can add more customer details here if available
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    ProductsProvider productsProvider,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: invoice.items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = invoice.items[index];
        final productName = productsProvider.nameOf(item.variantId);
        return ListTile(
          title: Text(productName),
          subtitle: Text('Price: ${item.unitPrice}'),
          trailing: Text(
            '${item.quantity} x ${item.unitPrice} = ${item.total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }

  Widget _buildTotals(BuildContext context) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTotalRow('Subtotal:', invoice.subtotal ?? '0.00'),
            _buildTotalRow('Discount:', invoice.discount ?? '0.00'),
            _buildTotalRow('Tax:', invoice.tax ?? '0.00'),
            const Divider(thickness: 1),
            _buildTotalRow('Total:', invoice.total ?? '0.00', style: boldStyle),
            _buildTotalRow('Paid:', invoice.paid ?? '0.00'),
            _buildTotalRow(
              'Remaining:',
              invoice.remaining.toStringAsFixed(2),
              style: boldStyle.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? chipColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          if (chipColor != null)
            Chip(
              label: Text(value),
              backgroundColor: chipColor,
              padding: EdgeInsets.zero,
            )
          else
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style ?? const TextStyle(fontSize: 16)),
          Text(value, style: style ?? const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.shade100;
      case 'partial':
        return Colors.orange.shade100;
      case 'unpaid':
        return Colors.red.shade100;
      case 'draft':
        return Colors.grey.shade300;
      default:
        return Colors.blue.shade100;
    }
  }
}
