import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class UpdateCustomerWithImageApi {
  Future<bool> update(
    String custId,
    String custName,
    String custPhn,
    String custAddress,
    {File? custPic}
  ) async {
    try {
      final url = Uri.parse(UrlConstant.updateCustomer);
      
      if (custPic != null) {
        // Use multipart request for file upload
        var request = http.MultipartRequest("POST", url);
        request.fields['custId'] = custId;
        request.fields['custName'] = custName;
        request.fields['custphn'] = custPhn;
        request.fields['custAddress'] = custAddress;
        
        if (await custPic.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath("custPic", custPic.path),
          );
        }
        
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          return responseData['status'] == true;
        }
      } else {
        // Use regular JSON request
        var body = {
          "custId": custId,
          "custName": custName,
          "custphn": custPhn,
          "custAddress": custAddress,
        };
        final newbody = json.encode(body);

        var response = await http.post(
          url,
          body: newbody,
          headers: {'Content-Type': 'application/json'},
        );
        
        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          return responseData['status'] == true;
        }
      }
      
      return false;
    } catch (e) {
      print("Error updating customer: $e");
      return false;
    }
  }
}
