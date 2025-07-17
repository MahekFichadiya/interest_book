import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Provider/customer_provider.dart';

import '../Model/CustomerModel.dart';

class Addcustomer {
  Future<Map<String, dynamic>> add(
    String custName,
    String custPhn,
    String custAddress,
    String date,
    String userId,
    CustomerProvider customerProvider,
    {File? custPic}
  ) async {
    final url = Uri.parse(UrlConstant.AddCustomer);
    http.Response responce;

    if (custPic != null) {
      // Use multipart request for file upload
      var request = http.MultipartRequest("POST", url);
      request.fields['custName'] = custName;
      request.fields['custPhn'] = custPhn;
      request.fields['custAddress'] = custAddress;
      request.fields['date'] = date;
      request.fields['userId'] = userId;

      if (await custPic.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath("custPic", custPic.path),
        );
      }

      var streamedResponse = await request.send();
      responce = await http.Response.fromStream(streamedResponse);
    } else {
      // Use regular JSON request
      var body = {
        "custName": custName,
        "custPhn": custPhn,
        "custAddress": custAddress,
        "date": date,
        "userId": userId,
      };
      final newbody = json.encode(body);

      responce = await http.post(
        url,
        body: newbody,
        headers: {'Content-Type': 'application/json'},
      );
    }

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
          return {
            'success': true,
            'message': responseData['message'] ?? 'Customer added successfully'
          };
        } else {
          print("Error: ${responseData['message']}");
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to add customer'
          };
        }
      } catch (e) {
        print("Error parsing response: $e");
        return {
          'success': false,
          'message': 'Error processing response'
        };
      }
    } else if (responce.statusCode == 409) {
      // Handle duplicate customer case
      try {
        var responseData = json.decode(responce.body);
        var existingCustomer = responseData['existingCustomer'];
        return {
          'success': false,
          'isDuplicate': true,
          'message': responseData['message'] ?? 'Customer already exists',
          'existingCustomer': existingCustomer
        };
      } catch (e) {
        return {
          'success': false,
          'isDuplicate': true,
          'message': 'Customer with this phone number already exists'
        };
      }
    } else {
      print("HTTP Error: ${responce.statusCode}");
      return {
        'success': false,
        'message': 'Network error occurred'
      };
    }
  }
}