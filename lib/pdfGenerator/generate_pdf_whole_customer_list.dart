// ignore_for_file: unnecessary_null_comparison

import 'package:interest_book/Model/customerLoanData.dart';
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

Future<void> generatePdfFromData(List<Customerloandata> data, {
  String? userName,
  String? userEmail,
  String? userPhone,
  double? totalYouGave,
  double? totalYouGot,
  double? totalYouGaveInterest,
  double? totalYouGotInterest,
  double? totalInterest,
}) async {
  try {
    print('Starting Profile PDF generation');
    print('Data count: ${data.length}');

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormatter = DateFormat('dd MMMM yyyy hh:mm a');

    // Calculate totals if not provided
    double calculatedYouGave = totalYouGave ?? 0;
    double calculatedYouGot = totalYouGot ?? 0;
    double calculatedYouGaveInterest = totalYouGaveInterest ?? 0;
    double calculatedYouGotInterest = totalYouGotInterest ?? 0;
    double calculatedTotalInterest = totalInterest ?? 0;
    double netBalance = 0;

    if (totalYouGave == null || totalYouGot == null || totalYouGaveInterest == null || totalYouGotInterest == null) {
      for (var customer in data) {
        calculatedYouGave += double.tryParse(customer.youGaveAmount) ?? 0;
        calculatedYouGot += double.tryParse(customer.youGotAmount) ?? 0;
        calculatedYouGaveInterest += double.tryParse(customer.youGaveInterest) ?? 0;
        calculatedYouGotInterest += double.tryParse(customer.youGotInterest) ?? 0;
      }
      calculatedTotalInterest = calculatedYouGaveInterest + calculatedYouGotInterest;
    }

    double totalCalculatedYouGave = calculatedYouGave + calculatedYouGaveInterest;
    double totalCalculatedYouGot = calculatedYouGot + calculatedYouGotInterest;
    netBalance = totalCalculatedYouGot - totalCalculatedYouGave;

    print('Calculated totals - You Gave: $calculatedYouGave, You Got: $calculatedYouGot, Net: $netBalance');

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
                      'Overall Business Report',
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
                            if (userName != null) ...[
                              pw.SizedBox(height: 8),
                              pw.Text(
                                'Business Owner:',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                userName,
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ],
                            if (userEmail != null) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Email:',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                userEmail,
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ],
                            if (userPhone != null) ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Phone:',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                userPhone,
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Total Customers:',
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
                              'Net Balance:',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              _formatCurrency(netBalance.abs()),
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: netBalance >= 0 ? PdfColors.green : PdfColors.red,
                              ),
                            ),
                            pw.Text(
                              netBalance >= 0 ? '(You will receive)' : '(You need to pay)',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: netBalance >= 0 ? PdfColors.green : PdfColors.red,
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

              // Business Summary Section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Business Summary',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Principal Amount You Gave:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              pw.Text(_formatCurrency(calculatedYouGave), style: const pw.TextStyle(fontSize: 11)),
                              pw.SizedBox(height: 4),
                              pw.Text('Interest on You Gave:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              pw.Text(_formatCurrency(calculatedYouGaveInterest), style: const pw.TextStyle(fontSize: 11)),
                              pw.SizedBox(height: 4),
                              pw.Text('Total You Gave:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                              pw.Text(_formatCurrency(totalCalculatedYouGave), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Principal Amount You Got:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              pw.Text(_formatCurrency(calculatedYouGot), style: const pw.TextStyle(fontSize: 11)),
                              pw.SizedBox(height: 4),
                              pw.Text('Interest on You Got:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              pw.Text(_formatCurrency(calculatedYouGotInterest), style: const pw.TextStyle(fontSize: 11)),
                              pw.SizedBox(height: 4),
                              pw.Text('Total You Got:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                              pw.Text(_formatCurrency(totalCalculatedYouGot), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Total Interest:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              pw.Text(_formatCurrency(calculatedYouGaveInterest + calculatedYouGotInterest), style: const pw.TextStyle(fontSize: 11)),
                              pw.SizedBox(height: 4),
                              pw.Text('Net Balance:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                _formatCurrency(netBalance.abs()),
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: netBalance >= 0 ? PdfColors.green : PdfColors.red,
                                ),
                              ),
                              pw.Text(
                                netBalance >= 0 ? '(You will receive)' : '(You need to pay)',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: netBalance >= 0 ? PdfColors.green : PdfColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Customer Data Table
              if (data.isNotEmpty) ...[
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(30),  // S.NO
                    1: const pw.FlexColumnWidth(2),    // CUSTOMER NAME
                    2: const pw.FixedColumnWidth(60),  // DATE
                    3: const pw.FixedColumnWidth(60),  // PRINCIPAL GAVE
                    4: const pw.FixedColumnWidth(60),  // PRINCIPAL GOT
                    5: const pw.FixedColumnWidth(60),  // INTEREST GAVE
                    6: const pw.FixedColumnWidth(60),  // INTEREST GOT
                    7: const pw.FixedColumnWidth(60),  // TOTAL GAVE
                    8: const pw.FixedColumnWidth(60),  // TOTAL GOT
                    9: const pw.FixedColumnWidth(60),  // BALANCE
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.amber,
                      ),
                      children: [
                        _buildTableCell('S.NO', isHeader: true),
                        _buildTableCell('CUSTOMER NAME', isHeader: true),
                        _buildTableCell('DATE', isHeader: true),
                        _buildTableCell('PRINCIPAL\nGAVE', isHeader: true),
                        _buildTableCell('PRINCIPAL\nGOT', isHeader: true),
                        _buildTableCell('INTEREST\nGAVE', isHeader: true),
                        _buildTableCell('INTEREST\nGOT', isHeader: true),
                        _buildTableCell('TOTAL\nGAVE', isHeader: true),
                        _buildTableCell('TOTAL\nGOT', isHeader: true),
                        _buildTableCell('BALANCE', isHeader: true),
                      ],
                    ),
                    // Data Rows
                    ...data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final customer = entry.value;

                      final principalGave = double.tryParse(customer.youGaveAmount) ?? 0;
                      final principalGot = double.tryParse(customer.youGotAmount) ?? 0;
                      final interestGave = double.tryParse(customer.youGaveInterest) ?? 0;
                      final interestGot = double.tryParse(customer.youGotInterest) ?? 0;
                      final totalGave = double.tryParse(customer.totalYouGave) ?? 0;
                      final totalGot = double.tryParse(customer.totalYouGot) ?? 0;
                      final balance = double.tryParse(customer.balance) ?? 0;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: index % 2 == 0 ? PdfColors.white : PdfColors.grey50,
                        ),
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell(customer.custName),
                          _buildTableCell(_formatDate(customer.date)),
                          _buildTableCell(_formatCurrency(principalGave)),
                          _buildTableCell(_formatCurrency(principalGot)),
                          _buildTableCell(_formatCurrency(interestGave)),
                          _buildTableCell(_formatCurrency(interestGot)),
                          _buildTableCell(_formatCurrency(totalGave)),
                          _buildTableCell(_formatCurrency(totalGot)),
                          _buildTableCell(_formatCurrency(balance.abs())),
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
                        _buildTableCell('TOTAL', isHeader: true),
                        _buildTableCell('', isHeader: true),
                        _buildTableCell(_formatCurrency(calculatedYouGave), isHeader: true),
                        _buildTableCell(_formatCurrency(calculatedYouGot), isHeader: true),
                        _buildTableCell(_formatCurrency(netBalance.abs()), isHeader: true),
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
                      'No customer data found',
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

              // Summary Section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.Column(
                          children: [
                            pw.Text(
                              'Total You Gave',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              _formatCurrency(calculatedYouGave),
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text(
                              'Total You Got',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              _formatCurrency(calculatedYouGot),
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text(
                              'Net Balance',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              _formatCurrency(netBalance.abs()),
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: netBalance >= 0 ? PdfColors.green : PdfColors.red,
                              ),
                            ),
                            pw.Text(
                              netBalance >= 0 ? '(Receivable)' : '(Payable)',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: netBalance >= 0 ? PdfColors.green : PdfColors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

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
    print('Profile PDF generation completed successfully');
  } catch (e) {
    print('Error generating Profile PDF: $e');
    rethrow;
  }
}
