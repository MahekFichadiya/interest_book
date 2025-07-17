import 'package:flutter_test/flutter_test.dart';
import 'package:interest_book/Utils/validation_helper.dart';

void main() {
  group('ValidationHelper Tests', () {
    group('Email Validation', () {
      test('should return null for valid emails', () {
        expect(ValidationHelper.validateEmail('test@example.com'), null);
        expect(ValidationHelper.validateEmail('user.name@domain.co.in'), null);
        expect(ValidationHelper.validateEmail('test123@gmail.com'), null);
      });

      test('should return error for invalid emails', () {
        expect(ValidationHelper.validateEmail(''), 'Email required');
        expect(ValidationHelper.validateEmail('invalid-email'), 'Enter valid email');
        expect(ValidationHelper.validateEmail('test@'), 'Enter valid email');
        expect(ValidationHelper.validateEmail('@domain.com'), 'Enter valid email');
      });
    });

    group('Mobile Number Validation', () {
      test('should return null for valid Indian mobile numbers', () {
        expect(ValidationHelper.validateMobileNumber('9876543210'), null);
        expect(ValidationHelper.validateMobileNumber('8123456789'), null);
        expect(ValidationHelper.validateMobileNumber('7987654321'), null);
        expect(ValidationHelper.validateMobileNumber('6123456789'), null);
      });

      test('should return null for valid international mobile numbers', () {
        expect(ValidationHelper.validateMobileNumber('+91 9876543210'), null);
        expect(ValidationHelper.validateMobileNumber('+1 1234567890'), null);
        expect(ValidationHelper.validateMobileNumber('+44 7123456789'), null);
        expect(ValidationHelper.validateMobileNumber('+86 13812345678'), null);
        expect(ValidationHelper.validateMobileNumber('+33 123456789'), null);
        expect(ValidationHelper.validateMobileNumber('+919876543210'), null); // Without space
      });

      test('should return error for invalid mobile numbers', () {
        expect(ValidationHelper.validateMobileNumber(''), 'Mobile number required');
        expect(ValidationHelper.validateMobileNumber('123456789'), 'Must be exactly 10 digits');
        expect(ValidationHelper.validateMobileNumber('12345678901'), 'Must be exactly 10 digits');
        expect(ValidationHelper.validateMobileNumber('5123456789'), 'Must start with 6, 7, 8, or 9');
        expect(ValidationHelper.validateMobileNumber('7777777777'), 'Cannot have all same digits');
      });

      test('should return error for invalid international mobile numbers', () {
        expect(ValidationHelper.validateMobileNumber('+'), 'Invalid international format. Use +XX XXXXXXXXXX');
        expect(ValidationHelper.validateMobileNumber('+1'), 'Invalid international format. Use +XX XXXXXXXXXX');
        expect(ValidationHelper.validateMobileNumber('+12345 12'), 'Invalid country code');
        expect(ValidationHelper.validateMobileNumber('+91 12345'), 'Invalid phone number length');
        expect(ValidationHelper.validateMobileNumber('+91 123456789012345'), 'Invalid phone number length');
      });

      test('should handle mobile numbers with formatting', () {
        expect(ValidationHelper.validateMobileNumber('987-654-3210'), null);
        expect(ValidationHelper.validateMobileNumber('987 654 3210'), null);
        expect(ValidationHelper.validateMobileNumber('(987) 654-3210'), null);
      });
    });

    group('Password Validation', () {
      test('should return null for valid passwords', () {
        expect(ValidationHelper.validatePassword('test123!'), null);
        expect(ValidationHelper.validatePassword('myPass@1'), null);
        expect(ValidationHelper.validatePassword('secure#9'), null);
        expect(ValidationHelper.validatePassword('valid1!'), null);
      });

      test('should return error for invalid passwords', () {
        expect(ValidationHelper.validatePassword(''), 'Password required');
        expect(ValidationHelper.validatePassword('test'), 'Min 5 characters');
        expect(ValidationHelper.validatePassword('verylongpasswordthatexceeds13chars'), 'Max 13 characters');
        expect(ValidationHelper.validatePassword('testpassword'), 'Need at least 1 digit');
        expect(ValidationHelper.validatePassword('test123'), 'Need at least 1 symbol');
        expect(ValidationHelper.validatePassword('test!@#'), 'Need at least 1 digit');
      });
    });

    group('Confirm Password Validation', () {
      test('should return null when passwords match', () {
        expect(ValidationHelper.validateConfirmPassword('test123!', 'test123!'), null);
      });

      test('should return error when passwords do not match', () {
        expect(ValidationHelper.validateConfirmPassword('', 'test123!'), 'Confirm password');
        expect(ValidationHelper.validateConfirmPassword('different', 'test123!'), "Passwords don't match");
      });
    });
  });
}
