import 'package:flutter/services.dart';
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
) async {
  final arabicFont = await loadAppFont();
  final pdf = pw.Document(
    theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: arabicFont)),
  );

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'فاتورة مبيعات #${invoice.id}',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('التاريخ: ${invoice.date}'),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['المنتج', 'الكمية', 'السعر', 'الإجمالي'],
              data: invoice.items.map((e) {
                final product = products.firstWhere((p) => p.id == e.variantId);
                final total = (double.parse(e.unitPrice) * e.quantity)
                    .toStringAsFixed(2);
                return [product.name, '${e.quantity}', e.unitPrice, total];
              }).toList(),
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'الإجمالي: ${invoice.total}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
  return await pdf.save();
  // فتح نافذة اختيار المجلد أو المسار
}
