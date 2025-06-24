import 'package:interest_book/Model/getLoanDetailForPDF.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

// Helper function to format currency for PDF
String _formatCurrency(double amount) {
  final formatter = NumberFormat('#,##,##0.00', 'en_IN');
  return 'Rs. ${formatter.format(amount)}';
}

// Helper function to format date
String _formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return dateStr;
  }
}

// Helper function to build table cells
pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: isHeader ? 10 : 9,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: isHeader ? PdfColors.black : PdfColors.grey800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

Future<void> generatePdfForPerticulatCustomer({
  required List<Getloandetailforpdf> data,
  required String customerName,
  Map<String, dynamic>? totals,
  String? customerPhone,
}) async {
  try {
    print('Starting PDF generation for customer: $customerName');
    print('Data count: ${data.length}');
    print('Totals: $totals');

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormatter = DateFormat('dd MMMM yyyy hh:mm a');

    // Calculate totals if not provided
    double totalAmount = 0;
    double totalInterest = 0;
    double totalDue = 0;

    if (totals != null) {
      totalAmount = totals['totalAmount']?.toDouble() ?? 0;
      totalInterest = totals['totalInterest']?.toDouble() ?? 0;
      totalDue = totals['totalDue']?.toDouble() ?? 0;
    } else {
      // Calculate from data if totals not provided
      for (var loan in data) {
        totalAmount += loan.amount.toDouble();
        // Parse interest details if available
        if (loan.interestDetails != null && loan.interestDetails!.isNotEmpty) {
          // Extract interest amounts from the concatenated string
          final interestParts = loan.interestDetails!.split(' | ');
          for (var part in interestParts) {
            if (part.contains('Amount: ')) {
              final amountStr = part.split('Amount: ')[1].split(',')[0];
              totalInterest += double.tryParse(amountStr) ?? 0;
            }
          }
        }
      }
      totalDue = totalAmount + totalInterest;
    }

    print('Calculated totals - Amount: $totalAmount, Interest: $totalInterest, Due: $totalDue');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Section
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Transaction Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Report Generated At:',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            dateFormatter.format(now),
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Customer Name:',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            customerName,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          if (customerPhone != null) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Phone:',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              customerPhone,
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Number of Transactions:',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${data.length}',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'They will pay you:',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            _formatCurrency(totalDue),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Transaction Table
            if (data.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),  // S.NO
                  1: const pw.FixedColumnWidth(80),  // DATE
                  2: const pw.FixedColumnWidth(80),  // RETURN DATE
                  3: const pw.FixedColumnWidth(80),  // DURATION
                  4: const pw.FixedColumnWidth(80),  // AMOUNT
                  5: const pw.FixedColumnWidth(80),  // INTEREST
                  6: const pw.FlexColumnWidth(),     // REMARKS
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.amber,
                    ),
                    children: [
                      _buildTableCell('S.NO', isHeader: true),
                      _buildTableCell('DATE', isHeader: true),
                      _buildTableCell('RETURN\nDATE', isHeader: true),
                      _buildTableCell('DURATION', isHeader: true),
                      _buildTableCell('AMOUNT', isHeader: true),
                      _buildTableCell('INTEREST', isHeader: true),
                      _buildTableCell('REMARKS', isHeader: true),
                    ],
                  ),
                  // Data Rows
                  ...data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final loan = entry.value;

                    // Parse interest amount from details
                    double interestAmount = 0;
                    if (loan.interestDetails != null && loan.interestDetails!.isNotEmpty) {
                      final interestParts = loan.interestDetails!.split(' | ');
                      for (var part in interestParts) {
                        if (part.contains('Amount: ')) {
                          final amountStr = part.split('Amount: ')[1].split(',')[0];
                          interestAmount += double.tryParse(amountStr) ?? 0;
                        }
                      }
                    }

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: index % 2 == 0 ? PdfColors.white : PdfColors.grey50,
                      ),
                      children: [
                        _buildTableCell('${index + 1}'),
                        _buildTableCell(_formatDate(loan.startDate)),
                        _buildTableCell(loan.endDate != null && loan.endDate != "0000-00-00"
                            ? _formatDate(loan.endDate!)
                            : 'N/A'),
                        _buildTableCell('${loan.duration} Months'),
                        _buildTableCell(_formatCurrency(loan.amount.toDouble())),
                        _buildTableCell(_formatCurrency(interestAmount)),
                        _buildTableCell(loan.loanNote ?? 'N/A'),
                      ],
                    );
                  }),
                  // Total Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.amber,
                    ),
                    children: [
                      _buildTableCell('', isHeader: true),
                      _buildTableCell('', isHeader: true),
                      _buildTableCell('', isHeader: true),
                      _buildTableCell('', isHeader: true),
                      _buildTableCell('TOTAL', isHeader: true),
                      _buildTableCell(_formatCurrency(totalInterest), isHeader: true),
                      _buildTableCell(_formatCurrency(totalDue), isHeader: true),
                    ],
                  ),
                ],
              ),
            ] else ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'No transactions found for this customer',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ),
            ],

            pw.Spacer(),

            // Footer
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Download Interest Book',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generated by Interest Book App',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
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

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    print('PDF generation completed successfully');
  } catch (e) {
    print('Error generating PDF: $e');
    rethrow;
  }
}
