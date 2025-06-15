import 'package:flutter/material.dart';
import 'package:interest_book/Api/fetchAllLoansByUserAndCustomer.dart';
import 'package:interest_book/Contact/EditContact.dart';
import 'package:interest_book/Loan/ApplyLoan/ApplyLoan.dart';
import 'package:interest_book/Loan/LoanDashborad/LoanList.dart';
import 'package:interest_book/Provider/CustomerProvider.dart';
import 'package:interest_book/Provider/LoanProvider.dart';
import 'package:interest_book/pdfGenerator/generatePdfForPerticularCustomer.dart';
import 'package:interest_book/Utils/amount_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class Loandashboard extends StatefulWidget {
  final String custId;
  const Loandashboard({super.key, required this.custId});

  @override
  State<Loandashboard> createState() => _LoandashboardState();
}

class _LoandashboardState extends State<Loandashboard> {
  String? userId;

  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    setState(() {});
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Remove this method as we'll use the provider's totals directly

  void _showDeleteDialog(customer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Text(
              'Are you sure you want to delete ${customer.custName}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Add delete functionality here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delete functionality - Coming Soon!'),
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 140, // Fixed width for horizontal scrolling
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF(customer) async {
    try {
      final data = await fetchAllLoansByUserAndCustomer(
        custId: int.parse(customer.custId.toString()),
        userId: int.parse(customer.userId.toString()),
      );

      await generatePdfForPerticulatCustomer(
        data: data,
        customerName: customer.custName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
      }
    }
  }

  Future<void> _navigateToAddLoan(customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplyLoan(customerId: customer.custId),
      ),
    );

    if (result == 'loan_added' && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId != null && mounted) {
        Provider.of<LoanProvider>(
          context,
          listen: false,
        ).fetchLoanDetailList(userId, widget.custId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = Provider.of<CustomerProvider>(
      context,
    ).getCustomerById(widget.custId);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Customer Not Found"),
          backgroundColor: Colors.blueGrey[700],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "Customer not found",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Customer ID: ${widget.custId}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  // Refresh customer list and try again
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString("userId");
                  if (userId != null && mounted) {
                    await Provider.of<CustomerProvider>(context, listen: false)
                        .fetchCustomerList(userId);
                    setState(() {}); // Trigger rebuild
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 'Success');
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          customer.custName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => _makePhoneCall(customer.custPhn),
            icon: const Icon(Icons.phone),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'edit') {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditContact(customer: customer),
                  ),
                );
                if (updated == true) setState(() {});
              } else if (value == 'delete') {
                _showDeleteDialog(customer);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Colors.blueGrey),
                      title: Text('Edit Customer'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete Customer'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Customer Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Customer Info Row - Centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Customer Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Customer Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          customer.custName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.custPhn,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Buttons - Centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.picture_as_pdf,
                      color: Colors.red,
                      onTap: () => _generatePDF(customer),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.phone,
                      color: Colors.green,
                      onTap: () => _makePhoneCall(customer.custPhn),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.message,
                      color: Colors.blue,
                      onTap: () {
                        // Message functionality
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Financial Summary Cards - Real-time updates
                Consumer<LoanProvider>(
                  builder: (context, loanProvider, child) {
                    final totals = loanProvider.totals;
                    return SizedBox(
                      height: 120, // Fixed height for the horizontal scroll view
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        children: [
                          _buildSummaryCard(
                            'Total Amount',
                            AmountFormatter.formatCurrency(totals['totalAmount']),
                            Colors.red,
                            Icons.account_balance_wallet,
                          ),
                          _buildSummaryCard(
                            'Interest',
                            AmountFormatter.formatCurrency(totals['totalInterest']),
                            Colors.orange,
                            Icons.trending_up,
                          ),
                          _buildSummaryCard(
                            'Total Due',
                            AmountFormatter.formatCurrency(totals['totalDue']),
                            Colors.blueGrey,
                            Icons.payment,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Loans Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Loan List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _navigateToAddLoan(customer),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Loan'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey[700],
                  ),
                ),
              ],
            ),
          ),

          // Loans List
          Expanded(
            child: LoanList(custId: customer.custId, customer: customer),
          ),
        ],
      ),
    );
  }
}
