import 'package:flutter/material.dart';
import 'package:interest_book/Provider/settled_loan_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class Settledloanlist extends StatefulWidget {
  const Settledloanlist({super.key});

  @override
  State<Settledloanlist> createState() => _SettledloanlistState();
}

class _SettledloanlistState extends State<Settledloanlist> {
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchLoans();
  }

  Future<void> loadUserIdAndFetchLoans() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    print("Fetched userId from prefs: $userId");

    if (userId != null) {
      print("Calling provider to fetch settled loans...");
      await Provider.of<Settledloanprovider>(context, listen: false)
          .fetchLoanDetailList(userId!, null);
    } else {
      print("User ID is null, can't fetch loans");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Settled Loans"),
        backgroundColor: Colors.blueGrey[300],
        elevation: 0,
      ),
      body: Consumer<Settledloanprovider>(
        builder: (context, settledLoanProvider, child) {
          if (settledLoanProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (settledLoanProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                settledLoanProvider.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (settledLoanProvider.detail.isEmpty) {
            return const Center(
              child: Text(
                "No settled loans found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: settledLoanProvider.detail.length,
            itemBuilder: (context, index) {
              final loan = settledLoanProvider.detail[index];
              final custName =
                  loan.custName.trim().isNotEmpty ? loan.custName : 'Unknown';

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "₹${loan.amount}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Customer: $custName",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.percent,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("Rate: ${loan.rate}%",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("Start: ${loan.startDate}",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.note, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Note: ${loan.note}",
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
