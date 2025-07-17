import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/ReminderModel.dart';

class ReminderApi {

  // Add a new reminder
  static Future<Map<String, dynamic>> addReminder({
    required String custId,
    String? loanId,
    required String userId,
    required String reminderType,
    required String reminderTitle,
    String? reminderMessage,
    required String reminderDate,
    String reminderTime = '10:00:00',
    bool isRecurring = false,
    String? recurringInterval,
  }) async {
    try {
      final url = Uri.parse(UrlConstant.addReminder);
      
      final body = {
        'custId': custId,
        'userId': userId,
        'reminderType': reminderType,
        'reminderTitle': reminderTitle,
        'reminderDate': reminderDate,
        'reminderTime': reminderTime,
        'isRecurring': isRecurring ? 1 : 0,
      };

      if (loanId != null) body['loanId'] = loanId;
      if (reminderMessage != null) body['reminderMessage'] = reminderMessage;
      if (recurringInterval != null) body['recurringInterval'] = recurringInterval;

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

  // Get reminders
  static Future<Map<String, dynamic>> getReminders({
    required String userId,
    String? custId,
    int? isActive,
    int? isCompleted,
  }) async {
    try {
      final queryParams = <String, String>{
        'userId': userId,
      };

      if (custId != null) queryParams['custId'] = custId;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (isCompleted != null) queryParams['isCompleted'] = isCompleted.toString();

      final url = Uri.parse(UrlConstant.getReminders).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<ReminderModel> reminders = (data['reminders'] as List)
              .map((reminder) => ReminderModel.fromJson(reminder))
              .toList();
          
          return {
            'success': true,
            'reminders': reminders,
            'count': data['count'],
          };
        }
        return data;
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

  // Update reminder
  static Future<Map<String, dynamic>> updateReminder({
    required String reminderId,
    required String userId,
    String? reminderTitle,
    String? reminderMessage,
    String? reminderDate,
    String? reminderTime,
    bool? isRecurring,
    String? recurringInterval,
    bool? isActive,
    bool? isCompleted,
  }) async {
    try {
      final url = Uri.parse(UrlConstant.updateReminder);
      
      final body = <String, dynamic>{
        'reminderId': reminderId,
        'userId': userId,
      };

      if (reminderTitle != null) body['reminderTitle'] = reminderTitle;
      if (reminderMessage != null) body['reminderMessage'] = reminderMessage;
      if (reminderDate != null) body['reminderDate'] = reminderDate;
      if (reminderTime != null) body['reminderTime'] = reminderTime;
      if (isRecurring != null) body['isRecurring'] = isRecurring ? 1 : 0;
      if (recurringInterval != null) body['recurringInterval'] = recurringInterval;
      if (isActive != null) body['isActive'] = isActive ? 1 : 0;
      if (isCompleted != null) body['isCompleted'] = isCompleted ? 1 : 0;

      final response = await http.put(
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

  // Delete reminder
  static Future<Map<String, dynamic>> deleteReminder({
    required String reminderId,
    required String userId,
  }) async {
    try {
      final url = Uri.parse(UrlConstant.deleteReminder);
      
      final body = {
        'reminderId': reminderId,
        'userId': userId,
      };

      final response = await http.delete(
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

  // Generate automatic reminders
  static Future<Map<String, dynamic>> generateAutomaticReminders({
    required String userId,
    int daysAhead = 2,
  }) async {
    try {
      final url = Uri.parse(UrlConstant.generateAutomaticReminders);
      
      final body = {
        'userId': userId,
        'daysAhead': daysAhead,
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
}
