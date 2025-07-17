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

class _LoanListState extends State<LoanList> with AutomaticKeepAliveClientMixin {
  String? userId;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true; // Keep the state alive

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didUpdateWidget(LoanList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh data if customer changed
    if (oldWidget.customer.custId != widget.customer.custId) {
      loadData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when the widget is rebuilt due to provider changes
    // Check if we need to refresh data
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);
    if (loanProvider.detail.isEmpty && !loanProvider.isLoading && userId != null) {
      // Data is empty and not loading, try to refresh
      fetchLoanDetailList();
    }
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

  // Manual refresh method for pull-to-refresh
  Future<void> _refreshData() async {
    if (userId != null && widget.customer.custId != null) {
      await fetchLoanDetailList();
    }
  }

  // Force refresh method that can be called externally
  void refreshLoanList() {
    if (mounted) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      color: Colors.blueGrey[700],
      backgroundColor: Colors.white,
      child: Consumer<LoanProvider>(
        builder: (context, loanProvider, child) {
          if (loanProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (loanProvider.errorMessage.isNotEmpty) {
            return _buildErrorState(loanProvider.errorMessage);
          } else if (loanProvider.detail.isEmpty) {
            return _buildEmptyState();
          } else {
            return _buildLoanList(loanProvider.detail);
          }
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Loans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  "This customer has no loan :)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pull down to refresh",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanList(List detail) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: detail.length,
      itemBuilder: (context, index) {
        return LoanDetail(
          detail: detail[index],
          customer: widget.customer,
        );
      },
    );
  }
}
