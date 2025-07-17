import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Provider/loan_provider.dart';

class LoanAdditionResult {
  final bool success;
  final String message;
  final String? errorCode;

  LoanAdditionResult({
    required this.success,
    required this.message,
    this.errorCode,
  });

  factory LoanAdditionResult.fromJson(Map<String, dynamic> json) {
    return LoanAdditionResult(
      success: json['status'] == 'true',
      message: json['message'] ?? '',
      errorCode: json['error_code'],
    );
  }
}

class Addloanapi {
  Future<LoanAdditionResult> newLoan(
    String amount,
    String rate,
    String startDate,
    String endDate,
    List<File> documents,
    String note,
    String type,
    String userId,
    String custId,
    String paymentMode,
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
    request.fields['paymentMode'] = paymentMode;

    // Add multiple documents
    if (documents.isNotEmpty) {
      for (int i = 0; i < documents.length; i++) {
        if (await documents[i].exists()) {
          request.files.add(
            await http.MultipartFile.fromPath("documents[]", documents[i].path),
          );
        }
      }
    }

    var response = await request.send();

    var data = await http.Response.fromStream(response);
    print("Response data: ${data.body}");

    try {
      final responseData = json.decode(data.body);
      return LoanAdditionResult.fromJson(responseData);
    } catch (e) {
      print("Error parsing response: $e");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoanAdditionResult(
          success: true,
          message: 'Loan added successfully',
        );
      } else {
        return LoanAdditionResult(
          success: false,
          message: 'Failed to add loan',
        );
      }
    }
  }
}