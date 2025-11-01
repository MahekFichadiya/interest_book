import 'package:flutter/material.dart';
import '../../Api/interest.dart';
import '../../Model/monthly_interest_calculation.dart';

class MonthlyInterestScreen extends StatefulWidget {
  final String loanId;
  final String customerName;

  const MonthlyInterestScreen({
    Key? key,
    required this.loanId,
    required this.customerName,
  }) : super(key: key);

  @override
  State<MonthlyInterestScreen> createState() => _MonthlyInterestScreenState();
}

class _MonthlyInterestScreenState extends State<MonthlyInterestScreen> {
  MonthlyInterestCalculation? calculation;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInterestCalculation();
  }

  Future<void> _loadInterestCalculation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await interestApi().calculateMonthlyInterest(widget.loanId);
      if (result != null) {
        setState(() {
          calculation = MonthlyInterestCalculation.fromJson(result);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load interest calculation";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interest Calculation'),
        backgroundColor: Colors.blueGrey[300],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInterestCalculation,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : calculation != null
                  ? _buildCalculationDetails()
                  : const Center(child: Text('No data available')),
    );
  }

  Widget _buildCalculationDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loan ID: ${calculation!.loanId}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Loan Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Loan Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Original Amount', calculation!.formattedOriginalAmount),
                  _buildDetailRow('Interest Rate', calculation!.formattedMonthlyInterestRate),
                  _buildDetailRow('Total Deposits', calculation!.formattedTotalDeposits),
                  _buildDetailRow('Remaining Balance', calculation!.formattedRemainingBalance, isHighlight: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Interest Calculation Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interest Calculation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Monthly Interest', calculation!.formattedMonthlyInterest),
                  _buildDetailRow('Total Months', '${calculation!.totalMonths} months'),
                  _buildDetailRow('Total Accumulated Interest', calculation!.formattedTotalAccumulatedInterest),
                  _buildDetailRow('Interest Paid', calculation!.formattedTotalInterestPaid),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary Card
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Net Amount Due',
                    calculation!.formattedNetAmountDue,
                    isHighlight: true,
                    highlightColor: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This includes remaining principal + accumulated interest - interest paid',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isHighlight ? (highlightColor ?? Colors.green) : Colors.black,
              ),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
