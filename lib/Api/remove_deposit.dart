import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class RemoveDeposit {
  Future<bool> remove(String depositeId) async {
    try {
      final url = Uri.parse(UrlConstant.removeDeposite);
      var body = {"depositeId": depositeId};
      final newbody = json.encode(body);
      
      var response = await http.post(
        url,
        body: newbody,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Remove deposit response: ${response.body}');
      print('Remove deposit status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        return false;
      }
    } catch (e) {
      print('Error removing deposit: $e');
      return false;
    }
  }
}
