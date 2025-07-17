import 'package:flutter/material.dart';
import 'package:interest_book/Provider/interest_provider.dart';
import 'package:interest_book/Utils/amount_formatter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class showInterest extends StatefulWidget {
  final String amount;
  final String date;
  final String note;
  final String loanId;
  const showInterest({
    super.key,
    required this.amount,
    required this.date,
    required this.note,
    required this.loanId,
  });

  @override
  State<showInterest> createState() => _showInterestState();
}

class _showInterestState extends State<showInterest> {
  Future<void> fetchInterestData() async {
    await Provider.of<Interestprovider>(context, listen: false)
        .fetchInterestList(widget.loanId); // ✅ only loanId now
  }

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchInterestData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey.shade300,
        title: Text("Interest"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Consumer<Interestprovider>(
        builder: (context, interestprovider, child) {
          if (interestprovider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (interestprovider.interest.isEmpty) {
            return Center(
              child: Text(
                "No Interest data available.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: interestprovider.interest.length,
              itemBuilder: (context, index) {
                // final customer = interestprovider.interest[index];
                return GestureDetector(
                  // onTap: () => Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (_) => Loandashboard(customer: customer),
                  //   ),
                  // ),
                  child: Card(
                    child: ListTile(
                      title:
                          Text(AmountFormatter.formatCurrencyWithDecimals(interestprovider.interest[index].interestAmount)),
                      subtitle:
                          Text(_formatDisplayDate(interestprovider.interest[index].interestDate)),
                      trailing:
                          Text(interestprovider.interest[index].interestNote),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
