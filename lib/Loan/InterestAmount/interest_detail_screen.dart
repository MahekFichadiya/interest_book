import 'package:flutter/material.dart';
import 'package:interest_book/Model/interestDetail.dart';
import 'package:interest_book/Utils/amount_formatter.dart';
import 'package:intl/intl.dart';

class InterestDetailScreen extends StatelessWidget {
  final Interestdetail interest;

  const InterestDetailScreen({
    Key? key,
    required this.interest,
  }) : super(key: key);

  String _formatDisplayDate(String dateString) {
    try {
      // Parse the date from MySQL format (yyyy-MM-dd)
      final DateTime parsedDate = DateTime.parse(dateString);
      // Format to display format (dd/MM/yyyy)
      return DateFormat("dd/MM/yyyy").format(parsedDate);
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Interest Payment Details'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              
              // Amount Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.payments,
                        size: 48,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Interest Payment',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AmountFormatter.formatCurrencyWithDecimals(interest.interestAmount),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Details Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date
                      _buildDetailRow(
                        'Payment Date',
                        _formatDisplayDate(interest.interestDate),
                        Icons.calendar_today,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Payment Method
                      _buildDetailRow(
                        'Payment Method',
                        (interest.interestField?.toUpperCase() ?? 'CASH'),
                        (interest.interestField == 'online') 
                            ? Icons.credit_card 
                            : Icons.money,
                        valueColor: (interest.interestField == 'online') 
                            ? Colors.green[700] 
                            : Colors.orange[700],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Note
                      _buildDetailRow(
                        'Note',
                        interest.interestNote.isEmpty 
                            ? 'No note provided' 
                            : interest.interestNote,
                        Icons.note,
                        valueColor: interest.interestNote.isEmpty 
                            ? Colors.grey 
                            : Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blueGrey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
