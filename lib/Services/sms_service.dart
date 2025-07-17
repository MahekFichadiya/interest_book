import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  /// Send SMS reminder to customer
  Future<Map<String, dynamic>> sendReminderSms({
    required String customerName,
    required String customerPhone,
    required String reminderTitle,
    String? reminderMessage,
    required double principalAmount,
    required double interestAmount,
    required String dueDate,
    String? businessName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in'
        };
      }

      // Create professional SMS message
      final smsMessage = _createReminderMessage(
        customerName: customerName,
        reminderTitle: reminderTitle,
        reminderMessage: reminderMessage,
        principalAmount: principalAmount,
        interestAmount: interestAmount,
        dueDate: dueDate,
        businessName: businessName ?? 'Om Jewellers',
      );

      // Send SMS via backend API
      final result = await _sendSmsViaApi(
        userId: userId,
        customerPhone: customerPhone,
        message: smsMessage,
        messageType: 'reminder',
      );

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending SMS: ${e.toString()}'
      };
    }
  }

  /// Send overdue SMS notification
  Future<Map<String, dynamic>> sendOverdueSms({
    required String customerName,
    required String customerPhone,
    required String reminderTitle,
    required int daysOverdue,
    required double principalAmount,
    required double interestAmount,
    String? businessName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in'
        };
      }

      // Create overdue SMS message
      final smsMessage = _createOverdueMessage(
        customerName: customerName,
        reminderTitle: reminderTitle,
        daysOverdue: daysOverdue,
        principalAmount: principalAmount,
        interestAmount: interestAmount,
        businessName: businessName ?? 'Om Jewellers',
      );

      // Send SMS via backend API
      final result = await _sendSmsViaApi(
        userId: userId,
        customerPhone: customerPhone,
        message: smsMessage,
        messageType: 'overdue',
      );

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending overdue SMS: ${e.toString()}'
      };
    }
  }

  /// Send custom SMS
  Future<Map<String, dynamic>> sendCustomSms({
    required String customerPhone,
    required String message,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in'
        };
      }

      final result = await _sendSmsViaApi(
        userId: userId,
        customerPhone: customerPhone,
        message: message,
        messageType: 'custom',
      );

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending custom SMS: ${e.toString()}'
      };
    }
  }

  /// Create professional reminder message
  String _createReminderMessage({
    required String customerName,
    required String reminderTitle,
    String? reminderMessage,
    required double principalAmount,
    required double interestAmount,
    required String dueDate,
    required String businessName,
  }) {
    final totalAmount = principalAmount + interestAmount;
    
    return '''Dear $customerName,

This is a friendly reminder from $businessName regarding your payment due on $dueDate.

Payment Details:
• Principal: ₹${principalAmount.toStringAsFixed(0)}
• Interest: ₹${interestAmount.toStringAsFixed(0)}
• Total Due: ₹${totalAmount.toStringAsFixed(0)}

${reminderMessage != null ? '\nNote: $reminderMessage\n' : ''}
Please contact us for any queries or to arrange payment.

Thank you for your business.
- $businessName''';
  }

  /// Create overdue message
  String _createOverdueMessage({
    required String customerName,
    required String reminderTitle,
    required int daysOverdue,
    required double principalAmount,
    required double interestAmount,
    required String businessName,
  }) {
    final totalAmount = principalAmount + interestAmount;
    
    return '''URGENT: Payment Overdue

Dear $customerName,

Your payment is now $daysOverdue day${daysOverdue > 1 ? 's' : ''} overdue.

Outstanding Amount:
• Principal: ₹${principalAmount.toStringAsFixed(0)}
• Interest: ₹${interestAmount.toStringAsFixed(0)}
• Total Due: ₹${totalAmount.toStringAsFixed(0)}

Please arrange immediate payment to avoid additional charges.

Contact us immediately: $businessName''';
  }

  /// Send SMS via backend API
  Future<Map<String, dynamic>> _sendSmsViaApi({
    required String userId,
    required String customerPhone,
    required String message,
    required String messageType,
  }) async {
    try {
      final url = Uri.parse(UrlConstant.sendSms);
      
      final body = {
        'userId': userId,
        'customerPhone': customerPhone,
        'message': message,
        'messageType': messageType,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  /// Format phone number for SMS (ensure proper format)
  String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // If starts with +91, remove it
    if (cleanPhone.startsWith('91') && cleanPhone.length == 12) {
      cleanPhone = cleanPhone.substring(2);
    }
    
    // Ensure 10 digits
    if (cleanPhone.length == 10) {
      return '+91$cleanPhone';
    }
    
    return phone; // Return original if can't format
  }

  /// Validate phone number
  bool isValidPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length == 10 || 
           (cleanPhone.length == 12 && cleanPhone.startsWith('91'));
  }
}
