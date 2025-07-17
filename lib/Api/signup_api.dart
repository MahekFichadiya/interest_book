import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class SignupResponse {
  final bool success;
  final String message;
  final int? userId;

  SignupResponse({
    required this.success,
    required this.message,
    this.userId,
  });
}

class signupApi {
  Future<SignupResponse> userSignup(
    String name,
    String mobileNo,
    String email,
    String password,
  ) async {
    try {
      final Url = Uri.parse(UrlConstant.SignupApi);
      var body = {
        "name": name,
        "mobileNo": mobileNo,
        "email": email,
        "password": password,
      };
      final newbody = json.encode(body);

      var response = await http.post(Url, body: newbody);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Parse response body
      Map<String, dynamic> responseData = {};
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        print('Error parsing response: $e');
        return SignupResponse(
          success: false,
          message: 'Invalid server response',
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SignupResponse(
          success: true,
          message: responseData['message'] ?? 'User registered successfully',
          userId: responseData['userId'],
        );
      } else if (response.statusCode == 409) {
        // User already exists
        return SignupResponse(
          success: false,
          message: responseData['message'] ?? 'User with this email already exists',
        );
      } else if (response.statusCode == 400) {
        // Bad request (validation errors)
        return SignupResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid input data',
        );
      } else {
        // Other server errors
        return SignupResponse(
          success: false,
          message: responseData['message'] ?? 'Server error occurred',
        );
      }
    } catch (e) {
      print('Network error: $e');
      return SignupResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}