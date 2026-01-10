import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ponit_of_sales/models/invoices/invoice.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/utils/main.dart';

class PdfGenPayload {
  final SendPort sendPort;
  final Invoice invoice;
  final List<POSView> products;
  final String customer;
  final PdfPageFormat format;
  PdfGenPayload({
    required this.sendPort,
    required this.invoice,
    required this.products,
    required this.customer,
    this.format = PdfPageFormat.a4,
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
  );
  payload.sendPort.send(pdfBytes);
}

Future<Uint8List> generateInvoicePdf({
  required Invoice invoice,
  required List<POSView> products,
  required String customer,
  PdfPageFormat format = PdfPageFormat.a4,
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
      textDirection: pw.TextDirection.rtl,
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
              'فاتورة مبيعات #${invoice.id}',
              style: pw.TextStyle(fontSize: 22),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'التاريخ: ${formatDateTimeSmart(DateTime.now(), reference: DateTime(1990))}',
                ),
                pw.Text("صادرة للعميل $customer"),
              ],
            ),
            pw.Text(
              "حالة الدفع: ${invoice.status == "paid"
                  ? "مدفوع"
                  : invoice.status == "unpaid"
                  ? "غير مدفوع"
                  : "جزئي"}",
            ),

            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['المنتج', 'الكمية', 'سعر الوحدة', 'الإجمالي'],
              data: invoice.items.map((e) {
                final product = products.firstWhere((p) => p.id == e.variantId);
                final total = e.total.toStringAsFixed(2);
                return [product.name, '${e.quantity}', e.unitPrice, total];
              }).toList(),
              tableDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 20),
            _buildTotalsTable(invoice, arabicFont),
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

pw.Widget _buildTotalsTable(Invoice invoice, pw.Font? font) {
  final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font);
  final totalStyle = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: 16,
    font: font,
  );

  return pw.Table(
    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    children: [
      _buildTableRow("المجموع:", invoice.subtotal ?? "0.00"),
      _buildTableRow("الخصم:", invoice.discount ?? "0.00"),
      _buildTableRow("الضرائب:", invoice.tax ?? "0.00"),
      _buildTableRow("الإجمالي:", invoice.total ?? "0.00", style: totalStyle),
      _buildTableRow("المبلغ المدفوع:", invoice.paid ?? "0.00"),
      _buildTableRow(
        "المبلغ المتبقي:",
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
