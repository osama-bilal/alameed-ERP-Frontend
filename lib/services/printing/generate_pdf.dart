// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ponit_of_sales/models/invoices/sale.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
// import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> generateInvoicePdf(SaleInvoice invoice, List<POSView> products) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('فاتورة مبيعات #${invoice.id}', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('التاريخ: ${invoice.date}'),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['المنتج', 'الكمية', 'السعر', 'الإجمالي'],
              data: invoice.items.map((e) {
                final product = products.firstWhere((p) => p.id == e.variantId);
                final total = (double.parse(e.unitPrice) * e.quantity).toStringAsFixed(2);
                return [product.name, '${e.quantity}', e.unitPrice, total];
              }).toList(),
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('الإجمالي: ${invoice.total}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            )
          ],
        );
      },
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/invoice_${invoice.id}.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}