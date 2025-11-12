import 'dart:isolate';
import 'dart:typed_data';

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
  final Uint8List fontData;
  final Uint8List imageData;
  PdfGenPayload({
    required this.sendPort,
    required this.invoice,
    required this.products,
    required this.customer,
    this.format = PdfPageFormat.a4,
    required this.fontData,
    required this.imageData,
  });
}

/// This is the entry point for the isolate.
void generateInvoicePdfIsolate(PdfGenPayload payload) async {
  final pdfBytes = await generateInvoicePdf(
    invoice: payload.invoice,
    products: payload.products,
    customer: payload.customer,
    format: payload.format,
    fontData: payload.fontData,
    imageData: payload.imageData,
  );
  payload.sendPort.send(pdfBytes);
}

Future<Uint8List> generateInvoicePdf({
  required Invoice invoice,
  required List<POSView> products,
  required String customer,
  required Uint8List fontData,
  required Uint8List imageData,
  PdfPageFormat format = PdfPageFormat.a4,
}) async {
  final arabicFont = pw.Font.ttf(fontData.buffer.asByteData());
  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
  );

  // 2. Create a pdf image from memory
  final image = pw.MemoryImage(imageData);
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
              // columnWidths: {
              //   0: pw.FlexColumnWidth(4),
              //   1: pw.FlexColumnWidth(2),
              //   2: pw.FlexColumnWidth(3),
              //   3: pw.FlexColumnWidth(3),
              // },
            ),
            pw.SizedBox(height: 20),
            _buildTotalsTable(invoice, arabicFont),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: invoice.returnBarcode ?? "No Barcode",
                width: 200,
                height: 80,
                drawText: false,
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
    // columnWidths: {
    //   0: const pw.FlexColumnWidth(1),
    //   1: const pw.FlexColumnWidth(1),
    // },
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
