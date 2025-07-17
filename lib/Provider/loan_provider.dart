import 'package:flutter/material.dart';
import 'package:interest_book/Api/get_loan_detail.dart';
import 'package:interest_book/Api/interest.dart';
import 'package:interest_book/Model/LoanDetail.dart';

class LoanProvider extends ChangeNotifier {
  List<Loandetail> _loanDetail = [];
  String _errorMessage = '';
  bool _isLoading = false;
  Map<String, dynamic> _totals = {
    'totalAmount': 0.0,
    'totalInterest': 0.0,
    'totalDue': 0.0,
  };

  List<Loandetail> get detail => _loanDetail;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get totals => _totals;

  Future<void> fetchLoanDetailList(String? userId, String? custId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Validate input parameters
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID is required');
      }

      // Try to fetch loan data first (most critical operation)
      _loanDetail = await getLoanDetail().loanList(userId, custId);
      _calculateTotals(); // Calculate totals after fetching data

      // Try to update interest calculations (optional operations)
      // If these fail, we still have the loan data
      try {
        await interestApi().updateMonthlyInterest();
        await interestApi().triggerAutomaticInterestCalculation();

        // Refetch data after interest calculations
        _loanDetail = await getLoanDetail().loanList(userId, custId);
        _calculateTotals();
      } catch (interestError) {
        print('Interest calculation failed, but loan data is available: $interestError');
        // Continue with existing loan data
      }

    } catch (e) {
      print('Error in fetchLoanDetailList: $e');
      _errorMessage = 'Failed to load loan details: ${e.toString()}';
      _loanDetail = []; // Clear existing data on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate totals from current loan data
  void _calculateTotals() {
    double totalAmount = 0;
    double totalInterest = 0;

    for (var loan in _loanDetail) {
      totalAmount += double.tryParse(loan.updatedAmount) ?? 0;
      totalInterest += double.tryParse(loan.totalInterest) ?? 0;
    }

    _totals = {
      'totalAmount': totalAmount,
      'totalInterest': totalInterest,
      'totalDue': totalAmount + totalInterest,
    };
  }

  // Refresh loan data and recalculate totals
  Future<void> addNewLoanAndRefresh({
    required String userId,
    required String custId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch updated loan data
      await fetchLoanDetailList(userId, custId);
    } catch (e) {
      _errorMessage = 'Failed to refresh loan data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force refresh totals without API call (useful for real-time updates)
  void refreshTotals() {
    _calculateTotals();
    notifyListeners();
  }

  // Force refresh method to trigger UI updates
  void forceRefresh() {
    notifyListeners();
  }

  // Simple fetch method without interest calculations (for quick navigation)
  Future<void> fetchLoanDetailListSimple(String? userId, String? custId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID is required');
      }

      _loanDetail = await getLoanDetail().loanList(userId, custId);
      _calculateTotals();

    } catch (e) {
      _errorMessage = 'Failed to load loan details: ${e.toString()}';
      _loanDetail = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get updated loan data for a specific loan
  Loandetail? getLoanById(String loanId) {
    try {
      return _loanDetail.firstWhere((loan) => loan.loanId == loanId);
    } catch (e) {
      return null;
    }
  }

  // Clear all data and reset state
  void clearData() {
    _loanDetail = [];
    _errorMessage = '';
    _isLoading = false;
    _totals = {
      'totalAmount': 0.0,
      'totalInterest': 0.0,
      'totalDue': 0.0,
    };
    notifyListeners();
  }

  // Force refresh with loading state
  Future<void> forceRefreshWithLoading(String? userId, String? custId) async {
    clearData();
    _isLoading = true;
    notifyListeners();

    try {
      await fetchLoanDetailList(userId, custId);
    } catch (e) {
      _errorMessage = 'Failed to refresh loan data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
