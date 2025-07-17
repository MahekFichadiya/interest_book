import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:intl/intl.dart';

Future<bool> updateLoan(
  String loanId,
  String amount,
  String rate,
  String startDate,
  String endDate,
  List<File> newDocuments,
  String note,
  String userId,
  String custId,
) async {
  try {
    var url = Uri.parse(UrlConstant.updateLoan);
    var request = http.MultipartRequest("POST", url);
    
    // Convert dates to MySQL format
    final DateTime startDateTime = DateFormat("dd/MM/yyyy hh:mm a").parse(startDate);
    final String formattedStartDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(startDateTime);
    
    String formattedEndDate = "";
    if (endDate.isNotEmpty) {
      final DateTime endDateTime = DateFormat("dd/MM/yyyy").parse(endDate);
      formattedEndDate = DateFormat("yyyy-MM-dd").format(endDateTime);
    }
    
    // Add form fields
    request.fields['loanId'] = loanId;
    request.fields['amount'] = amount;
    request.fields['rate'] = rate;
    request.fields['startDate'] = formattedStartDate;
    request.fields['endDate'] = formattedEndDate;
    request.fields['note'] = note;
    request.fields['userId'] = userId;
    request.fields['custId'] = custId;
    
    // Handle multiple documents upload
    if (newDocuments.isNotEmpty) {
      for (int i = 0; i < newDocuments.length; i++) {
        if (await newDocuments[i].exists()) {
          request.files.add(
            await http.MultipartFile.fromPath("documents[]", newDocuments[i].path),
          );
        }
      }
    }
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonData = json.decode(responseData);
    
    return jsonData['status'] == 'true';
  } catch (e) {
    print("Error updating loan: $e");
    return false;
  }
}