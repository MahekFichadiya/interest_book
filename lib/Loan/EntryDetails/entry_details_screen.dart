import 'package:flutter/material.dart';
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Loan/EditLoan.dart';
import 'package:interest_book/Provider/deposite_provider.dart';
import 'package:interest_book/Provider/interest_provider.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Uncomment if using FontAwesome
import '../../Model/CustomerModel.dart';
import '../../Model/LoanDetail.dart';
import '../../Api/interest.dart';
import '../../Utils/amount_formatter.dart';
import '../../Widgets/interest_amount_display.dart';
import '../DepositeAmount/add_deposit_screen.dart';
import '../InterestAmount/add_interest_screen.dart';
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

  // Calculate remaining balance immediately from current data
  int _calculateRemainingBalance(Loandetail loan, List<dynamic> deposits) {
    final originalAmount = double.tryParse(loan.amount) ?? 0.0;
    final totalDeposits = deposits.fold<double>(
      0.0,
      (sum, deposit) => sum + (double.tryParse(deposit.depositeAmount) ?? 0.0),
    );
    return (originalAmount - totalDeposits).clamp(0.0, double.infinity).toInt();
  }

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the context is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Load deposits and interest data
      if (mounted) {
        await Provider.of<Depositeprovider>(
          context,
          listen: false,
        ).fetchDepositeList(widget.loanDetail.loanId);
      }

      if (mounted) {
        await Provider.of<Interestprovider>(
          context,
          listen: false,
        ).fetchInterestList(widget.loanDetail.loanId);
      }

      // Refresh loan data to get updated amounts
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      final custId = prefs.getString("custId");

      if (userId != null && mounted) {
        await Provider.of<LoanProvider>(context, listen: false)
            .fetchLoanDetailList(userId, custId);
      }

      // Load calculation data with fresh loan information
      final result = await interestApi().calculateMonthlyInterest(
        widget.loanDetail.loanId,
      );

      if (mounted) {
        setState(() {
          calculationData = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Entry Details'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // Store context reference before async operations
            final navigator = Navigator.of(context);

            // Refresh loan data before going back to ensure consistency
            try {
              if (mounted) {
                final loanProvider = Provider.of<LoanProvider>(context, listen: false);
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString("userId");
                if (userId != null && mounted) {
                  // Use simple fetch for faster navigation
                  await loanProvider.fetchLoanDetailListSimple(userId, widget.customer.custId);
                }
              }
            } catch (e) {
              // If refresh fails, still allow navigation
              debugPrint('Failed to refresh data on back navigation: $e');
            }

            // Navigate back
            if (mounted) {
              navigator.pop();
            }
          },
        ),
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
    return Consumer2<LoanProvider, Depositeprovider>(
      builder: (context, loanProvider, depositProvider, child) {
        // Find the current loan from the provider to get the most up-to-date data
        final currentLoan = loanProvider.detail.firstWhere(
          (loan) => loan.loanId == widget.loanDetail.loanId,
          orElse: () => widget.loanDetail,
        );

        // Calculate remaining balance immediately from current data
        final calculatedRemainingBalance = _calculateRemainingBalance(currentLoan, depositProvider.deposite);

        // Use calculated balance for immediate updates, fallback to API data
        final remainingBalance = calculatedRemainingBalance;

        return _buildLoanHeaderContent(currentLoan, remainingBalance);
      },
    );
  }

  Widget _buildLoanHeaderContent(Loandetail currentLoan, int remainingBalance) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
            AmountFormatter.formatCurrency(currentLoan.amount),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'On ${_formatDate(currentLoan.startDate)}',
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
                      // Force immediate UI refresh for both providers
                      if (mounted) {
                        Provider.of<Depositeprovider>(context, listen: false).forceRefresh();
                        Provider.of<LoanProvider>(context, listen: false).forceRefresh();
                        // Then load fresh data in background
                        _loadData();
                      }
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
    final rate = double.tryParse(widget.loanDetail.rate) ?? 0;

    // Calculate months passed since loan started
    final monthsPassed = _calculateMonthsPassed(widget.loanDetail.startDate);

    // Calculate daily interest from monthly interest (interest ÷ 30)
    final monthlyInterest = double.tryParse(widget.loanDetail.interest) ?? 0;
    final dailyInterest = monthlyInterest / 30;

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
          InterestDetailRow(
            label: 'Interest',
            totalInterest: widget.loanDetail.totalInterest,
          ),
          _buildDetailRow('Months Passed', '$monthsPassed'),
          _buildDetailRow('Rate', AmountFormatter.formatPercentage(rate)),
          _buildDetailRow('Note', widget.loanDetail.note),
          _buildDetailRow(
            'Daily Interest',
            AmountFormatter.formatCurrencyWithDecimals(dailyInterest),
          ),
          const SizedBox(height: 16),
          // Enhanced loan image section
          _buildLoanImageSection(imageUrl),
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
                      // Force immediate UI refresh
                      if (mounted) {
                        Provider.of<LoanProvider>(context, listen: false).forceRefresh();
                        // Then load fresh data
                        await _loadData();
                      }
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

  int _calculateMonthsPassed(String startDateStr) {
    try {
      final startDate = DateTime.parse(startDateStr);
      final currentDate = DateTime.now();

      // Calculate the difference in months
      int months = (currentDate.year - startDate.year) * 12 +
                   (currentDate.month - startDate.month);

      // If the current day is before the start day, subtract one month
      if (currentDate.day < startDate.day) {
        months--;
      }

      return months.clamp(0, double.infinity).toInt();
    } catch (e) {
      return 0;
    }
  }

  Widget _buildLoanImageSection(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildNoImagePlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: Colors.blueGrey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Loan Document',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Image container with enhanced design
        GestureDetector(
          onTap: () => _showFullScreenImage(imageUrl),
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Main image
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildImageLoadingPlaceholder();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImageErrorPlaceholder();
                    },
                  ),

                  // Gradient overlay for better text visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Tap to view indicator
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blueGrey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in,
                            size: 16,
                            color: Colors.blueGrey[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to view',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blueGrey[200]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 40,
            color: Colors.blueGrey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No document attached',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading image...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to retry',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Background overlay
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),

            // Image container with zoom functionality
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 32,
                  maxHeight: MediaQuery.of(context).size.height - 100,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 300,
                          height: 300,
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 300,
                          height: 200,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                                color: Colors.red[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Failed to load image",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "The image may have been moved or deleted",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
