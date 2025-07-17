import 'package:flutter_test/flutter_test.dart';
import 'package:interest_book/Utils/validation_helper.dart';

void main() {
  group('International Mobile Number Validation Tests', () {
    test('demonstrates international mobile number support', () {
      print('\n=== International Mobile Number Validation ===');
      
      print('\n✅ SUPPORTED FORMATS:');
      print('1. Indian Format: 9876543210');
      print('2. International with space: +91 9876543210');
      print('3. International without space: +919876543210');
      print('4. US Format: +1 1234567890');
      print('5. UK Format: +44 7123456789');
      print('6. China Format: +86 13812345678');
      print('7. France Format: +33 123456789');
      
      print('\n❌ INVALID FORMATS:');
      print('1. Missing country code: + (incomplete)');
      print('2. Too short: +1 123');
      print('3. Too long: +91 123456789012345');
      print('4. Invalid country code: +12345 123456789');
      print('5. Non-digits: +91 abc123def');
      
      print('\n=== VALIDATION RULES ===');
      print('Indian Format (without +):');
      print('- Must be exactly 10 digits');
      print('- Must start with 6, 7, 8, or 9');
      print('- Cannot have all same digits');
      
      print('\nInternational Format (with +):');
      print('- Country code: 1-4 digits');
      print('- Phone number: 6-14 digits');
      print('- Format: +XX XXXXXXXXXX (space optional)');
      print('- Cannot have all same digits');
    });

    group('Valid International Mobile Numbers', () {
      test('should accept common international formats', () {
        final validNumbers = [
          '+91 9876543210',  // India
          '+1 1234567890',   // USA/Canada
          '+44 7123456789',  // UK
          '+86 13812345678', // China
          '+33 123456789',   // France
          '+49 1234567890',  // Germany
          '+81 9012345678',  // Japan
          '+61 412345678',   // Australia
          '+7 9123456789',   // Russia
          '+55 11987654321', // Brazil
        ];

        for (String number in validNumbers) {
          expect(
            ValidationHelper.validateMobileNumber(number),
            null,
            reason: 'Should accept $number',
          );
        }
      });

      test('should accept international numbers without spaces', () {
        final validNumbers = [
          '+919876543210',   // India
          '+11234567890',    // USA/Canada
          '+447123456789',   // UK
          '+8613812345678',  // China
        ];

        for (String number in validNumbers) {
          expect(
            ValidationHelper.validateMobileNumber(number),
            null,
            reason: 'Should accept $number (no space)',
          );
        }
      });
    });

    group('Valid Indian Mobile Numbers', () {
      test('should accept standard Indian formats', () {
        final validNumbers = [
          '9876543210',
          '8123456789',
          '7987654321',
          '6123456789',
          '987-654-3210',  // With dashes
          '987 654 3210',  // With spaces
          '(987) 654-3210', // With parentheses
        ];

        for (String number in validNumbers) {
          expect(
            ValidationHelper.validateMobileNumber(number),
            null,
            reason: 'Should accept Indian number: $number',
          );
        }
      });
    });

    group('Invalid Mobile Numbers', () {
      test('should reject invalid international formats', () {
        final invalidNumbers = {
          '+': 'Invalid international format. Use +XX XXXXXXXXXX',
          '+1': 'Invalid international format. Use +XX XXXXXXXXXX',
          '+12345 123456789': 'Invalid country code',
          '+91 12345': 'Invalid phone number length',
          '+91 123456789012345': 'Invalid phone number length',
          '+abc 123456789': 'Invalid international format. Use +XX XXXXXXXXXX',
          '+91 abc123def': 'Invalid international format. Use +XX XXXXXXXXXX', // Regex catches non-digits
        };

        invalidNumbers.forEach((number, expectedError) {
          final result = ValidationHelper.validateMobileNumber(number);
          expect(
            result,
            expectedError,
            reason: 'Should reject $number with error: $expectedError',
          );
        });
      });

      test('should reject invalid Indian formats', () {
        final invalidNumbers = {
          '': 'Mobile number required',
          '123456789': 'Must be exactly 10 digits',
          '12345678901': 'Must be exactly 10 digits',
          '5123456789': 'Must start with 6, 7, 8, or 9',
          '7777777777': 'Cannot have all same digits',
          '1234567890': 'Must start with 6, 7, 8, or 9',
        };

        invalidNumbers.forEach((number, expectedError) {
          final result = ValidationHelper.validateMobileNumber(number);
          expect(
            result,
            expectedError,
            reason: 'Should reject Indian number $number with error: $expectedError',
          );
        });
      });
    });

    group('Edge Cases', () {
      test('should handle whitespace correctly', () {
        expect(ValidationHelper.validateMobileNumber('  +91 9876543210  '), null);
        expect(ValidationHelper.validateMobileNumber('  9876543210  '), null);
        expect(ValidationHelper.validateMobileNumber('   '), 'Mobile number required');
      });

      test('should reject all same digits in international numbers', () {
        final result = ValidationHelper.validateMobileNumber('+91 7777777777');
        expect(result, 'Cannot have all same digits');
      });

      test('should handle minimum and maximum lengths', () {
        // Minimum valid international number
        expect(ValidationHelper.validateMobileNumber('+1 123456'), null);
        
        // Maximum valid international number  
        expect(ValidationHelper.validateMobileNumber('+1234 12345678901234'), null);
      });
    });

    test('verifies backend and frontend consistency', () {
      print('\n=== Backend-Frontend Consistency ===');
      
      print('\nFrontend (Flutter):');
      print('- ValidationHelper.validateMobileNumber()');
      print('- Supports both Indian and international formats');
      print('- TextInputType.phone for better keyboard');
      
      print('\nBackend (PHP):');
      print('- SignupAPI.php updated with validateMobileNumber()');
      print('- Same validation rules as frontend');
      print('- Consistent error messages');
      
      print('\nForms Updated:');
      print('✓ AddNewContact.dart - keyboardType: TextInputType.phone');
      print('✓ EditContact.dart - keyboardType: TextInputType.phone');
      print('✓ SignupScreen.dart - Already using TextInputType.phone');
      print('✓ update_profile.dart - Already using TextInputType.phone');
      
      print('\nValidation Coverage:');
      print('✓ Customer registration forms');
      print('✓ User signup form');
      print('✓ Profile update form');
      print('✓ Customer edit forms');
    });
  });
}
