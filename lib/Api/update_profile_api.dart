import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class UpdateProfileAPI {
  Future<bool> update(
    String userId,
    String name,
    String mobileNo,
    String email,
  ) async {
    final Url = Uri.parse(UrlConstant.UpdateProfile);
    var body = {
      "userId": userId,
      "name": name,
      "mobileNo": mobileNo,
      "email": email,
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