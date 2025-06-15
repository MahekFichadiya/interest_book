import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/depositeDetail.dart';
import 'package:interest_book/Model/interestDetail.dart';

class interestApi {
  Future<bool> addInterest(
    String interestAmount,
    String interestDate,
    String interestNote,
    String loanId,
  ) async {
    final url = Uri.parse(UrlConstant.addInterest);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "interestAmount": interestAmount,
        "interestDate": interestDate,
        "interestNote": interestNote,
        "loanId": loanId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        var responseData = json.decode(response.body);
        print("Response from server: $responseData");
        // If your API returns just `1`, then:
        return responseData == 1;
      } catch (e) {
        print("Error decoding JSON: $e");
        print("Response body: ${response.body}");
        return false;
      }
    } else {
      print("Failed with status code: ${response.statusCode}");
      return false;
    }
  }

  Future<List<Interestdetail>> getInterestList(String loanId) async {
    final url = Uri.parse("${UrlConstant.fetchInterestdetail}?loanId=$loanId");
    final response = await http.get(url);

    List<Interestdetail> interest = [];

    if (response.statusCode == 200) {
      try {
        var responseData = json.decode(response.body);
        for (var data in responseData) {
          interest.add(Interestdetail.fromJson(data));
        }
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }
    return interest;
  }

  Future<bool> addDeposite(
    String depositeAmount,
    String depositeDate,
    String depositeNote,
    String loanId,
  ) async {
    final url = Uri.parse(UrlConstant.addDeposite);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "depositeAmount": depositeAmount,
        "depositeDate": depositeDate,
        "depositeNote": depositeNote,
        "loanId": loanId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        var responseData = json.decode(response.body);
        print("Response from server: $responseData");
        // If your API returns just `1`, then:
        return responseData == 1;
      } catch (e) {
        print("Error decoding JSON: $e");
        print("Response body: ${response.body}");
        return false;
      }
    } else {
      print("Failed with status code: ${response.statusCode}");
      return false;
    }
  }

  Future<List<Depositedetail>> getDepositeList(String loanId) async {
    final url = Uri.parse("${UrlConstant.fetchDepositedetail}?loanId=$loanId");
    final response = await http.get(url);

    List<Depositedetail> deposite = [];

    if (response.statusCode == 200) {
      try {
        var responseData = json.decode(response.body);
        for (var data in responseData) {
          deposite.add(Depositedetail.fromJson(data));
        }
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }
    print(response.body);
    return deposite;
  }

  // Calculate monthly interest for a specific loan
  Future<Map<String, dynamic>?> calculateMonthlyInterest(String loanId) async {
    final url = Uri.parse(UrlConstant.calculateMonthlyInterest);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"loanId": loanId}),
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print("Error decoding JSON: $e");
        return null;
      }
    }
    return null;
  }

  // Trigger automatic interest calculation for all loans
  Future<Map<String, dynamic>?> triggerAutomaticInterestCalculation() async {
    final url = Uri.parse('${UrlConstant.baseUrl}automaticInterestCalculation.php');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print("Error decoding JSON: $e");
        return null;
      }
    }
    return null;
  }

  // Update monthly interest for all active loans
  Future<Map<String, dynamic>?> updateMonthlyInterest() async {
    final url = Uri.parse(UrlConstant.updateMonthlyInterest);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print("Error decoding JSON: $e");
        return null;
      }
    }
    return null;
  }

  // Calculate monthly interest for a specific loan
  Future<Map<String, dynamic>?> calculateMonthlyInterestForLoan(String loanId) async {
    final url = Uri.parse(UrlConstant.calculateMonthlyInterest);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"loanId": loanId}),
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print("Error decoding JSON: $e");
        return null;
      }
    }
    return null;
  }
}
