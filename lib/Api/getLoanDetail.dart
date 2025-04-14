import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/LoanDetail.dart';
import 'package:interest_book/Model/settledLoanModel.dart';

class getLoanDetail {
  Future<List<Loandetail>> loanList(String? userId, String? custId) async {
    if (userId == null || custId == null) {
      throw Exception('User ID or Customer ID is null');
    }

    var url = Uri.parse(UrlConstant.getLoanDetail);
    List<Loandetail> loanData = [];
    var body = json.encode({"userId": userId, "custId": custId});
    var response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      for (var data in responseData) {
        Loandetail detail = Loandetail.fromJson(data);
        loanData.add(detail);
      }
    } else {
      throw Exception('Failed to load loan details');
    }
    print("loanData: ${loanData}");
    print(response.body);
    return loanData;
  }

  Future<List<Settledloanmodel>> fetchSettledLoans(String userId, String? custId) async {
    final url = Uri.parse(UrlConstant.getSettledLoanDetail);

    final body = jsonEncode({
      "userId": userId,
      "custId": custId, // this can be null
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Settledloanmodel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load loan details");
      }
    } catch (e) {
      print("Exception caught: $e");
      throw Exception("Failed to load loan details. Please try again.");
    }
  }
}
