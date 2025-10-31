import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ponit_of_sales/models/invoices/sale.dart' show SaleInvoice;
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/services/auth_service.dart';
import 'package:ponit_of_sales/utils/main.dart';
// import 'package:printing/printing.dart';

Future<Uint8List> generateReceipt({
  String? type,
  required SaleInvoice invoice,
  required String customer,
  required List<POSView> products,
}) async {
  final pdf = pw.Document();
  final arabicFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/notosansarabic.ttf'),
  );

  final imageData = await rootBundle.load('assets/logo/logo.png');
  final image = pw.MemoryImage(imageData.buffer.asUint8List());

  final user = await AuthService().getStoredUser();
  String userName = "";
  if (user != null) userName = user.firstName ?? "";

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
          font: arabicFont,
          fontSize: 12,
          fontNormal: arabicFont,
          fontBold: arabicFont,
        ),
      ),
      // theme: pw.ThemeData.withFont(
      //   base: arabicFont,
      //   bold: arabicFont,
      // ),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Image(image, height: 80)),
            pw.Center(
              child: pw.Text(
                'Al-Ameed Shop',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Customer: $customer',
              style: pw.TextStyle(font: arabicFont),
            ),
            pw.Text(
              'Date: ${formatDateTimeSmart(DateTime.now(), reference: DateTime(1990), use24Hour: true)}',
            ),
            pw.Text("Status: ${invoice.status.replaceAll('_', " ")}"),
            pw.Divider(height: 10),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.topLeft,

              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
              },
              headers: ['Item', 'Qty', 'Price', 'Total'],
              data: invoice.items.map((e) {
                final product = products.firstWhere((p) => p.id == e.variantId);
                final price = double.parse(e.unitPrice).toStringAsFixed(0);
                final total = e.total.toStringAsFixed(0);
                return [product.name, e.quantity.toString(), price, total];
              }).toList(),
            ),
            pw.Divider(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Subtotal: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(invoice.subtotal ?? "0.00"),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Discount: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(invoice.discount ?? "0.00"),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Tax: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(invoice.tax ?? "0.00"),
              ],
            ),
            pw.Divider(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.Text(
                  invoice.total ?? "0.00",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            pw.Divider(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Paid: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  invoice.paid ?? "0.00",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Remaining: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  "${invoice.remaining}",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            pw.Text('User: $userName'),
            pw.SizedBox(height: 15),
            if (invoice.returnBarcode != null &&
                invoice.returnBarcode!.isNotEmpty)
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: invoice.returnBarcode!,
                  width: 150,
                  height: 50,
                  drawText: false,
                ),
              ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Thank you for your purchase!',
                style: pw.TextStyle(font: arabicFont),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
