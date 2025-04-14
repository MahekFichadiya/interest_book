import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

import '../Provider/LoanProvider.dart';

class Addloanapi {
  Future<bool> newLoan(
    String amount,
    String rate,
    String startDate,
    String endDate,
    File? image,
    String note,
    String type,
    String userId,
    String custId,
    LoanProvider loanProvider,
  ) async {
    var url = Uri.parse(UrlConstant.AddLoan);
    var request = http.MultipartRequest("POST", url);
    request.fields['amount'] = amount;
    request.fields['rate'] = rate;
    request.fields['startDate'] = startDate;
    request.fields['endDate'] = endDate;
    request.fields['note'] = note;
    request.fields['type'] = type;
    request.fields['userId'] = userId;
    request.fields['custId'] = custId;
    if (image != null && await image.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath("image", image.path),
      );
    } else {
      request.fields['image'] = "";
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = await http.Response.fromStream(response);
      print("Response data: ${data.body}");
      return true;
    } else {
      var errorData = await http.Response.fromStream(response);
      print("Error data: ${errorData.body}");
      return false;
    }
  }
}