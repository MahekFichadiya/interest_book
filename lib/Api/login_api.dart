import "dart:convert";
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Model/UserModel.dart';

class LoginResponse {
  final bool success;
  final String message;

  LoginResponse({required this.success, required this.message});
}

class LoginAPI {
  Future<LoginResponse> userLogin(String email, String password) async {
    try {
      final Url = Uri.parse(UrlConstant.LoginApi);
      final prefs = await SharedPreferences.getInstance();
      var body = {"email": email, "password": password};
      final newbody = json.encode(body);

      var response = await http.post(
        Url,
        body: newbody,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Parse response body
      Map<String, dynamic> responseData = {};
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        print('Error parsing response: $e');
        return LoginResponse(
          success: false,
          message: 'Invalid server response',
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        var userData = responseData;
        UserModel user = UserModel.fromJson(userData);
        prefs.setString("name", user.data.name);
        prefs.setString("email", user.data.email);
        prefs.setString("mobileNo", user.data.mobileNo);
        prefs.setString("userId", user.data.userId);
        // Note: Password is no longer stored for security reasons
        print('userId: ${prefs.getString("userId")}');
        print(userData);
        var userId = prefs.getString("userId");
        print("userId: $userId");

        return LoginResponse(
          success: true,
          message: responseData['message'] ?? 'Login successful',
        );
      } else {
        // Handle different error cases with specific messages
        String errorMessage = responseData['message'] ?? 'Login failed';

        // Use server-provided error messages or provide fallbacks
        switch (response.statusCode) {
          case 400:
            // Use the specific message from server, or provide fallback
            if (errorMessage.isEmpty) {
              errorMessage = 'Please check your email and password';
            }
            break;
          case 401:
            errorMessage = errorMessage.isNotEmpty ? errorMessage : 'Incorrect password. Please try again.';
            break;
          case 404:
            errorMessage = errorMessage.isNotEmpty ? errorMessage : 'No account found with this email address';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = errorMessage.isNotEmpty ? errorMessage : 'Login failed. Please check your credentials.';
        }

        return LoginResponse(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      print('Network error: $e');
      return LoginResponse(
        success: false,
        message: 'Network error. Please check your internet connection.',
      );
    }
  }
}
