import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

import '../Model/CustomerModel.dart';
import '../Provider/CustomerProvider.dart';

class Addcustomer {
  Future<bool> add(
    String custName,
    String custPhn,
    String custAddress,
    String date,
    String userId,
    CustomerProvider customerProvider,
  ) async {
    final Url = Uri.parse(UrlConstant.AddCustomer);
    var body = {
      "custName": custName,
      "custPhn": custPhn,
      "custAddress": custAddress,
      "date": date,
      "userId": userId,
    };
    final newbody = json.encode(body);

    var responce = await http.post(Url, body: newbody);
    print(responce.body);
    print(responce.statusCode);
    if (responce.statusCode == 200 || responce.statusCode == 201) {
      print(responce.statusCode);
      // Add the customer to the provider's list
      customerProvider.addCustomer(
        Customer(
          custName: custName,
          custPhn: custPhn,
          custAddress: custAddress,
          date: date,
          userId: userId,
        ),
      );
      return true;
    } else {
      print(responce.statusCode);
      return false;
    }
  }
}