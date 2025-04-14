import 'package:flutter/material.dart';
import 'package:interest_book/Loan/ApplyLoan.dart/YouGaveLoan.dart';
import 'package:interest_book/Loan/ApplyLoan.dart/YouGotLoan.dart';

class LoanToggleButton extends StatefulWidget {
  final String? customerId;
  const LoanToggleButton({super.key, required this.customerId});

  @override
  State<LoanToggleButton> createState() => _LoanToggleButtonState();
}

class _LoanToggleButtonState extends State<LoanToggleButton> {
  bool isYouGive = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton(
              label: "You Gave ₹",
              isSelected: isYouGive,
              isLeft: true,
              onTap: () {
                setState(() {
                  isYouGive = true;
                });
              },
            ),
            _buildToggleButton(
              label: "You Got ₹",
              isSelected: !isYouGive,
              isLeft: false,
              onTap: () {
                setState(() {
                  isYouGive = false;
                });
              },
            ),
          ],
        ),
        SizedBox(
          height:
              MediaQuery.of(context).size.height * 0.7, // 70% of screen height
          child: isYouGive
              ? YouGaveLone(
                  customerId: widget.customerId,
                )
              : YouGotLone(customerId: widget.customerId,),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueGrey[400] : Colors.white,
            border: Border.all(width: 2),
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? Radius.circular(30) : Radius.zero,
              bottomLeft: isLeft ? Radius.circular(30) : Radius.zero,
              topRight: isLeft ? Radius.zero : Radius.circular(30),
              bottomRight: isLeft ? Radius.zero : Radius.circular(30),
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
