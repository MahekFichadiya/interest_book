import 'package:flutter/material.dart';
import 'package:interest_book/Provider/settled_loan_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../Widgets/history_loan_documents_widget.dart';

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



  // Show loan documents dialog
  void _showLoanDocuments(String loanId, String customerName) {
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Dialog header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_open,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Loan Documents - $customerName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Documents content
                Expanded(
                  child: HistoryLoanDocumentsWidget(
                    loanId: loanId,
                    userId: userId!,
                    customerName: customerName,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
            return RefreshIndicator(
              onRefresh: loadUserIdAndFetchLoans,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      "No settled loans found.\nPull to refresh",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: loadUserIdAndFetchLoans,
            child: ListView.builder(
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
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Loan Icon (removed individual image display)
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blueGrey[100],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              size: 30,
                              color: Colors.blueGrey[600],
                            ),
                          ),
                          // Loan Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "₹${loan.amount}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    const SizedBox(width: 80), // Space for banner
                                  ],
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
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      loan.paymentMode == 'online'
                                        ? Icons.credit_card
                                        : Icons.money,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: loan.paymentMode == 'online'
                                          ? Colors.blue.shade50
                                          : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: loan.paymentMode == 'online'
                                            ? Colors.blue.shade200
                                            : Colors.green.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        loan.paymentMode == 'online' ? 'Online' : 'Cash',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: loan.paymentMode == 'online'
                                            ? Colors.blue.shade700
                                            : Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Documents button
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showLoanDocuments(loan.loanId, custName),
                                        icon: const Icon(
                                          Icons.folder_open,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'View Documents',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey[100],
                                          foregroundColor: Colors.blueGrey[700],
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Banner positioned at top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: loan.type == "1"
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          loan.type == "1" ? "You Gave" : "You Got",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            ),
          );
        },
      ),
    );
  }


}
