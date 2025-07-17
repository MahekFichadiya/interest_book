import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/customerLoanData.dart';

class BusinessReportService {
  // Fetch comprehensive business report data with interest calculations
  static Future<BusinessReportData> fetchBusinessReportData(String userId) async {
    final response = await http.get(
      Uri.parse('${UrlConstant.getBusinessReportData}?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      
      if (jsonData['status'] == 'success') {
        return BusinessReportData.fromJson(jsonData['data']);
      } else {
        throw Exception('API Error: ${jsonData['message']}');
      }
    } else {
      throw Exception('Failed to load business report data');
    }
  }

  // Fetch customer loan data (legacy method for backward compatibility)
  static Future<List<Customerloandata>> fetchCustomerLoanData() async {
    final response = await http.get(Uri.parse(UrlConstant.getCustomerLoanData));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Customerloandata.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customer loan data');
    }
  }
}

class BusinessReportData {
  final List<Customerloandata> customers;
  final BusinessSummary summary;

  BusinessReportData({
    required this.customers,
    required this.summary,
  });

  factory BusinessReportData.fromJson(Map<String, dynamic> json) {
    return BusinessReportData(
      customers: (json['customers'] as List<dynamic>)
          .map((customerJson) => Customerloandata.fromJson(customerJson))
          .toList(),
      summary: BusinessSummary.fromJson(json['summary']),
    );
  }
}

class BusinessSummary {
  final int totalCustomers;
  final double principalYouGave;
  final double principalYouGot;
  final double interestYouGave;
  final double interestYouGot;
  final double totalYouGave;
  final double totalYouGot;
  final double netBalance;
  final double totalInterest;

  BusinessSummary({
    required this.totalCustomers,
    required this.principalYouGave,
    required this.principalYouGot,
    required this.interestYouGave,
    required this.interestYouGot,
    required this.totalYouGave,
    required this.totalYouGot,
    required this.netBalance,
    required this.totalInterest,
  });

  factory BusinessSummary.fromJson(Map<String, dynamic> json) {
    return BusinessSummary(
      totalCustomers: json['total_customers'] ?? 0,
      principalYouGave: double.tryParse(json['principal_you_gave'].toString()) ?? 0.0,
      principalYouGot: double.tryParse(json['principal_you_got'].toString()) ?? 0.0,
      interestYouGave: double.tryParse(json['interest_you_gave'].toString()) ?? 0.0,
      interestYouGot: double.tryParse(json['interest_you_got'].toString()) ?? 0.0,
      totalYouGave: double.tryParse(json['total_you_gave'].toString()) ?? 0.0,
      totalYouGot: double.tryParse(json['total_you_got'].toString()) ?? 0.0,
      netBalance: double.tryParse(json['net_balance'].toString()) ?? 0.0,
      totalInterest: double.tryParse(json['total_interest'].toString()) ?? 0.0,
    );
  }
}
