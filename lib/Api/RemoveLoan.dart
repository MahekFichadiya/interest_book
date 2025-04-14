import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class RemoveLoan {
  Future<bool> remove(String loanId) async {
    final Url = Uri.parse(UrlConstant.removeLoan);
    var body = {"loanId": loanId};
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
