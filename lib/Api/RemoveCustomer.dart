import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class Removecustomer {
  Future<bool> remove(String custId, String userId) async {
    final Url = Uri.parse(UrlConstant.removeCustomer);
    var body = {
      "custId": custId,
      "userId": userId,
    };
    final newbody = json.encode(body);
    var responce = await http.post(Url, body: newbody);
    print(responce);
    print(responce.statusCode);
    if (responce.statusCode == 200 || responce.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
