import 'package:flutter/material.dart';
import 'package:interest_book/Api/remove_loan.dart';
import 'package:interest_book/Api/loan_document_api.dart';
import 'package:interest_book/DashboardScreen.dart';
import 'package:interest_book/Loan/EditLoan.dart';
import 'package:interest_book/Model/LoanDocument.dart';
import 'package:interest_book/Provider/customer_provider.dart';
import 'package:interest_book/Provider/deposite_provider.dart';
import 'package:interest_book/Provider/interest_provider.dart';
import 'package:interest_book/Provider/loan_provider.dart';
import 'package:interest_book/Provider/profile_provider.dart';
import 'package:interest_book/Widgets/enhanced_loan_deletion_dialog.dart';
import 'package:interest_book/Widgets/loan_document_full_screen_viewer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Uncomment if using FontAwesome
import '../../Model/CustomerModel.dart';
import '../../Model/LoanDetail.dart';
import '../../Api/interest.dart';
import '../../Utils/amount_formatter.dart';
import '../../Widgets/interest_amount_display.dart';
import '../DepositeAmount/add_deposit_screen.dart';
import '../DepositeAmount/deposit_detail_screen.dart';
import '../InterestAmount/add_interest_screen.dart';
import '../InterestAmount/interest_detail_screen.dart';
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
  late Loandetail currentLoanDetail; // Current loan detail that can be updated
  List<LoanDocument> loanDocuments = [];
  bool isLoadingDocuments = false;

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
    // Initialize current loan detail with the passed data
    currentLoanDetail = widget.loanDetail;
    // Use addPostFrameCallback to ensure the context is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadLoanDocuments();
    });
  }

  Future<void> _loadLoanDocuments() async {
    if (!mounted) return;

    setState(() => isLoadingDocuments = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");

      print("DEBUG: Loading documents for loanId: ${currentLoanDetail.loanId}, userId: $userId");

      if (userId != null) {
        final documents = await LoanDocumentApi().getLoanDocuments(
          currentLoanDetail.loanId,
          userId
        );

        print("DEBUG: Loaded ${documents.length} documents");
        for (var doc in documents) {
          print("DEBUG: Document - ID: ${doc.documentId}, Path: ${doc.documentPath}");
        }

        if (mounted) {
          setState(() {
            loanDocuments = documents;
            isLoadingDocuments = false;
          });
        }
      } else {
        print("DEBUG: UserId is null");
        if (mounted) {
          setState(() {
            isLoadingDocuments = false;
          });
        }
      }
    } catch (e) {
      print("ERROR loading loan documents: $e");
      if (mounted) {
        setState(() {
          isLoadingDocuments = false;
        });
      }
    }
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
        ).fetchDepositeList(currentLoanDetail.loanId);
      }

      if (mounted) {
        await Provider.of<Interestprovider>(
          context,
          listen: false,
        ).fetchInterestList(currentLoanDetail.loanId);
      }

      // Refresh loan data to get updated amounts
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      // Use the customer ID from the widget, fallback to loan detail custId
      String custId = widget.customer.custId ?? '';
      if (custId.isEmpty) {
        custId = currentLoanDetail.custId;
      }

      // Debug logging
      print("Debug - userId: $userId, custId: $custId");
      print("Debug - customer object: ${widget.customer.custName}");
      print("Debug - loan custId: ${currentLoanDetail.custId}");

      if (userId != null && custId.isNotEmpty && mounted) {
        await Provider.of<LoanProvider>(context, listen: false)
            .fetchLoanDetailList(userId, custId);

        // Update current loan detail with fresh data from provider
        _updateCurrentLoanDetail();
      } else {
        print("Debug - Skipping fetchLoanDetailList: userId=$userId, custId=$custId");
      }

      // Load calculation data with fresh loan information
      final result = await interestApi().calculateMonthlyInterest(
        currentLoanDetail.loanId,
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

  // Update current loan detail with fresh data from provider
  void _updateCurrentLoanDetail() {
    if (!mounted) return;

    final loanProvider = Provider.of<LoanProvider>(context, listen: false);
    final updatedLoan = loanProvider.detail.firstWhere(
      (loan) => loan.loanId == currentLoanDetail.loanId,
      orElse: () => currentLoanDetail, // Keep current if not found
    );

    setState(() {
      currentLoanDetail = updatedLoan;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // Store context reference before async operations
            final navigator = Navigator.of(context);
            final loanProvider = Provider.of<LoanProvider>(context, listen: false);

            // Refresh loan data before going back to ensure consistency
            try {
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString("userId");
              if (userId != null && mounted) {
                // Use simple fetch for faster navigation
                await loanProvider.fetchLoanDetailListSimple(userId, widget.customer.custId);
              }
            } catch (e) {
              // If refresh fails, still allow navigation
              debugPrint('Failed to refresh data on back navigation: $e');
            }

            // Navigate back
            if (mounted) {
              navigator.pop('refreshed'); // Return a result to indicate refresh was attempted
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
                        details: currentLoanDetail,
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
        // Use the current loan detail which is already updated
        final currentLoan = currentLoanDetail;

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
          const SizedBox(height: 8),
          // Add Total Interest Paid in the header
          Consumer<Interestprovider>(
            builder: (context, interestProvider, child) {
              // Calculate total interest paid from all interest payments
              final totalInterestPaid = interestProvider.interest.fold<double>(
                0.0,
                (sum, interest) => sum + (double.tryParse(interest.interestAmount) ?? 0.0),
              );

              return Text(
                'Total Interest Paid : ${AmountFormatter.formatCurrency(totalInterestPaid.toInt())}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              );
            },
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
                              loanId: currentLoanDetail.loanId,
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
                height: 130, // Increased height to accommodate payment method badges
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
    return GestureDetector(
      onTap: () {
        // Show SnackBar on tap
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Do long press'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onLongPress: () {
        _showDepositContextMenu(context, deposit);
      },
      child: Container(
        width: 170, // Increased width to accommodate new content
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10), // Reduced padding slightly
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Prevent overflow
        children: [
          Text(
            AmountFormatter.formatCurrency(deposit.depositeAmount),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Deposited on',
                  style: TextStyle(fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: (deposit.depositeField == 'online')
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: (deposit.depositeField == 'online')
                        ? Colors.green[300]!
                        : Colors.orange[300]!,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (deposit.depositeField == 'online')
                          ? Icons.credit_card
                          : Icons.money,
                      size: 8,
                      color: (deposit.depositeField == 'online')
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      deposit.depositeField?.toUpperCase() ?? 'CASH',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: (deposit.depositeField == 'online')
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            _formatDisplayDate(deposit.depositeDate),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ), // Close Container
    ); // Close GestureDetector
  }

  void _showDepositContextMenu(BuildContext context, deposit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Deposit Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
              const SizedBox(height: 16),

              // View option
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DepositDetailScreen(deposit: deposit),
                    ),
                  );
                },
              ),

              // Delete option
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Deposit'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, deposit);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, deposit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Deposit'),
          content: Text(
            'Are you sure you want to delete this deposit of ${AmountFormatter.formatCurrency(deposit.depositeAmount)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteDeposit(deposit);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDeposit(deposit) async {
    try {
      final success = await Provider.of<Depositeprovider>(context, listen: false)
          .deleteDeposit(deposit.depositeId);

      if (success) {
        // Refresh loan data to update totals
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString("userId");
        // Use the customer ID from the widget, fallback to loan detail custId
        String custId = widget.customer.custId ?? '';
        if (custId.isEmpty) {
          custId = currentLoanDetail.custId;
        }

        if (mounted && userId != null && custId.isNotEmpty) {
          await Provider.of<LoanProvider>(context, listen: false)
              .fetchLoanDetailList(userId, custId);

          // Also refresh the profile provider to update profile screen amounts
          if (mounted) {
            await Provider.of<ProfileProvider>(context, listen: false)
                .fetchMoneyInfo();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Deposit deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Failed to delete deposit'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildLoanDetailsSection() {
    final rate = double.tryParse(currentLoanDetail.rate) ?? 0;

    // Calculate months passed since loan started
    final monthsPassed = _calculateMonthsPassed(currentLoanDetail.startDate);

    // Use daily interest from database instead of manual calculation
    final dailyInterest = double.tryParse(currentLoanDetail.dailyInterest) ?? 0;

    // Documents are now loaded separately in _loadLoanDocuments()

    return Container(
      padding: const EdgeInsets.all(16),
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
          _buildDetailRow(
            'Return Date',
            currentLoanDetail.endDate == "0000-00-00"
                ? "N/A"
                : _formatReturnDate(currentLoanDetail.endDate),
          ),
          InterestDetailRow(
            label: 'Interest',
            totalInterest: currentLoanDetail.totalInterest,
          ),
          // Add Total Interest Paid field
          Consumer<Interestprovider>(
            builder: (context, interestProvider, child) {
              // Calculate total interest paid from all interest payments
              final totalInterestPaid = interestProvider.interest.fold<double>(
                0.0,
                (sum, interest) => sum + (double.tryParse(interest.interestAmount) ?? 0.0),
              );

              return _buildDetailRow(
                'Total Interest Paid',
                AmountFormatter.formatCurrencyWithDecimals(totalInterestPaid.toString()),
              );
            },
          ),
          _buildDetailRow('Months Passed', '$monthsPassed'),
          _buildDetailRow('Rate', AmountFormatter.formatPercentage(rate)),
          _buildDetailRow('Note', currentLoanDetail.note),
          _buildDetailRow(
            'Daily Interest',
            AmountFormatter.formatCurrencyWithDecimals(dailyInterest),
          ),
          _buildDetailRow(
            'Total Daily Interest',
            AmountFormatter.formatCurrencyWithDecimals(
              double.tryParse(currentLoanDetail.totalDailyInterest) ?? 0,
            ),
          ),
          const SizedBox(height: 16),
          // Enhanced loan documents section
          _buildLoanDocumentsSection(),
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
                              loanId: currentLoanDetail.loanId,
                            ),
                      ),
                    );
                    if (result == true) {
                      // Refresh loan data to get updated totalInterest
                      await _loadData();
                    }
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.blueGrey),
                ),
              ],
            ),
            // Interest Summary Card
            if (interestProvider.interest.isNotEmpty)
              SizedBox(
                height: 130, // Increased height to accommodate payment method badges
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
    return GestureDetector(
      onTap: () {
        // Show SnackBar on tap
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Do long press'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onLongPress: () {
        _showInterestContextMenu(context, interest);
      },
      child: Container(
        width: 170, // Increased width to accommodate new content
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10), // Reduced padding slightly
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Prevent overflow
        children: [
          Text(
            AmountFormatter.formatCurrencyWithDecimals(interest.interestAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: (interest.interestField == 'online')
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: (interest.interestField == 'online')
                        ? Colors.green[300]!
                        : Colors.orange[300]!,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (interest.interestField == 'online')
                          ? Icons.credit_card
                          : Icons.money,
                      size: 8,
                      color: (interest.interestField == 'online')
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      interest.interestField?.toUpperCase() ?? 'CASH',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: (interest.interestField == 'online')
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            _formatDisplayDate(interest.interestDate),
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
    ), // Close Container
    ); // Close GestureDetector
  }

  void _showInterestContextMenu(BuildContext context, interest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Interest Payment Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
              const SizedBox(height: 16),

              // View option
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InterestDetailScreen(interest: interest),
                    ),
                  );
                },
              ),

              // Delete option
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Payment'),
                onTap: () {
                  Navigator.pop(context);
                  _showInterestDeleteConfirmationDialog(context, interest);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showInterestDeleteConfirmationDialog(BuildContext context, interest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Interest Payment'),
          content: Text(
            'Are you sure you want to delete this interest payment of ${AmountFormatter.formatCurrencyWithDecimals(interest.interestAmount)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteInterest(interest);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteInterest(interest) async {
    try {
      final success = await Provider.of<Interestprovider>(context, listen: false)
          .deleteInterest(interest.InterestId);

      if (success) {
        // Refresh loan data to update totals
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString("userId");
        // Use the customer ID from the widget, fallback to loan detail custId
        String custId = widget.customer.custId ?? '';
        if (custId.isEmpty) {
          custId = currentLoanDetail.custId;
        }

        if (mounted && userId != null && custId.isNotEmpty) {
          await Provider.of<LoanProvider>(context, listen: false)
              .fetchLoanDetailList(userId, custId);

          // Also refresh the profile provider to update profile screen amounts
          if (mounted) {
            await Provider.of<ProfileProvider>(context, listen: false)
                .fetchMoneyInfo();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Interest payment deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Failed to delete interest payment'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              AmountFormatter.formatCurrency(amount),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
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
              'Are you sure you want to delete this loan? This action will move the loan to settled loans and cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteLoan();
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

  Future<void> _deleteLoan() async {
    await _deleteLoanWithConfirmation(false);
  }

  Future<void> _deleteLoanWithConfirmation(bool confirmCustomerDeletion) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call the delete API
      final result = await RemoveLoan().remove(
        currentLoanDetail.loanId,
        confirmCustomerDeletion: confirmCustomerDeletion,
      );

      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (result.success) {
        // If customer was deleted, remove from customer provider
        if (result.customerDeleted && result.customerId != null && mounted) {
          Provider.of<CustomerProvider>(context, listen: false)
              .removeCustomer(result.customerId!);
        }

        // Show success message with additional info about customer deletion
        if (mounted) {
          String message = result.message;
          if (result.customerDeleted) {
            message += '\nCustomer also removed (no remaining loans)';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: Duration(seconds: result.customerDeleted ? 4 : 3),
            ),
          );
        }

        // Refresh loan data
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString("userId");
        if (userId != null && mounted) {
          // Refresh loan provider
          await Provider.of<LoanProvider>(context, listen: false)
              .fetchLoanDetailList(userId, widget.customer.custId);

          // Refresh profile provider to update amounts
          if (mounted) {
            await Provider.of<ProfileProvider>(context, listen: false)
                .fetchMoneyInfo();
          }
        }

        // Navigate appropriately based on whether customer was deleted
        if (mounted) {
          if (result.customerDeleted) {
            // Customer deleted - navigate to dashboard (shows customer list)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
              (route) => false, // Remove all previous routes
            );
          } else {
            // Normal loan deletion - go back to loan dashboard
            Navigator.pop(context);
          }
        }
      } else if (result.confirmationRequired) {
        // Show enhanced confirmation dialog with three options
        if (mounted) {
          final choice = await EnhancedLoanDeletionDialog.show(
            context: context,
            customerName: widget.customer.custName,
          );

          if (choice == LoanDeletionChoice.deleteBoth) {
            // User wants to delete both loan and customer
            await _deleteLoanWithConfirmation(true);
          } else if (choice == LoanDeletionChoice.deleteLoanOnly) {
            // User wants to delete loan only, keep customer
            final result = await RemoveLoan().remove(
              currentLoanDetail.loanId,
              deleteLoanOnly: true,
            );

            if (mounted && result.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate to dashboard
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
                (route) => false,
              );
            }
          } else {
            // User cancelled, show message that loan was not deleted
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loan deletion cancelled'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete loan. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting loan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
    } catch (e) {
      return dateStr;
    }
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

  Widget _buildLoanDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.attach_file,
              color: Colors.blueGrey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Loan Documents (${loanDocuments.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Documents content
        if (isLoadingDocuments)
          Container(
            height: 120,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (loanDocuments.isEmpty)
          _buildNoDocumentsPlaceholder()
        else
          _buildDocumentsGrid(),
      ],
    );
  }

  Widget _buildNoDocumentsPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 40,
            color: Colors.blueGrey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No documents available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsGrid() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: loanDocuments.length,
        itemBuilder: (context, index) {
          final document = loanDocuments[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showFullScreenDocument(document),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Document image
                      Image.network(
                        LoanDocumentApi.getDocumentUrl(document.documentPath),
                        width: 100,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 100,
                            height: 120,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 120,
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 24,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Error',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Tap indicator
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenDocument(LoanDocument document) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoanDocumentFullScreenViewer(
          document: document,
        ),
      ),
    );
  }
}
