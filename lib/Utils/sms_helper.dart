import 'package:url_launcher/url_launcher.dart';

class SMSHelper {
  /// Launch SMS app with a specific phone number and message
  static Future<void> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    // Remove any non-digit characters from phone number
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Create SMS URL
    String smsUrl = 'sms:$cleanPhone?body=${Uri.encodeComponent(message)}';
    
    try {
      final Uri url = Uri.parse(smsUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch SMS app';
      }
    } catch (e) {
      throw 'Error launching SMS: $e';
    }
  }
  
  /// Generate loan summary message for SMS
  static String generateLoanSummaryMessage({
    required double totalAmount,
    required double totalInterest,
    required double principalAmount,
  }) {
    // Format amounts to show in rupees
    String formattedTotalAmount = totalAmount.toStringAsFixed(0);
    String formattedPrincipalAmount = principalAmount.toStringAsFixed(0);
    String formattedInterest = totalInterest.toStringAsFixed(0);

    return '''Dear Customer,
This is a reminder that your loan amount of Rs. $formattedTotalAmount is currently due.
Principal: Rs. $formattedPrincipalAmount
Interest: Rs. $formattedInterest

We kindly request you to make the payment at your earliest convenience.
This message is for your information only. Please do not reply.

Thank you.
Interest Book''';
  }
}
