import 'package:flutter/material.dart';
import 'package:interest_book/Api/getLoanDetail.dart';
import 'package:interest_book/Model/LoanDetail.dart';

class LoanProvider extends ChangeNotifier {
  List<Loandetail> _loanDetail = [];
  String _errorMessage = '';
  bool _isLoading = false;

  List<Loandetail> get detail => _loanDetail;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchLoanDetailList(String? userId, String? custId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _loanDetail = await getLoanDetail().loanList(userId, custId);
    } catch (e) {
      _errorMessage = 'Failed to load loan details. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Add this new method
  Future<void> addNewLoanAndRefresh({
    required String userId,
    required String custId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // After successful POST API call to add the loan
      await fetchLoanDetailList(userId, custId);
    } catch (e) {
      _errorMessage = 'Failed to add loan. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
