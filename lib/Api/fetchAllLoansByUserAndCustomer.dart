import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/getLoanDetailForPDF.dart';

Future<List<Getloandetailforpdf>> fetchAllLoansByUserAndCustomer({
  required int userId,
  required int custId,
}) async {
  final Uri url = Uri.parse(
    '${UrlConstant.getLoanDetailForPDF}?userId=$userId&custId=$custId',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Getloandetailforpdf.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch loan data');
  }
}
