import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Model/CustomerModel.dart';
import '../../Model/LoanDetail.dart';
import '../getLoanDetails.dart';

class LoanDetail extends StatefulWidget {
  final Loandetail detail;
  final Customer customer;

  const LoanDetail({
    super.key,
    required this.detail,
    required this.customer,
  });

  @override
  State<LoanDetail> createState() => LoanDetailState();
}

class LoanDetailState extends State<LoanDetail> {
  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy hh:mm a').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String formatFullDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy').format(parsedDate).toUpperCase();
    } catch (e) {
      return "Invalid Date";
    }
  }

  String formatAmount(double value) {
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return GetLoanDetails(
                detail: widget.detail,
                customer: widget.customer,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Date
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  formatDate(widget.detail.startDate),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Note & Amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Note
                Expanded(
                  child: Text(
                    widget.detail.note,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 10),

                /// Loan Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${widget.detail.amount}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text(
                      "Amount",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "₹${formatAmount(double.parse(widget.detail.totalInterest))}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      "Interest Up to",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      formatFullDate(widget.detail.lastInterestUpdatedAt ??
                          widget.detail.startDate),
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
