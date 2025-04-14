import 'package:flutter/material.dart';
import 'package:interest_book/Loan/DepositeAmount/ToggleButtonRows.dart';
import 'package:interest_book/Model/LoanDetail.dart';

class Depositeinterest extends StatefulWidget {
  final Loandetail? detail;
  const Depositeinterest({super.key, required this.detail});

  @override
  State<Depositeinterest> createState() => _DepositeinterestState();
}

class _DepositeinterestState extends State<Depositeinterest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Enter Amount Detail"),
        backgroundColor: Colors.blueGrey.shade300,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 30,
            right: 10,
            left: 10,
          ),
          child: ToggleButtonsRow(
            detail: widget.detail,
          ),
        ),
      ),
    );
  }
}
