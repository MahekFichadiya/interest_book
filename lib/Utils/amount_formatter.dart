import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utility class for formatting amounts and currency values consistently
/// throughout the application
class AmountFormatter {
  // Indian number format with commas
  static final NumberFormat _indianFormat = NumberFormat('#,##,###', 'en_IN');
  
  // Format for currency with 2 decimal places
  static final NumberFormat _currencyFormat = NumberFormat('#,##,##0.00', 'en_IN');
  
  // Format for percentage
  static final NumberFormat _percentageFormat = NumberFormat('#0.0#', 'en_IN');

  /// Format amount as Indian currency with rupee symbol
  /// For whole numbers (principal amounts), shows no decimals
  /// Example: ₹1,00,000
  static String formatCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    
    double value = _parseToDouble(amount);
    if (value == 0) return '₹0';
    
    // If it's a whole number, don't show decimals
    if (value == value.toInt()) {
      return '₹${_indianFormat.format(value.toInt())}';
    }
    
    return '₹${_currencyFormat.format(value)}';
  }

  /// Format amount with 2 decimal places for interest calculations
  /// Example: ₹1,00,000.50
  static String formatCurrencyWithDecimals(dynamic amount) {
    if (amount == null) return '₹0.00';
    
    double value = _parseToDouble(amount);
    return '₹${_currencyFormat.format(value)}';
  }

  /// Format amount without currency symbol
  /// Example: 1,00,000
  static String formatAmount(dynamic amount) {
    if (amount == null) return '0';
    
    double value = _parseToDouble(amount);
    if (value == 0) return '0';
    
    // If it's a whole number, don't show decimals
    if (value == value.toInt()) {
      return _indianFormat.format(value.toInt());
    }
    
    return _currencyFormat.format(value);
  }

  /// Format percentage with 1-2 decimal places
  /// Example: 12.5%
  static String formatPercentage(dynamic percentage) {
    if (percentage == null) return '0%';
    
    double value = _parseToDouble(percentage);
    return '${_percentageFormat.format(value)}%';
  }

  /// Format amount for display in compact form
  /// Example: ₹1.2L for ₹1,20,000
  static String formatCompactCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    
    double value = _parseToDouble(amount);
    if (value == 0) return '₹0';
    
    if (value >= 10000000) { // 1 Crore
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) { // 1 Lakh
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) { // 1 Thousand
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    
    return formatCurrency(value);
  }

  /// Parse various input types to double
  static double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove currency symbols and commas
      String cleanValue = value.replaceAll(RegExp(r'[₹,\s]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  /// Format amount for API/database storage (plain number string)
  static String formatForStorage(dynamic amount) {
    double value = _parseToDouble(amount);
    return value.toString();
  }

  /// Check if amount is positive
  static bool isPositive(dynamic amount) {
    return _parseToDouble(amount) > 0;
  }

  /// Check if amount is negative
  static bool isNegative(dynamic amount) {
    return _parseToDouble(amount) < 0;
  }

  /// Format amount with color coding for positive/negative values
  static Map<String, dynamic> formatWithColor(dynamic amount) {
    double value = _parseToDouble(amount);
    String formattedAmount = formatCurrency(value);

    if (value > 0) {
      return {
        'amount': '+$formattedAmount',
        'color': 'green',
        'isPositive': true,
      };
    } else if (value < 0) {
      return {
        'amount': formattedAmount,
        'color': 'red',
        'isPositive': false,
      };
    } else {
      return {
        'amount': formattedAmount,
        'color': 'black',
        'isPositive': null,
      };
    }
  }

  /// Format interest amount with advance payment indication
  /// When totalInterest is negative, it means advance payment (show in green with +)
  /// When totalInterest is positive, it means amount due (show normally)
  static Map<String, dynamic> formatInterestWithAdvancePayment(dynamic totalInterest) {
    double value = _parseToDouble(totalInterest);

    if (value < 0) {
      // Negative totalInterest means advance payment
      double advanceAmount = value.abs(); // Convert to positive
      return {
        'amount': '+${formatCurrencyWithDecimals(advanceAmount)}',
        'color': const Color(0xFF2E7D32), // Dark green for better contrast (Material Green 800)
        'lightColor': const Color(0xFFE8F5E8), // Light green background
        'borderColor': const Color(0xFF4CAF50), // Medium green border
        'isAdvancePayment': true,
        'displayText': 'Advance Payment',
        'icon': Icons.trending_up,
      };
    } else if (value > 0) {
      // Positive totalInterest means amount due
      return {
        'amount': formatCurrencyWithDecimals(value),
        'color': const Color(0xFFE65100), // Dark orange for better contrast (Material Orange 900)
        'lightColor': const Color(0xFFFFF3E0), // Light orange background
        'borderColor': const Color(0xFFFF9800), // Medium orange border
        'isAdvancePayment': false,
        'displayText': 'Interest Due',
        'icon': Icons.schedule,
      };
    } else {
      // Zero means no interest due or advance
      return {
        'amount': formatCurrencyWithDecimals(0),
        'color': const Color(0xFF424242), // Dark grey for better contrast (Material Grey 800)
        'lightColor': const Color(0xFFF5F5F5), // Light grey background
        'borderColor': const Color(0xFF9E9E9E), // Medium grey border
        'isAdvancePayment': false,
        'displayText': 'No Interest',
        'icon': Icons.check_circle,
      };
    }
  }

  /// Format daily interest rate from monthly rate
  static String formatDailyInterest(dynamic monthlyAmount) {
    double monthly = _parseToDouble(monthlyAmount);
    double daily = monthly / 30;
    return formatCurrencyWithDecimals(daily);
  }

  /// Format monthly interest rate from daily rate
  static String formatMonthlyInterest(dynamic dailyAmount) {
    double daily = _parseToDouble(dailyAmount);
    double monthly = daily * 30;
    return formatCurrencyWithDecimals(monthly);
  }

  /// Format amount for real-time input display (without currency symbol)
  /// Example: 1,00,000
  static String formatInputAmount(String input) {
    if (input.isEmpty) return '';

    // Remove all non-digit characters except decimal point
    String cleanInput = input.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimal points
    List<String> parts = cleanInput.split('.');
    if (parts.length > 2) {
      cleanInput = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Parse the clean input
    double? value = double.tryParse(cleanInput);
    if (value == null) return '';

    // Format with Indian number format
    if (cleanInput.contains('.')) {
      return _currencyFormat.format(value);
    } else {
      return _indianFormat.format(value.toInt());
    }
  }

  /// Get the raw numeric value from formatted input
  static String getRawValue(String formattedInput) {
    if (formattedInput.isEmpty) return '';
    return formattedInput.replaceAll(RegExp(r'[^\d.]'), '');
  }

  /// Create a TextInputFormatter for amount fields
  static TextInputFormatter getAmountInputFormatter() {
    return AmountInputFormatter();
  }
}

/// Custom TextInputFormatter for amount fields
class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters except decimal point
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimal points
    List<String> parts = cleanText.split('.');
    if (parts.length > 2) {
      cleanText = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Limit decimal places to 2
    if (cleanText.contains('.')) {
      List<String> decimalParts = cleanText.split('.');
      if (decimalParts[1].length > 2) {
        cleanText = '${decimalParts[0]}.${decimalParts[1].substring(0, 2)}';
      }
    }

    // Parse and format the amount
    double? value = double.tryParse(cleanText);
    if (value == null) {
      return oldValue;
    }

    String formattedText;
    if (cleanText.contains('.')) {
      formattedText = NumberFormat('#,##,##0.##', 'en_IN').format(value);
    } else {
      formattedText = NumberFormat('#,##,###', 'en_IN').format(value.toInt());
    }

    // Calculate the new cursor position
    int newCursorPosition = formattedText.length;

    // Try to maintain cursor position relative to the end
    int oldCursorFromEnd = oldValue.text.length - oldValue.selection.baseOffset;
    newCursorPosition = (formattedText.length - oldCursorFromEnd).clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
