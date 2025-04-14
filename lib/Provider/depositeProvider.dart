import 'package:flutter/material.dart';
import 'package:interest_book/Api/interest.dart';
import 'package:interest_book/Model/depositeDetail.dart';

class Depositeprovider extends ChangeNotifier {
  List<Depositedetail> _deposite = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Depositedetail> get deposite => _deposite;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch deposit list by loanId
  Future<void> fetchDepositeList(String loanId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _deposite = await interestApi().getDepositeList(loanId);
    } catch (e) {
      _errorMessage = "Failed to fetch deposit list: $e";
      _deposite = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
