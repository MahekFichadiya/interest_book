import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class ForgotPasswordAPI {
  
  /// Send OTP to user's email
  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      final url = Uri.parse(UrlConstant.sendOTP);
      var body = {"email": email};
      final requestBody = json.encode(body);
      
      var response = await http.post(
        url, 
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print('Send OTP Response Status: ${response.statusCode}');
      print('Send OTP Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent successfully',
          'data': data,
        };
      } else {
        var errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to send OTP',
          'data': null,
        };
      }
    } catch (e) {
      print('Send OTP Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
        'data': null,
      };
    }
  }
  
  /// Verify OTP entered by user
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final url = Uri.parse(UrlConstant.verifyOTP);
      print('Verify OTP URL: $url');

      // Ensure email and OTP are clean strings
      final cleanEmail = email.trim();
      final cleanOTP = otp.trim();

      var body = {
        "email": cleanEmail,
        "otp": cleanOTP,
      };
      final requestBody = json.encode(body);
      print('Verify OTP Request Body: $requestBody');
      print('Email: "$cleanEmail", OTP: "$cleanOTP"');

      var response = await http.post(
        url,
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Verify OTP Response Status: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          var data = json.decode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'OTP verified successfully',
            'data': data,
          };
        } catch (jsonError) {
          print('JSON Parse Error: $jsonError');
          return {
            'success': false,
            'message': 'Server response error. Raw response: ${response.body}',
            'data': null,
          };
        }
      } else {
        try {
          var errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Invalid OTP',
            'data': null,
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message': 'Server error (${response.statusCode}): ${response.body}',
            'data': null,
          };
        }
      }
    } catch (e) {
      print('Verify OTP Error: $e');
      String errorMessage = 'Network error. Please check your connection.';

      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Cannot connect to server. Check if XAMPP is running.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Server response format error.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      return {
        'success': false,
        'message': errorMessage,
        'data': null,
      };
    }
  }
  
  /// Reset password after OTP verification
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      final url = Uri.parse(UrlConstant.resetPassword);
      var body = {
        "email": email,
        "newPassword": newPassword,
      };
      final requestBody = json.encode(body);
      
      var response = await http.post(
        url, 
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print('Reset Password Response Status: ${response.statusCode}');
      print('Reset Password Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successfully',
          'data': data,
        };
      } else {
        var errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to reset password',
          'data': null,
        };
      }
    } catch (e) {
      print('Reset Password Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
        'data': null,
      };
    }
  }
}
