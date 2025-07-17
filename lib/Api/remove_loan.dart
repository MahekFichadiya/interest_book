import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class LoanDeletionResult {
  final bool success;
  final String message;
  final bool customerDeleted;
  final String? customerId;
  final int? remainingLoans;
  final bool confirmationRequired;
  final bool customerDeletionRequired;

  LoanDeletionResult({
    required this.success,
    required this.message,
    this.customerDeleted = false,
    this.customerId,
    this.remainingLoans,
    this.confirmationRequired = false,
    this.customerDeletionRequired = false,
  });

  factory LoanDeletionResult.fromJson(Map<String, dynamic> json) {
    return LoanDeletionResult(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      customerDeleted: json['customer_deleted'] ?? false,
      customerId: json['customer_id']?.toString(),
      remainingLoans: json['remaining_loans'],
      confirmationRequired: json['status'] == 'confirmation_required',
      customerDeletionRequired: json['customer_deletion_required'] ?? false,
    );
  }
}

class RemoveLoan {
  Future<LoanDeletionResult> remove(String loanId, {bool confirmCustomerDeletion = false, bool deleteLoanOnly = false}) async {
    try {
      final Url = Uri.parse(UrlConstant.removeLoan);
      var body = {
        "loanId": loanId,
        "confirmCustomerDeletion": confirmCustomerDeletion,
        "deleteLoanOnly": deleteLoanOnly
      };
      final newbody = json.encode(body);

      var response = await http.post(
        Url,
        body: newbody,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Remove Loan Response Status: ${response.statusCode}');
      print('Remove Loan Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          return LoanDeletionResult.fromJson(responseData);
        } catch (e) {
          print('Error parsing response: $e');
          return LoanDeletionResult(
            success: true,
            message: 'Loan deleted successfully',
          );
        }
      } else {
        print('Failed to delete loan. Status: ${response.statusCode}, Body: ${response.body}');
        return LoanDeletionResult(
          success: false,
          message: 'Failed to delete loan',
        );
      }
    } catch (e) {
      print('Error in remove loan API: $e');
      return LoanDeletionResult(
        success: false,
        message: 'Network error occurred',
      );
    }
  }
}
