import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';

Future<pw.Font> loadAppFont() async {
  final fontData = await rootBundle.load('assets/fonts/notosansarabic.ttf');
  return pw.Font.ttf(fontData);
}

Future<Uint8List> generateInvoicePdf(
  SaleInvoice invoice,
  List<POSView> products,
  String customer,
) async {
  final arabicFont = await loadAppFont();
  final pdf = pw.Document(
    theme: pw.ThemeData(
      defaultTextStyle: pw.TextStyle(font: arabicFont, fontSize: 16),
    ),
  );
  // 1. Load the image from assets
  final ByteData bytes = await rootBundle.load(
    'assets/logo/logo-no-background.png',
  );
  final Uint8List imageData = bytes.buffer.asUint8List();

  // 2. Create a pdf image from memory
  final image = pw.MemoryImage(imageData);
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
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
                pw.Text('التاريخ: ${invoice.date}'),
                pw.Text("صادرة للعميل $customer"),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['المنتج', 'الكمية', 'السعر', 'الإجمالي'],
              data: invoice.items.map((e) {
                final product = products.firstWhere((p) => p.id == e.variantId);
                final total = e.total.toStringAsFixed(2);
                return [product.name, '${e.quantity}', e.unitPrice, total];
              }).toList(),
            ),
            // pw.Divider(),
            pw.Column(
              // crossAxisAlignment: pw.CrossAxisAlignment.end,
              // mainAxisAlignment: pw,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("المجموع: "),
                    pw.Text(invoice.subtotal ?? "0.00"),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("الخصم: "),
                    pw.Text(invoice.discount ?? "0.00"),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("الضرائب: "),
                    pw.Text(invoice.tax ?? "0.00"),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الإجمالي: ', style: pw.TextStyle(fontSize: 18)),
                    pw.Text(invoice.total ?? "0.00"),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("المبلغ الندفوع: "),
                    pw.Text(invoice.paid ?? "0.00"),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("المبلغ المتبقي: "),
                    pw.Text(
                      "${double.parse(invoice.paid ?? '0.00') - double.parse(invoice.total ?? '0.00')}",
                    ),
                  ],
                ),
                pw.Divider(),
              ],
            ),
          ],
        );
      },
    ),
  );
  return await pdf.save();
  // فتح نافذة اختيار المجلد أو المسار
}
