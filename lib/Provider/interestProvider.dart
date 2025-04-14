import 'package:flutter/material.dart';
import 'package:interest_book/Api/interest.dart';
import 'package:interest_book/Model/interestDetail.dart';

class Interestprovider extends ChangeNotifier {
  List<Interestdetail> _interest = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Interestdetail> get interest => _interest;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // ✅ Fetch interest list by loanId only
  Future<void> fetchInterestList(String loanId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _interest = await interestApi().getInterestList(loanId);
    } catch (e) {
      _errorMessage = "Failed to fetch interest list: $e";
      _interest = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
