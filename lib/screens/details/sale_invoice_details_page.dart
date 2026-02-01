import 'package:flutter/material.dart';
import '/controllers/provider/parties.dart';
import '/controllers/provider/pos_view.dart';
import '/l10n/app_localizations.dart';
import '/models/customer.dart';
import '/models/invoices/sale.dart';
import '/models/party.dart';
import '/utils/main.dart';
import 'package:provider/provider.dart';

import '/services/printing/thermal_printer.dart'
    if (dart.library.html) '/services/printing/web_printing.dart';

class SaleInvoiceDetailsPage extends StatelessWidget {
  final SaleInvoice invoice;

  const SaleInvoiceDetailsPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    context.read<ProductsProvider>().getFromServer();
    final productsProvider = context.watch<ProductsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.invoice} #${invoice.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: l10n.print,
            onPressed: () async {
              await Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ThermalPrinting(
                        key: UniqueKey(),
                        customer: context
                            .read<AppParties>()
                            .customers
                            .firstWhere(
                              (c) => c.id == invoice.customerId,
                              orElse: () =>
                                  ViewParty<Customer>(id: -1, name: ''),
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
            _buildPartyInfo(context, l10n.customer),
            const SizedBox(height: 24),
            Text(l10n.items, style: Theme.of(context).textTheme.titleLarge),
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              context,
              l10n.invoiceNumber(invoice.id!),
              "#${invoice.id}",
            ),
            _buildInfoRow(
              context,
              l10n.date,
              formatDateTimeSmart(invoice.date, showTime: true) ?? 'N/A',
            ),
            _buildInfoRow(
              context,
              l10n.status,
              invoice.status,
              chipColor: _getStatusColor(invoice.status),
            ),
            _buildInfoRow(context, l10n.refundStatus, invoice.refundStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyInfo(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;

    final customerName = context
        .watch<AppParties>()
        .customers
        .firstWhere(
          (c) => c.id == invoice.customerId,
          orElse: () => ViewParty<Customer>(id: -1, name: ''),
        )
        .name;
    debugPrint(invoice.customerId.toString());
    debugPrint(customerName);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow(context, l10n.nameLabel, customerName),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    ProductsProvider productsProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;

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
          subtitle: Text('${l10n.price}: ${item.unitPrice}'),
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTotalRow('${l10n.subtotal}:', invoice.subtotal ?? '0.00'),
            _buildTotalRow('${l10n.discount}:', invoice.discount ?? '0.00'),
            _buildTotalRow('${l10n.tax}:', invoice.tax ?? '0.00'),
            const Divider(thickness: 1),
            _buildTotalRow(
              '${l10n.total}:',
              invoice.total ?? '0.00',
              style: boldStyle,
            ),
            _buildTotalRow('${l10n.paid}:', invoice.paid ?? '0.00'),
            _buildTotalRow(
              '${l10n.remaining}:',
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
