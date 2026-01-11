import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ponit_of_sales/l10n/app_localizations.dart';
import 'package:ponit_of_sales/models/invoices/invoice.dart';
import 'package:ponit_of_sales/models/pos_view.dart';
import 'package:ponit_of_sales/services/auth_service.dart';
import 'package:ponit_of_sales/utils/main.dart';

Future<Uint8List> generateReceipt({
  String? type,
  required Invoice invoice,
  required String customer,
  required List<POSView> products,
  required AppLocalizations l10n,
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
          fontNormal: arabicFont,
          fontBold: arabicFont,
        ),
      ),
      textDirection: l10n.languageCode == 'ar'
          ? pw.TextDirection.rtl
          : pw.TextDirection.ltr,
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
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(l10n.invoiceNumber(invoice.id!)),
            pw.Text(
              '${l10n.customer}: $customer',
              style: pw.TextStyle(font: arabicFont),
            ),
            pw.Text(
              '${l10n.date}: ${formatDateTimeSmart(DateTime.now(), reference: DateTime(1990), use24Hour: true)}',
            ),
            pw.Text("${l10n.status}: ${invoice.status.replaceAll('_', " ")}"),
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
              headers: [l10n.items, l10n.qty, l10n.price, l10n.total],
              data: invoice.items.map((e) {
                final product = products.firstWhere((p) => p.id == e.variantId);
                final price = double.parse(e.unitPrice).toStringAsFixed(0);
                final total = e.total.toStringAsFixed(0);
                return [
                  "${product.name}${e.notes != null && e.notes!.isNotEmpty ? "\n${e.notes}" : ""}",
                  e.quantity.toString(),
                  price,
                  total,
                ];
              }).toList(),
            ),
            pw.Divider(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${l10n.subtotal}: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(invoice.subtotal ?? "0.00"),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${l10n.discount}: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(invoice.discount ?? "0.00"),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${l10n.tax}: ',
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
                  '${l10n.total}: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  invoice.total ?? "0.00",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Divider(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${l10n.paid}: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  invoice.paid ?? "0.00",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${l10n.remaining}: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "${invoice.remaining}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            if (invoice.notes != null && invoice.notes!.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [pw.Text('${l10n.notes}: ${invoice.notes}')],
              ),
            pw.Text('${l10n.user}: $userName'),
            pw.SizedBox(height: 10),
            if (invoice.returnBarcode != null &&
                invoice.returnBarcode!.isNotEmpty)
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: invoice.returnBarcode!,
                  width: 150,
                  height: 50,
                ),
              ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Thank you for your purchase!',
                style: pw.TextStyle(font: arabicFont),
              ),
            ),
            pw.SizedBox(height: 10),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
