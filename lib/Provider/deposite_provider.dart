import 'package:flutter/material.dart';
import 'package:interest_book/Api/interest.dart';
import 'package:interest_book/Api/remove_deposit.dart';
import 'package:interest_book/Model/depositeDetail.dart';

class Depositeprovider extends ChangeNotifier {
  List<Depositedetail> _deposite = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Depositedetail> get deposite => _deposite;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get total deposits for a specific loan
  double getTotalDeposits() {
    return _deposite.fold<double>(
      0.0,
      (sum, deposit) => sum + (double.tryParse(deposit.depositeAmount) ?? 0.0),
    );
  }

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

  // Force immediate refresh for real-time updates
  void forceRefresh() {
    notifyListeners();
  }

  // Delete deposit by depositeId
  Future<bool> deleteDeposit(String depositeId) async {
    try {
      final success = await RemoveDeposit().remove(depositeId);
      if (success) {
        // Remove the deposit from the local list
        _deposite.removeWhere((deposit) => deposit.depositeId == depositeId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = "Failed to delete deposit: $e";
      return false;
    }
  }
}
