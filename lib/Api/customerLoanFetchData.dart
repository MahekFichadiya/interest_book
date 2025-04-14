import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/customerLoanData.dart';

Future<List<Customerloandata>> fetchCustomerLoanData() async {
  final response = await http.get(Uri.parse(UrlConstant.getCustomerLoanData));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Customerloandata.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}


