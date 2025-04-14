import 'package:flutter/material.dart';
import 'package:interest_book/Api/getLoanDetail.dart';
import '../Model/settledLoanModel.dart'; // This is the file above

class Settledloanprovider with ChangeNotifier {
  final getLoanDetail _loanService = getLoanDetail();

  List<Settledloanmodel> _detail = [];
  List<Settledloanmodel> get detail => _detail;

  bool isLoading = false;
  String errorMessage = "";

  Future<void> fetchLoanDetailList(String userId, String? custId) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      _detail = await _loanService.fetchSettledLoans(userId, custId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
