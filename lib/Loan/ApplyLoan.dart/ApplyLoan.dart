import 'package:flutter/material.dart';
import 'package:interest_book/Loan/ApplyLoan.dart/LoanToggleButton.dart';
// import 'package:omjavellers/Loan/ApplyLoan.dart/ToggleButtonLoan.dart';

class ApplyLoan extends StatefulWidget {
  final String? customerId;
  const ApplyLoan({super.key, required this.customerId});

  @override
  State<ApplyLoan> createState() => _ApplyLoanState();
}

class _ApplyLoanState extends State<ApplyLoan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade300,
        automaticallyImplyLeading: false,
        title: Text("Apply for a loan"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 30,
            left: 10,
            right: 10,
          ),
          child: LoanToggleButton(
            customerId: widget.customerId,
          ),
        ),
      ),
    );
  }
}
