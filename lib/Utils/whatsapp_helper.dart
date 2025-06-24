import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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

    try {
      // Try WhatsApp app URL scheme first (direct navigation)
      String whatsappAppUrl = 'whatsapp://send?phone=$cleanPhone';
      if (message != null && message.isNotEmpty) {
        whatsappAppUrl += '&text=${Uri.encodeComponent(message)}';
      }

      final Uri appUrl = Uri.parse(whatsappAppUrl);
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      print('WhatsApp app URL failed: $e');
    }

    try {
      // Fallback to web URL if app URL fails
      String whatsappWebUrl = 'https://wa.me/$cleanPhone';
      if (message != null && message.isNotEmpty) {
        whatsappWebUrl += '?text=${Uri.encodeComponent(message)}';
      }

      final Uri webUrl = Uri.parse(whatsappWebUrl);
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      throw 'Error launching WhatsApp: $e';
    }
  }

  /// Share image directly to WhatsApp - Opens WhatsApp with image ready to send
  static Future<void> shareImageViaWhatsApp({
    required File imageFile,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // Just share the image directly - this will show WhatsApp as an option
      // and when user selects WhatsApp, it will open with the image ready to send
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: message ?? 'Payment Reminder',
      );

    } catch (e) {
      throw 'Error sharing image via WhatsApp: $e';
    }
  }

  /// Open WhatsApp directly with image - Prioritizes image sharing
  static Future<void> openWhatsAppDirectlyWithImage({
    required File imageFile,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // Method 1: Share image directly to WhatsApp - this opens WhatsApp with image ready to send
      // This is the most direct way to send an image via WhatsApp
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: message ?? 'Payment Reminder',
      );
      return;
    } catch (e) {
      print('Image sharing failed: $e');
      // Continue to fallback methods
    }

    // Clean phone number for fallback methods
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+')) {
      if (cleanPhone.startsWith('91')) {
        cleanPhone = '+$cleanPhone';
      } else {
        cleanPhone = '+91$cleanPhone';
      }
    }

    try {
      // Method 2: Try to open WhatsApp directly with the contact
      String whatsappAppUrl = 'whatsapp://send?phone=${cleanPhone.replaceAll('+', '')}';
      if (message != null && message.isNotEmpty) {
        whatsappAppUrl += '&text=${Uri.encodeComponent(message)}';
      }

      final Uri appUrl = Uri.parse(whatsappAppUrl);
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      // Continue to next method
    }

    try {
      // Method 3: Try WhatsApp web URL
      String whatsappWebUrl = 'https://wa.me/$cleanPhone';
      if (message != null && message.isNotEmpty) {
        whatsappWebUrl += '?text=${Uri.encodeComponent(message)}';
      }

      final Uri webUrl = Uri.parse(whatsappWebUrl);
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      throw 'Could not open WhatsApp with image. Please ensure WhatsApp is installed.';
    }
  }

  /// Share image to WhatsApp with direct contact selection
  static Future<void> shareImageToWhatsAppContact({
    required File imageFile,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // Clean phone number
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+91$cleanPhone';
      }

      // Share the image with WhatsApp specifically
      // This should open WhatsApp directly with the image
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: message ?? 'Payment Reminder',
      );

    } catch (e) {
      throw 'Error sharing image to WhatsApp contact: $e';
    }
  }

  /// Share payment reminder image with message - Prioritizes image over text
  static Future<void> sharePaymentReminder({
    required File imageFile,
    required String customerName,
    required String phoneNumber,
    String? customMessage,
  }) async {
    try {
      final String message = customMessage ??
        'Dear $customerName, please find your payment reminder attached. Please make the payment as soon as possible. Thank you!';

      await openWhatsAppDirectlyWithImage(
        imageFile: imageFile,
        phoneNumber: phoneNumber,
        message: message,
      );
    } catch (e) {
      throw 'Error sharing payment reminder: $e';
    }
  }

  /// Send image directly to WhatsApp - Opens WhatsApp with image ready to send
  static Future<void> sendImageDirectly({
    required File imageFile,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // Direct image sharing - this opens WhatsApp with the image ready to send
      // User just needs to select the contact and send
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: message ?? '',
      );
    } catch (e) {
      throw 'Error sending image directly: $e';
    }
  }

  /// Direct WhatsApp navigation - Opens WhatsApp directly to the contact
  static Future<void> openWhatsAppDirectly({
    required String phoneNumber,
    String? message,
  }) async {
    // Clean phone number - remove all non-digits except +
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure phone number has country code
    if (!cleanPhone.startsWith('+')) {
      if (cleanPhone.startsWith('91')) {
        cleanPhone = '+$cleanPhone';
      } else {
        cleanPhone = '+91$cleanPhone';
      }
    }

    try {
      // Method 1: Try WhatsApp app URL scheme (most direct)
      String whatsappAppUrl = 'whatsapp://send?phone=${cleanPhone.replaceAll('+', '')}';
      if (message != null && message.isNotEmpty) {
        whatsappAppUrl += '&text=${Uri.encodeComponent(message)}';
      }

      final Uri appUrl = Uri.parse(whatsappAppUrl);
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      // Continue to next method
    }

    try {
      // Method 2: Try WhatsApp web URL
      String whatsappWebUrl = 'https://wa.me/$cleanPhone';
      if (message != null && message.isNotEmpty) {
        whatsappWebUrl += '?text=${Uri.encodeComponent(message)}';
      }

      final Uri webUrl = Uri.parse(whatsappWebUrl);
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      // Continue to next method
    }

    try {
      // Method 3: Try alternative WhatsApp API URL
      String altUrl = 'https://api.whatsapp.com/send?phone=${cleanPhone.replaceAll('+', '')}';
      if (message != null && message.isNotEmpty) {
        altUrl += '&text=${Uri.encodeComponent(message)}';
      }

      final Uri apiUrl = Uri.parse(altUrl);
      if (await canLaunchUrl(apiUrl)) {
        await launchUrl(apiUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      // Continue to error
    }

    // If all methods fail, try without message
    if (message != null && message.isNotEmpty) {
      try {
        await openWhatsAppDirectly(phoneNumber: phoneNumber, message: null);
        return;
      } catch (e) {
        // Continue to final error
      }
    }
    throw 'Could not open WhatsApp. Please ensure WhatsApp is installed or check your internet connection.';
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
