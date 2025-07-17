import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_book/Api/reminder_api.dart';
import 'package:interest_book/Api/notification_api.dart';
import 'package:interest_book/Services/notification_service.dart';
import 'package:interest_book/Services/reminder_scheduler.dart';

class ReminderTestHelper {
  /// Test the complete reminder system functionality
  static Future<Map<String, dynamic>> testReminderSystem() async {
    final results = <String, dynamic>{
      'success': true,
      'tests': <String, dynamic>{},
      'errors': <String>[],
    };

    try {
      // Test 1: Check if user is logged in
      results['tests']['user_login'] = await _testUserLogin();
      
      // Test 2: Test notification service initialization
      results['tests']['notification_service'] = await _testNotificationService();
      
      // Test 3: Test reminder scheduler initialization
      results['tests']['reminder_scheduler'] = await _testReminderScheduler();
      
      // Test 4: Test API connectivity
      results['tests']['api_connectivity'] = await _testApiConnectivity();
      
      // Test 5: Test automatic reminder generation
      results['tests']['auto_reminders'] = await _testAutomaticReminders();
      
      // Test 6: Test notification retrieval
      results['tests']['notifications'] = await _testNotifications();
      
      print('=== Reminder System Test Results ===');
      results['tests'].forEach((test, result) {
        print('$test: ${result['success'] ? 'PASS' : 'FAIL'}');
        if (!result['success']) {
          print('  Error: ${result['error']}');
          results['errors'].add('$test: ${result['error']}');
        }
      });
      
      // Overall success if all tests pass
      results['success'] = results['tests'].values.every((test) => test['success'] == true);
      
    } catch (e) {
      results['success'] = false;
      results['errors'].add('Test execution error: $e');
      print('Test execution error: $e');
    }
    
    return results;
  }

  static Future<Map<String, dynamic>> _testUserLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null || userId.isEmpty) {
        return {
          'success': false,
          'error': 'User not logged in - userId not found in SharedPreferences'
        };
      }
      
      return {
        'success': true,
        'userId': userId,
        'message': 'User logged in successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error checking user login: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> _testNotificationService() async {
    try {
      await NotificationService().initialize();
      final permissionGranted = await NotificationService().requestPermissions();
      
      return {
        'success': true,
        'permissionGranted': permissionGranted,
        'message': 'Notification service initialized successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error initializing notification service: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> _testReminderScheduler() async {
    try {
      await ReminderScheduler().initialize();
      
      return {
        'success': true,
        'message': 'Reminder scheduler initialized successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error initializing reminder scheduler: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> _testApiConnectivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return {
          'success': false,
          'error': 'No userId available for API test'
        };
      }
      
      // Test reminder API
      final reminderResult = await ReminderApi.getReminders(userId: userId);
      
      if (reminderResult['success'] != true) {
        return {
          'success': false,
          'error': 'Reminder API test failed: ${reminderResult['message']}'
        };
      }
      
      // Test notification API
      final notificationResult = await NotificationApi.getNotifications(userId: userId);
      
      if (notificationResult['success'] != true) {
        return {
          'success': false,
          'error': 'Notification API test failed: ${notificationResult['message']}'
        };
      }
      
      return {
        'success': true,
        'reminderCount': reminderResult['count'] ?? 0,
        'notificationCount': notificationResult['count'] ?? 0,
        'message': 'API connectivity test successful'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'API connectivity test error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> _testAutomaticReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return {
          'success': false,
          'error': 'No userId available for automatic reminder test'
        };
      }
      
      final result = await ReminderApi.generateAutomaticReminders(
        userId: userId,
        daysAhead: 2,
      );
      
      if (result['success'] != true) {
        return {
          'success': false,
          'error': 'Automatic reminder generation failed: ${result['message']}'
        };
      }
      
      return {
        'success': true,
        'remindersCreated': result['remindersCreated'] ?? 0,
        'notificationsCreated': result['notificationsCreated'] ?? 0,
        'message': 'Automatic reminder generation successful'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Automatic reminder test error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> _testNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return {
          'success': false,
          'error': 'No userId available for notification test'
        };
      }
      
      final result = await NotificationApi.getNotifications(
        userId: userId,
        limit: 10,
      );
      
      if (result['success'] != true) {
        return {
          'success': false,
          'error': 'Notification retrieval failed: ${result['message']}'
        };
      }
      
      return {
        'success': true,
        'notificationCount': result['count'] ?? 0,
        'unreadCount': result['unreadCount'] ?? 0,
        'message': 'Notification retrieval successful'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Notification test error: $e'
      };
    }
  }

  /// Test local notification functionality
  static Future<void> testLocalNotification() async {
    try {
      await NotificationService().showInstantNotification(
        id: 999,
        title: 'Test Notification',
        body: 'This is a test notification for the reminder system',
        payload: 'test_notification',
      );
      print('Test notification sent successfully');
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  /// Test overdue notification functionality
  static Future<void> testOverdueNotification() async {
    try {
      await NotificationService().showInstantNotification(
        id: 998,
        title: 'OVERDUE: Test Payment Reminder',
        body: 'Test Customer reminder is 2 days overdue. Please call immediately!',
        payload: 'test_overdue_notification',
      );
      print('Test overdue notification sent successfully');
    } catch (e) {
      print('Error sending test overdue notification: $e');
    }
  }

  /// Show test results in a dialog
  static void showTestResults(BuildContext context, Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reminder System Test Results',
          style: TextStyle(
            color: results['success'] ? Colors.green[700] : Colors.red[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Overall Status: ${results['success'] ? 'PASS' : 'FAIL'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: results['success'] ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Test Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...results['tests'].entries.map((entry) {
                final testName = entry.key;
                final testResult = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        testResult['success'] ? Icons.check_circle : Icons.error,
                        color: testResult['success'] ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          testName.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (results['errors'].isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Errors:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ...results['errors'].map((error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• $error',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!results['success'])
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                testLocalNotification();
              },
              child: const Text('Test Notification'),
            ),
        ],
      ),
    );
  }
}
