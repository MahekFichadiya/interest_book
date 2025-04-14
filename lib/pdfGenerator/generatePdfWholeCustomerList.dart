// ignore_for_file: unnecessary_null_comparison

import 'package:interest_book/Model/customerLoanData.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

Future<void> generatePdfFromData(List<Customerloandata> data) async {
  final pdf = pw.Document();
  final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Customer Loan Interest Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Customer',
                'Date',
                'You Got (+)',
                'You Gave (-)',
              ],
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30,
              data: data.map((row) {
                return [
                  row.custName,
                  row.date != null
                      ? dateFormatter.format(DateTime.parse(row.date))
                      : '-',
                  row.youGotAmount.toString(),
                  row.youGaveAmount.toString(),
                ];
              }).toList(),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
