import 'package:interest_book/Model/getLoanDetailForPDF.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> generatePdfForPerticulatCustomer({
  required List<Getloandetailforpdf> data,
  required String customerName,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Customer Loan Interest Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Loan Report for: $customerName',
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
            pw.Row(
              children: [
                pw.Text(
                  "Report is genrated at: ",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  DateTime.now().toString(),
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Amount',
                'Duration',
                'Start Date',
                'End Date',
                'Loan Note',
              ],
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.blueGrey300,
              ),
              cellHeight: 30,
              data:
                  data.map((row) {
                    return [
                      row.amount,
                      '${row.duration} month',
                      row.startDate,
                      row.endDate ?? 'Not Set',
                      row.loanNote ?? 'Not Set',
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
