import 'package:flutter/material.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Loan/EditLoan.dart';
import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Uncomment if using FontAwesome
import '../../Model/CustomerModel.dart';
import '../../Model/LoanDetail.dart';
import '../../Api/interest.dart';
import '../../Provider/depositeProvider.dart';
import '../../Provider/interestProvider.dart';
import '../../Utils/amount_formatter.dart';
import '../DepositeAmount/add_deposit_screen.dart';
import '../InterestAmount/add_interest_screen.dart';
import '../../Provider/LoanProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../../Utils/whatsapp_helper.dart';

class EntryDetailsScreen extends StatefulWidget {
  final Loandetail loanDetail;
  final Customer customer;

  const EntryDetailsScreen({
    Key? key,
    required this.loanDetail,
    required this.customer,
  }) : super(key: key);

  @override
  State<EntryDetailsScreen> createState() => _EntryDetailsScreenState();
}

class _EntryDetailsScreenState extends State<EntryDetailsScreen> {
  Map<String, dynamic>? calculationData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the context is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    // Load deposits and interest data
    await Provider.of<Depositeprovider>(
      context,
      listen: false,
    ).fetchDepositeList(widget.loanDetail.loanId);
    await Provider.of<Interestprovider>(
      context,
      listen: false,
    ).fetchInterestList(widget.loanDetail.loanId);

    // Load calculation data
    final result = await interestApi().calculateMonthlyInterest(
      widget.loanDetail.loanId,
    );
    setState(() {
      calculationData = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Entry Details'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              // Edit functionality
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => EditLoan(
                        customer: widget.customer,
                        details: widget.loanDetail,
                      ),
                ),
              );

              // If edit was successful, reload data
              if (result == true && mounted) {
                _loadData();

                // Also refresh the loan list in the parent screen
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString("userId");
                if (userId != null) {
                  await Provider.of<LoanProvider>(
                    context,
                    listen: false,
                  ).fetchLoanDetailList(userId, widget.customer.custId);
                }
              }
            },
            child: const Text(
              'EDIT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLoanHeader(),
                    const SizedBox(height: 20),
                    _buildDepositSection(),
                    const SizedBox(height: 20),
                    _buildLoanDetailsSection(),
                    const SizedBox(height: 20),
                    _buildInterestSection(),
                    const SizedBox(height: 30),
                    _buildDeleteButton(),
                  ],
                ),
              ),
    );
  }

  Widget _buildLoanHeader() {
    final remainingBalance =
        calculationData?['remainingBalance']?.toInt() ??
        int.tryParse(widget.loanDetail.updatedAmount) ??
        0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.customer.custName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AmountFormatter.formatCurrency(widget.loanDetail.amount),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'On ${_formatDate(widget.loanDetail.startDate)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Text(
            'Remaining Balance : ${AmountFormatter.formatCurrency(remainingBalance)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositSection() {
    return Consumer<Depositeprovider>(
      builder: (context, depositProvider, child) {
        final totalDeposits = depositProvider.deposite.fold<double>(
          0,
          (sum, deposit) =>
              sum + (double.tryParse(deposit.depositeAmount) ?? 0),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Deposit Capital Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    if (depositProvider.deposite.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.swipe_left,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddDepositScreen(
                              loanId: widget.loanDetail.loanId,
                            ),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (depositProvider.deposite.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: depositProvider.deposite.length,
                  itemBuilder: (context, index) {
                    return _buildDepositCard(depositProvider.deposite[index]);
                  },
                ),
              ),
            SizedBox(height: 20),
            _buildTotalCard('Total Deposit Amount', totalDeposits),
          ],
        );
      },
    );
  }

  Widget _buildDepositCard(deposit) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AmountFormatter.formatCurrency(deposit.depositeAmount),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueGrey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Deposited on',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deposit.depositeDate,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsSection() {
    final months = calculationData?['totalMonths'] ?? 0;
    final rate = double.tryParse(widget.loanDetail.rate) ?? 0;

    // Construct the full image URL
    String? imageUrl;
    if (widget.loanDetail.image.isNotEmpty) {
      // Check if the image path already contains the base URL
      if (widget.loanDetail.image.startsWith('http')) {
        imageUrl = widget.loanDetail.image;
      } else {
        // Ensure there's no double slash between base URL and image path
        final String imagePath =
            widget.loanDetail.image.startsWith('/')
                ? widget.loanDetail.image.substring(1)
                : widget.loanDetail.image;
        imageUrl = "${UrlConstant.showImage}/$imagePath";
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Return Date',
            widget.loanDetail.endDate == "0000-00-00"
                ? "N/A"
                : _formatReturnDate(widget.loanDetail.endDate),
          ),
          _buildDetailRow(
            'Interest',
            AmountFormatter.formatCurrencyWithDecimals(calculationData?['totalAccumulatedInterest'] ?? 0),
          ),
          _buildDetailRow('Months', '$months'),
          _buildDetailRow('Rate', AmountFormatter.formatPercentage(rate)),
          _buildDetailRow('Note', widget.loanDetail.note),
          SizedBox(height: 5),
          // Add loan image
          if (imageUrl != null)
            GestureDetector(
              onTap: () {
                // Show full image when tapped
                showDialog(
                  context: context,
                  builder:
                      (context) => Dialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                            Image.network(
                              imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print("Image error: $error");
                                return const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: Colors.red,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        "Image could not be loaded",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "The image may have been moved or deleted",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                );
              },
              child: Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Image error in header: $error");
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Image not available",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInterestSection() {
    return Consumer<Interestprovider>(
      builder: (context, interestProvider, child) {
        // final totalInterestPaid = interestProvider.interest.fold<double>(
        //   0,
        //   (sum, interest) =>
        //       sum + (double.tryParse(interest.interestAmount) ?? 0),
        // );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Deposit Interest',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    if (interestProvider.interest.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.swipe_left,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddInterestScreen(
                              loanId: widget.loanDetail.loanId,
                            ),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.blueGrey),
                ),
              ],
            ),
            if (interestProvider.interest.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: interestProvider.interest.length,
                  itemBuilder: (context, index) {
                    return _buildInterestCard(interestProvider.interest[index]);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInterestCard(interest) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AmountFormatter.formatCurrencyWithDecimals(interest.interestAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blueGrey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Interest paid',
              style: TextStyle(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            interest.interestDate,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          if (interest.interestNote?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                interest.interestNote,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(String title, double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            AmountFormatter.formatCurrency(amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    print("${UrlConstant.showImage}/${widget.loanDetail.image}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showDeleteDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Delete Transaction',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Loan'),
            content: const Text(
              'Are you sure you want to delete this loan? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement delete functionality
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatReturnDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const monthAbbreviations = [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
      ];

      final monthAbbr = monthAbbreviations[date.month - 1];
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final amPm = date.hour >= 12 ? 'PM' : 'AM';

      return '${date.day} $monthAbbr ${date.year} ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $amPm';
    } catch (e) {
      return dateStr;
    }
  }
}
