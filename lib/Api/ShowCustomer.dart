import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import '../Model/CustomerModel.dart';
import '../Model/backupedCustomerModel.dart';

class ShowCustomer {
  Future<List<Customer>> custList(String userId) async {
    var url = Uri.parse(UrlConstant.FatchCustomer);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"userId": userId}),
    );

    List<Customer> customers = [];

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        var responseData = json.decode(response.body);
        for (var data in responseData) {
          customers.add(Customer.fromJson(data));
        }
      } catch (e) {
        print("Error decoding JSON: $e");
        print("Response body: ${response.body}");
      }
      print(response.body);
    }

    return customers;
  }

  Future<List<Backupedcustomermodel>> backupedCustList(String userId) async {
    var url = Uri.parse(UrlConstant.fatchBackupedCustomer);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"userId": userId}),
    );

    List<Backupedcustomermodel> customers = [];

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        var responseData = json.decode(response.body);
        for (var data in responseData) {
          customers.add(Backupedcustomermodel.fromJson(data));
        }
      } catch (e) {
        print("Error decoding JSON: $e");
        print("Response body: ${response.body}");
      }
    }

    return customers;
  }
}