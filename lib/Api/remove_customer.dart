import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class CustomerDeletionResult {
  final bool success;
  final String message;
  final int customerDeleted;
  final int loansDeleted;
  final int interestsDeleted;
  final int depositsDeleted;

  CustomerDeletionResult({
    required this.success,
    required this.message,
    this.customerDeleted = 0,
    this.loansDeleted = 0,
    this.interestsDeleted = 0,
    this.depositsDeleted = 0,
  });

  factory CustomerDeletionResult.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    return CustomerDeletionResult(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      customerDeleted: _parseToInt(summary['customer_deleted']),
      loansDeleted: _parseToInt(summary['loans_deleted']),
      interestsDeleted: _parseToInt(summary['interests_deleted']),
      depositsDeleted: _parseToInt(summary['deposits_deleted']),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  String get detailedMessage {
    if (!success) return message;

    List<String> details = [];
    if (customerDeleted > 0) details.add('$customerDeleted customer');
    if (loansDeleted > 0) details.add('$loansDeleted loans');
    if (interestsDeleted > 0) details.add('$interestsDeleted interest records');
    if (depositsDeleted > 0) details.add('$depositsDeleted deposit records');

    return 'Successfully deleted: ${details.join(', ')}';
  }
}

class Removecustomer {
  Future<CustomerDeletionResult> remove(String custId, String userId) async {
    try {
      final Url = Uri.parse(UrlConstant.removeCustomer);
      var body = {
        "custId": custId,
        "userId": userId,
      };
      final newbody = json.encode(body);

      var response = await http.post(
        Url,
        body: newbody,
        headers: {'Content-Type': 'application/json'},
      );

      print('Remove customer response: ${response.body}');
      print('Remove customer status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return CustomerDeletionResult.fromJson(responseData);
      } else {
        final responseData = json.decode(response.body);
        return CustomerDeletionResult(
          success: false,
          message: responseData['message'] ?? 'Failed to delete customer',
        );
      }
    } catch (e) {
      print('Error removing customer: $e');
      return CustomerDeletionResult(
        success: false,
        message: 'Error: $e',
      );
    }
  }
}
