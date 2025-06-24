import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class signupApi {
  Future<bool> userSignup(
    String name,
    String mobileNo,
    String email,
    String password,
  ) async {
    final Url = Uri.parse(UrlConstant.SignupApi);
    var body = {
      "name": name,
      "mobileNo": mobileNo,
      "email": email,
      "password": password,
    };
    final newbody = json.encode(body);
  
    var responce = await http.post(Url, body: newbody);
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