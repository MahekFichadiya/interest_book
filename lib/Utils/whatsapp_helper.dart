import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  /// Launch WhatsApp with a specific phone number and optional message
  static Future<void> launchWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    // Remove any non-digit characters from phone number
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure phone number starts with country code
    if (!cleanPhone.startsWith('+')) {
      // Add India country code if not present
      cleanPhone = '+91$cleanPhone';
    }
    
    // Create WhatsApp URL
    String whatsappUrl = 'https://wa.me/$cleanPhone';
    
    // Add message if provided
    if (message != null && message.isNotEmpty) {
      whatsappUrl += '?text=${Uri.encodeComponent(message)}';
    }
    
    try {
      final Uri url = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      throw 'Error launching WhatsApp: $e';
    }
  }
  
  /// Generate loan summary message for WhatsApp
  static String generateLoanSummaryMessage({
    required String customerName,
    required String loanAmount,
    required String remainingBalance,
    required String monthlyInterest,
  }) {
    return '''
Hello $customerName,

Here's your loan summary:
💰 Original Loan: ₹$loanAmount
📊 Remaining Balance: ₹$remainingBalance
📈 Monthly Interest: ₹$monthlyInterest

Please contact us for any queries.

Best regards,
Your Loan Manager
    ''';
  }
  
  /// Generate payment reminder message
  static String generatePaymentReminderMessage({
    required String customerName,
    required String dueAmount,
    required String dueDate,
  }) {
    return '''
Dear $customerName,

This is a friendly reminder about your upcoming payment:
💳 Amount Due: ₹$dueAmount
📅 Due Date: $dueDate

Please make the payment on time to avoid any late fees.

Thank you!
    ''';
  }
}
