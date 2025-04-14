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
}