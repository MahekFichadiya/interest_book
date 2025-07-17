import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';

class ProfileMoneyApi {
  static Future<Map<String, double>> getProfileMoneyInfo(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${UrlConstant.getProfileMoneyInfo}?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final data = jsonResponse['data'];
          return {
            'you_gave': (data['you_gave'] ?? 0).toDouble(),
            'you_got': (data['you_got'] ?? 0).toDouble(),
            'you_gave_interest': (data['you_gave_interest'] ?? 0).toDouble(),
            'you_got_interest': (data['you_got_interest'] ?? 0).toDouble(),
            'total_you_gave': (data['total_you_gave'] ?? 0).toDouble(),
            'total_you_got': (data['total_you_got'] ?? 0).toDouble(),
          };
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to fetch money info');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to fetch money info');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
