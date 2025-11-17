import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ponit_of_sales/models/report.dart';

Future<Uint8List> generateReportPdf(Report report) async {
  final fontData = await rootBundle.load('assets/fonts/notosansarabic.ttf');
  final imageData = await rootBundle.load('assets/logo/logo.png');
  final arabicFont = pw.Font.ttf(fontData.buffer.asByteData());
  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
  );

  final image = pw.MemoryImage(imageData.buffer.asUint8List());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
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
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'تقرير مالي',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildReportHeader(report),
            pw.SizedBox(height: 24),
            _buildFinancialSummary(report, arabicFont),
            pw.SizedBox(height: 24),
            _buildActivitySummary(report),
          ],
        );
      },
    ),
  );
  return pdf.save();
}

pw.Widget _buildReportHeader(Report report) {
  return pw.Table(
    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    children: [
      _buildTableRow('رقم التقرير:', '#${report.id}'),
      _buildTableRow('النوع:', report.reportType.toUpperCase()),
      _buildTableRow(
        'الفترة:',
        '${DateFormat.yMd().format(report.startDate)} - ${DateFormat.yMd().format(report.endDate)}',
      ),
    ],
  );
}

pw.Widget _buildFinancialSummary(Report report, pw.Font font) {
  final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font);

  return pw.Table(
    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    children: [
      _buildTableRow('ملخص مالي', '', style: boldStyle),
      _buildTableRow('إجمالي المبيعات:', report.totalSales),
      _buildTableRow('إجمالي الإيداعات:', report.totalDeposits),
      _buildTableRow('إجمالي المصاريف:', report.totalExpenses),
      _buildTableRow('إجمالي السحوبات:', report.totalWithdraws),
      _buildTableRow('صافي الربح:', report.netProfit, style: boldStyle),
    ],
  );
}

pw.Widget _buildActivitySummary(Report report) {
  return pw.Table(
    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    children: [
      _buildTableRow(
        'ملخص النشاط',
        '',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      _buildTableRow('إجمالي الفواتير:', report.totalInvoices.toString()),
      _buildTableRow('المنتجات المباعة:', report.totalProductsSold.toString()),
      _buildTableRow(
        'المنتجات المرتجعة:',
        report.totalProductsReturned.toString(),
      ),
    ],
  );
}

pw.TableRow _buildTableRow(String label, String value, {pw.TextStyle? style}) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          value,
          style: style,
          textDirection: pw.TextDirection.rtl,
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          label,
          style: style,
          textDirection: pw.TextDirection.rtl,
        ),
      ),
    ],
  );
}
