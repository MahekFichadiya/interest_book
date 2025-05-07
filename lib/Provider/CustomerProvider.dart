import 'package:flutter/material.dart';
import 'package:interest_book/Api/ShowCustomer.dart';
import 'package:interest_book/Model/CustomerModel.dart';

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = true;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> fetchCustomerList(String userId) async {
    _isLoading = true;
    notifyListeners();

    _customers = await ShowCustomer().custList(userId);
    _isLoading = false;
    notifyListeners();
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
    notifyListeners();
  }

  void updateCustomer(Customer updated) {
    final index = _customers.indexWhere((c) => c.custId == updated.custId);
    if (index != -1) {
      _customers[index] = updated;
      notifyListeners();
    }
  }

  Customer? getCustomerById(String custId) {
    try {
      return _customers.firstWhere((c) => c.custId == custId);
    } catch (_) {
      return null;
    }
  }
}
