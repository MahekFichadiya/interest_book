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

    var responce = await http.post(
      Url,
      body: newbody,
      headers: {'Content-Type': 'application/json'},
    );

    print(responce.body);
    print(responce.statusCode);

    if (responce.statusCode == 200 || responce.statusCode == 201) {
      try {
        var responseData = json.decode(responce.body);

        if (responseData['status'] == true) {
          var customerData = responseData['data'];

          // Add the customer to the provider's list with the correct custId
          customerProvider.addCustomer(
            Customer(
              custId: customerData['custId'].toString(),
              custName: customerData['custName'],
              custPhn: customerData['custPhn'],
              custAddress: customerData['custAddress'],
              date: customerData['date'],
              userId: customerData['userId'].toString(),
            ),
          );
          return true;
        } else {
          print("Error: ${responseData['message']}");
          return false;
        }
      } catch (e) {
        print("Error parsing response: $e");
        return false;
      }
    } else {
      print("HTTP Error: ${responce.statusCode}");
      return false;
    }
  }
}