import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class RemoveInterest {
  Future<bool> remove(String interestId) async {
    try {
      final url = Uri.parse(UrlConstant.removeInterest);
      var body = {"interestId": interestId};
      final newbody = json.encode(body);
      
      var response = await http.post(
        url,
        body: newbody,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Remove interest response: ${response.body}');
      print('Remove interest status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        return false;
      }
    } catch (e) {
      print('Error removing interest: $e');
      return false;
    }
  }
}
