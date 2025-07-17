import 'package:flutter/material.dart';
import 'package:interest_book/Api/show_customer.dart';
import 'package:interest_book/Model/backupedCustomerModel.dart';

class backupedCustomerProvider extends ChangeNotifier {
  List<Backupedcustomermodel> _customers = [];
  bool _isLoading = true;

  List<Backupedcustomermodel> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> fetchCustomerList(String userId) async {
    _isLoading = true;
    notifyListeners();

    _customers = await ShowCustomer().backupedCustList(userId);
    _isLoading = false;
    notifyListeners();
  }

  void addCustomer(Backupedcustomermodel customer) {
    _customers.add(customer);
    notifyListeners();
  }

  // Method to refresh the list after a customer is deleted
  Future<void> refreshCustomerList(String userId) async {
    await fetchCustomerList(userId);
  }
}