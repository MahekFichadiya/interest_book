import 'package:flutter/material.dart';
import 'package:interest_book/Api/getLoanDetail.dart';
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
      // First update monthly interest for all loans to ensure current calculations
      await interestApi().updateMonthlyInterest();

      // Then trigger automatic interest calculation for accumulation
      await interestApi().triggerAutomaticInterestCalculation();

      // Finally fetch the updated loan data
      _loanDetail = await getLoanDetail().loanList(userId, custId);
      _calculateTotals(); // Calculate totals after fetching data
    } catch (e) {
      _errorMessage = 'Failed to load loan details. Please try again later.';
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
}
