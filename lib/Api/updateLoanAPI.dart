import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

Future<bool> updateLoan(
  String loanId,
  String amount,
  String rate,
  String startDate,
  String endDate,
  dynamic image, // Accept both File and String
  String note,
  String userId,
  String custId,
) async {
  var url = Uri.parse(UrlConstant.updateLoan);
  var request = http.MultipartRequest("POST", url)
    ..fields['loanId'] = loanId
    ..fields['amount'] = amount
    ..fields['rate'] = rate
    ..fields['startDate'] = startDate
    ..fields['endDate'] = endDate
    ..fields['note'] = note
    ..fields['userId'] = userId
    ..fields['custId'] = custId;

  if (image is File) {
    // If the image is a File, send it as a multipart file
    request.files.add(
      await http.MultipartFile.fromPath("image", image.path),
    );
  } else if (image is String) {
    // If the image is a URL (String), send it as a field
    request.fields['image'] = image;
  }

  var response = await request.send();
  print(response.statusCode);
  if (response.statusCode == 200 || response.statusCode == 201) {
    var data = await http.Response.fromStream(response);
    var userData = jsonDecode(data.body);
    print(userData);
    return true;
  } else {
    var da = await http.Response.fromStream(response);
    print("body" + da.body);
    return false;
  }
}
