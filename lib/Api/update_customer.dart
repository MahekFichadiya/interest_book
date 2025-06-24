import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class updateCustomerApi {
  Future<bool> update(
    String custId,
    String custName,
    String custPhn,
    String custAddress,
  ) async {
    final Url = Uri.parse(UrlConstant.updateCustomer);
    var body = {
      "custId": custId,
      "custName": custName,
      "custphn": custPhn,
      "custAddress": custAddress,
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
      print(responce.statusCode);
      return true;
    } else {
      print(responce.statusCode);
      return false;
    }
  }
}
