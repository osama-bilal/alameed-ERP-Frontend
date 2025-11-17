import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ponit_of_sales/models/report.dart';
import 'package:ponit_of_sales/services/printing/report_pdf.dart';
import 'package:printing/printing.dart';

class ReportDetailsPage extends StatelessWidget {
  final Report report;

  const ReportDetailsPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report #${report.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Report',
            onPressed: () async {
              final pdfBytes = await generateReportPdf(report);
              await Printing.layoutPdf(
                  onLayout: (format) => pdfBytes, name: 'report_${report.id}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReportHeader(context),
            const SizedBox(height: 24),
            _buildFinancialSummary(context),
            const SizedBox(height: 24),
            _buildActivitySummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context, 'Report ID:', '#${report.id}'),
            _buildInfoRow(context, 'Type:', report.reportType.toUpperCase()),
            _buildInfoRow(
              context,
              'Period:',
              '${DateFormat.yMd().format(report.startDate)} - ${DateFormat.yMd().format(report.endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(thickness: 1.5),
            _buildTotalRow(
              'Total Sales:',
              report.totalSales,
              style: boldStyle.copyWith(color: Colors.green),
            ),
            _buildTotalRow('Total Deposits:', report.totalDeposits),
            _buildTotalRow(
              'Total Expenses:',
              report.totalExpenses,
              style: const TextStyle(color: Colors.orange),
            ),
            _buildTotalRow(
              'Total Withdrawals:',
              report.totalWithdraws,
              style: const TextStyle(color: Colors.red),
            ),
            const Divider(thickness: 1),
            _buildTotalRow('Net Profit:', report.netProfit, style: boldStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummary(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(thickness: 1.5),
            _buildInfoRow(
              context,
              'Total Invoices:',
              report.totalInvoices.toString(),
            ),
            _buildInfoRow(
              context,
              'Products Sold:',
              report.totalProductsSold.toString(),
            ),
            _buildInfoRow(
              context,
              'Products Returned:',
              report.totalProductsReturned.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
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
}
