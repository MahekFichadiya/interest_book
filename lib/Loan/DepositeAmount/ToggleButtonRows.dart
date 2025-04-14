import 'package:flutter/material.dart';
import 'package:interest_book/Loan/DepositeAmount/DepositeCapitalAmount.dart';
import 'package:interest_book/Loan/DepositeAmount/DepositeInterest.dart';
import 'package:interest_book/Model/LoanDetail.dart';

class ToggleButtonsRow extends StatefulWidget {
  final Loandetail? detail;
  const ToggleButtonsRow({super.key, required this.detail});

  @override
  State<ToggleButtonsRow> createState() => _ToggleButtonsRowState();
}

class _ToggleButtonsRowState extends State<ToggleButtonsRow> {
  bool isInterestSelected = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton(
              label: "Interest",
              isSelected: isInterestSelected,
              isLeft: true,
              onTap: () {
                setState(() {
                  isInterestSelected = true;
                });
              },
            ),
            _buildToggleButton(
              label: "Deposite\nAmount",
              isSelected: !isInterestSelected,
              isLeft: false,
              onTap: () {
                setState(() {
                  isInterestSelected = false;
                });
              },
            ),
          ],
        ),
        SizedBox(
          height:
              MediaQuery.of(context).size.height * 0.7, // 70% of screen height
          child: isInterestSelected
              ? DepositeInterest(
                  loanId: widget.detail!.loanId,
                )
              : DepositeCapitalAmount(
                  loanId: widget.detail!.loanId,
                ),
        ),
      ],
    );
  }
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
