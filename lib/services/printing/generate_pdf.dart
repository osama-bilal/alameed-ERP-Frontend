import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/invoices/invoice.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/utils/main.dart';

class PdfGenPayload {
  final SendPort sendPort;
  final Invoice invoice;
  final List<POSView> products;
  final String customer;
  final PdfPageFormat format;
  final AppLocalizations l10n;
  PdfGenPayload({
    required this.sendPort,
    required this.invoice,
    required this.products,
    required this.customer,
    this.format = PdfPageFormat.a4,
    required this.l10n,
  });
}

/// This is the entry point for the isolate.
void generateInvoicePdfIsolate(PdfGenPayload payload) async {
  // Initialize the bindings for the isolate.
  // This is required to use services like `rootBundle` for loading assets.
  WidgetsFlutterBinding.ensureInitialized();
  // For isolates, it's also common to use the lighter-weight ServicesBinding.
  // ServicesBinding.instance.ensureInitialized();
  final pdfBytes = await generateInvoicePdf(
    invoice: payload.invoice,
    products: payload.products,
    customer: payload.customer,
    format: payload.format,
    l10n: payload.l10n,
  );
  payload.sendPort.send(pdfBytes);
}

Future<Uint8List> generateInvoicePdf({
  required Invoice invoice,
  required List<POSView> products,
  required String customer,
  PdfPageFormat format = PdfPageFormat.a4,
  required AppLocalizations l10n,
}) async {
  final fontData = await rootBundle.load('assets/fonts/notosansarabic.ttf');
  final imageData = await rootBundle.load('assets/logo/logo.png');
  final arabicFont = pw.Font.ttf(fontData.buffer.asByteData());
  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
  );

  // 2. Create a pdf image from memory
  final image = pw.MemoryImage(imageData.buffer.asUint8List());
  pdf.addPage(
    pw.Page(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(16),
      textDirection: l10n.languageCode == "ar"
          ? pw.TextDirection.rtl
          : pw.TextDirection.ltr,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                  height: 100,
                  width: 100,
                ),
              ],
            ),
            pw.Text(
              '${l10n.invoice}: #${invoice.id}',
              style: pw.TextStyle(fontSize: 22),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${l10n.date}: ${formatDateTimeSmart(DateTime.now(), reference: DateTime(1990))}',
                ),
                pw.Text("${l10n.customer}: $customer"),
              ],
            ),
            pw.Text(
              "${l10n.status}: ${invoice.status == "paid"
                  ? "مدفوع"
                  : invoice.status == "unpaid"
                  ? "غير مدفوع"
                  : "جزئي"}",
            ),

            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: [
                l10n.productName,
                l10n.quantity,
                l10n.unitPrice,
                l10n.total,
              ],
              data: invoice.items.map((e) {
                final product = products.firstWhere((p) => p.id == e.variantId);
                final total = e.total.toStringAsFixed(2);
                return [
                  "${product.name}${e.notes != null && e.notes!.isNotEmpty ? "\n${e.notes}" : ""}",
                  '${e.quantity}',
                  e.unitPrice,
                  total,
                ];
              }).toList(),
              tableDirection: pw.TextDirection.rtl,
            ),
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Text('${l10n.notes}: ${invoice.notes}'),
            ],

            pw.SizedBox(height: 20),
            _buildTotalsTable(invoice, arabicFont, l10n),
            pw.SizedBox(height: 20),
            if (invoice.returnBarcode != null &&
                invoice.returnBarcode!.isNotEmpty)
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: invoice.returnBarcode ?? "No Barcode",
                  width: 200,
                  height: 80,
                ),
              ),
          ],
        );
      },
    ),
  );
  return await pdf.save();
}

pw.Widget _buildTotalsTable(
  Invoice invoice,
  pw.Font? font,
  AppLocalizations l10n,
) {
  final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font);
  final totalStyle = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: 16,
    font: font,
  );

  return pw.Table(
    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    children: [
      _buildTableRow("${l10n.subtotal}:", invoice.subtotal ?? "0.00"),
      _buildTableRow("${l10n.discount}:", invoice.discount ?? "0.00"),
      _buildTableRow("${l10n.tax}:", invoice.tax ?? "0.00"),
      _buildTableRow(
        "${l10n.total}:",
        invoice.total ?? "0.00",
        style: totalStyle,
      ),
      _buildTableRow("${l10n.paid}:", invoice.paid ?? "0.00"),
      _buildTableRow(
        "${l10n.remaining}:",
        invoice.remaining.toStringAsFixed(2),
        style: boldStyle,
      ),
    ],
  );
}

pw.TableRow _buildTableRow(String label, String value, {pw.TextStyle? style}) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(value, style: style),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(label, style: style),
      ),
    ],
  );
}
