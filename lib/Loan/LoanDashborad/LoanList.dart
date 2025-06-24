import 'package:flutter/material.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanDetail.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/CustomerModel.dart';
import 'package:provider/provider.dart';

class LoanList extends StatefulWidget {
  final String? custId;
  final Customer customer;

  const LoanList({super.key, required this.custId, required this.customer});

  @override
  State<LoanList> createState() => _LoanListState();
}

class _LoanListState extends State<LoanList> {
  String? userId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");

    if (userId != null && widget.customer.custId != null) {
      await fetchLoanDetailList();
    }
  }

  Future<void> fetchLoanDetailList() async {
    try {
      // Use simple fetch for faster navigation, fallback to full fetch if needed
      await Provider.of<LoanProvider>(context, listen: false)
          .fetchLoanDetailListSimple(userId, widget.customer.custId);
    } catch (e) {
      // If simple fetch fails, try full fetch with interest calculations
      if (mounted) {
        await Provider.of<LoanProvider>(context, listen: false)
            .fetchLoanDetailList(userId, widget.customer.custId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoanProvider>(
        builder: (context, loanProvider, child) {
          if (loanProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (loanProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(loanProvider.errorMessage));
          } else if (loanProvider.detail.isEmpty) {
            return const Center(
              child: Text(
                "This customer has no loan :)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: loanProvider.detail.length,
              itemBuilder: (context, index) {
                return LoanDetail(
                  detail: loanProvider.detail[index],
                  customer: widget.customer,
                );
              },
            );
          }
        },
      ),
    );
  }
}
