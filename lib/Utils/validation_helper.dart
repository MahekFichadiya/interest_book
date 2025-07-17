import 'dart:core';

/// Comprehensive validation utility class for the Interest Book application
class ValidationHelper {
  // Email validation regex - more comprehensive than the current one
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  // Mobile number validation regex (supports Indian format)
  static final RegExp _mobileRegex = RegExp(r'^[6-9]\d{9}$');

  // International mobile number validation regex
  // Supports formats like: +91 9876543210, +1 1234567890, +44 7123456789, etc.
  static final RegExp _internationalMobileRegex = RegExp(r'^\+[\d\s]{2,23}$');

  // Password strength regex patterns
  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasDigits = RegExp(r'\d');
  static final RegExp _hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Validates email address
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email required";
    }

    // Remove leading/trailing whitespace
    value = value.trim();

    if (value.isEmpty) {
      return "Email required";
    }

    // Check length constraints
    if (value.length > 254) {
      return "Email too long";
    }

    // Check for valid email format
    if (!_emailRegex.hasMatch(value)) {
      return "Enter valid email";
    }

    // Check for consecutive dots
    if (value.contains('..')) {
      return "Invalid email format";
    }

    // Check if starts or ends with dot
    if (value.startsWith('.') || value.endsWith('.')) {
      return "Invalid email format";
    }

    return null;
  }

  /// Validates mobile number (supports both Indian and international formats)
  /// Supports formats: 9876543210, +91 9876543210, +1 1234567890, etc.
  /// Returns null if valid, error message if invalid
  static String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Mobile number required";
    }

    // Trim whitespace
    value = value.trim();

    if (value.isEmpty) {
      return "Mobile number required";
    }

    // Check if it's an international format (starts with +)
    if (value.startsWith('+')) {
      return _validateInternationalMobileNumber(value);
    } else {
      return _validateIndianMobileNumber(value);
    }
  }

  /// Validates Indian mobile number format
  static String? _validateIndianMobileNumber(String value) {
    // Remove all non-digit characters
    String cleanValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanValue.isEmpty) {
      return "Mobile number required";
    }

    // Check exact length
    if (cleanValue.length != 10) {
      return "Must be exactly 10 digits";
    }

    // Check if it starts with valid digits (6-9 for Indian mobile numbers)
    if (!_mobileRegex.hasMatch(cleanValue)) {
      return "Must start with 6, 7, 8, or 9";
    }

    // Check for all same digits
    if (RegExp(r'^(\d)\1{9}$').hasMatch(cleanValue)) {
      return "Cannot have all same digits";
    }

    return null;
  }

  /// Validates international mobile number format
  static String? _validateInternationalMobileNumber(String value) {
    // Check basic international format
    if (!_internationalMobileRegex.hasMatch(value)) {
      return "Invalid international format. Use +XX XXXXXXXXXX";
    }

    // Extract country code and number
    String numberWithoutPlus = value.substring(1);
    List<String> parts = numberWithoutPlus.split(RegExp(r'\s+'));

    String? countryCode;
    String? numberPart;

    if (parts.length == 1) {
      // No space between country code and number (e.g., +919876543210)
      String allDigits = parts[0];
      if (allDigits.length < 7 || allDigits.length > 18) {
        return "Invalid international number length";
      }

      // Extract country code (1-4 digits) and number part
      if (allDigits.length >= 7) {
        // Try different country code lengths (prefer longer country codes)
        for (int i = 4; i >= 1; i--) {
          if (i < allDigits.length) {
            String testCountryCode = allDigits.substring(0, i);
            String testNumberPart = allDigits.substring(i);

            if (testNumberPart.length >= 6 && testNumberPart.length <= 14) {
              countryCode = testCountryCode;
              numberPart = testNumberPart;
              break;
            }
          }
        }

        if (countryCode == null || numberPart == null) {
          return "Invalid international format. Use +XX XXXXXXXXXX";
        }
      } else {
        return "Invalid international format. Use +XX XXXXXXXXXX";
      }
    } else {
      // Space between country code and number (e.g., +91 9876543210)
      countryCode = parts[0];
      numberPart = parts.sublist(1).join('');

      // Validate country code (1-4 digits)
      if (countryCode.isEmpty || countryCode.length > 4) {
        return "Invalid country code";
      }

      // Validate number part (6-14 digits)
      if (numberPart.length < 6 || numberPart.length > 14) {
        return "Invalid phone number length";
      }

      // Check if all digits
      if (!RegExp(r'^\d+$').hasMatch(countryCode) || !RegExp(r'^\d+$').hasMatch(numberPart)) {
        return "Phone number must contain only digits";
      }
    }

    // Check for all same digits in the phone number part (not including country code)
    if (numberPart.length > 6 && RegExp(r'^(\d)\1+$').hasMatch(numberPart)) {
      return "Cannot have all same digits";
    }

    return null;
  }

  /// Validates password with specific requirements
  /// Requirements: 5-13 characters, at least one digit, at least one symbol
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password required";
    }

    // Length check: minimum 5, maximum 13 characters
    if (value.length < 5) {
      return "Min 5 characters";
    }

    if (value.length > 13) {
      return "Max 13 characters";
    }

    // Check for at least one digit
    if (!_hasDigits.hasMatch(value)) {
      return "Need at least 1 digit";
    }

    // Check for at least one special character/symbol
    if (!_hasSpecialCharacters.hasMatch(value)) {
      return "Need at least 1 symbol";
    }

    return null;
  }

  /// Validates confirm password
  /// Returns null if valid, error message if invalid
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return "Confirm password";
    }

    if (value != originalPassword) {
      return "Passwords don't match";
    }

    return null;
  }

  /// Validates name fields (first name, last name, etc.)
  /// Returns null if valid, error message if invalid
  static String? validateName(String? value, {String fieldName = "Name"}) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }

    value = value.trim();

    if (value.isEmpty) {
      return "$fieldName is required";
    }

    if (value.length < 2) {
      return "$fieldName must be at least 2 characters";
    }

    if (value.length > 50) {
      return "$fieldName must not exceed 50 characters";
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return "$fieldName can only contain letters, spaces, hyphens, and apostrophes";
    }

    // Check for consecutive spaces
    if (value.contains('  ')) {
      return "$fieldName cannot contain consecutive spaces";
    }

    return null;
  }

  /// Validates required text fields
  /// Returns null if valid, error message if invalid
  static String? validateRequired(String? value, {String fieldName = "Field"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  /// Get password strength score (0-4) based on new requirements
  /// 0: Very Weak, 1: Weak, 2: Fair, 3: Good, 4: Strong
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // Length check (5-13 characters range)
    if (password.length >= 5) score++;
    if (password.length >= 8) score++;

    // Required character checks
    if (_hasDigits.hasMatch(password)) score++;
    if (_hasSpecialCharacters.hasMatch(password)) score++;

    // Bonus checks
    if (_hasUppercase.hasMatch(password)) score++;
    if (_hasLowercase.hasMatch(password)) score++;

    // Penalty for exceeding max length
    if (password.length > 13) score = score > 1 ? score - 1 : 0;

    return score > 4 ? 4 : score;
  }

  /// Get password strength text
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
        return "Very Weak";
      case 1:
        return "Weak";
      case 2:
        return "Fair";
      case 3:
        return "Good";
      case 4:
        return "Strong";
      default:
        return "Unknown";
    }
  }

  /// Get password strength color
  static int getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
        return 0xFFE53E3E; // Red
      case 1:
        return 0xFFFF8C00; // Dark Orange
      case 2:
        return 0xFFFFA500; // Orange
      case 3:
        return 0xFF32CD32; // Lime Green
      case 4:
        return 0xFF008000; // Green
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// Validates OTP (One Time Password)
  /// Returns null if valid, error message if invalid
  static String? validateOTP(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return "OTP is required";
    }

    // Remove any spaces
    value = value.replaceAll(' ', '');

    if (value.length != length) {
      return "OTP must be $length digits";
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "OTP must contain only numbers";
    }

    return null;
  }
}
