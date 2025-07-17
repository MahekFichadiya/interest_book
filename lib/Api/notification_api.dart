import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interest_book/Api/UrlConstant.dart';
import 'package:interest_book/Model/NotificationModel.dart';

class NotificationApi {

  // Get notifications
  static Future<Map<String, dynamic>> getNotifications({
    required String userId,
    int? isRead,
    String? notificationType,
    String? priority,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'userId': userId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (isRead != null) queryParams['isRead'] = isRead.toString();
      if (notificationType != null) queryParams['notificationType'] = notificationType;
      if (priority != null) queryParams['priority'] = priority;

      final url = Uri.parse(UrlConstant.getNotifications).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<NotificationModel> notifications = (data['notifications'] as List)
              .map((notification) => NotificationModel.fromJson(notification))
              .toList();
          
          return {
            'success': true,
            'notifications': notifications,
            'count': data['count'],
            'unreadCount': data['unreadCount'],
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

  // Update notification (mainly for marking as read)
  static Future<Map<String, dynamic>> updateNotification({
    required String notificationId,
    required String userId,
    bool? isRead,
    String? title,
    String? message,
    String? priority,
  }) async {
    try {
      final url = Uri.parse(UrlConstant.updateNotification);
      
      final body = <String, dynamic>{
        'notificationId': notificationId,
        'userId': userId,
      };

      if (isRead != null) body['isRead'] = isRead ? 1 : 0;
      if (title != null) body['title'] = title;
      if (message != null) body['message'] = message;
      if (priority != null) body['priority'] = priority;

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

  // Mark notification as read
  static Future<Map<String, dynamic>> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    return updateNotification(
      notificationId: notificationId,
      userId: userId,
      isRead: true,
    );
  }

  // Mark all notifications as read
  static Future<Map<String, dynamic>> markAllAsRead({
    required String userId,
  }) async {
    try {
      // First get all unread notifications
      final unreadResult = await getNotifications(
        userId: userId,
        isRead: 0,
        limit: 1000, // Get all unread
      );

      if (unreadResult['success'] != true) {
        return unreadResult;
      }

      final List<NotificationModel> unreadNotifications = unreadResult['notifications'];
      
      // Mark each as read
      int successCount = 0;
      for (final notification in unreadNotifications) {
        final result = await markAsRead(
          notificationId: notification.notificationId,
          userId: userId,
        );
        if (result['success'] == true) {
          successCount++;
        }
      }

      return {
        'success': true,
        'message': 'Marked $successCount notifications as read',
        'markedCount': successCount,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error marking all as read: ${e.toString()}'
      };
    }
  }

  // Get unread count
  static Future<int> getUnreadCount({required String userId}) async {
    try {
      final result = await getNotifications(
        userId: userId,
        isRead: 0,
        limit: 1,
      );

      if (result['success'] == true) {
        return result['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Add overdue notification
  static Future<Map<String, dynamic>> addOverdueNotification({
    required String userId,
    required String custId,
    String? loanId,
    required String reminderId,
    required String title,
    required String message,
    int daysOverdue = 1,
  }) async {
    try {
      final url = Uri.parse(UrlConstant.addOverdueNotification);

      final body = {
        'userId': userId,
        'custId': custId,
        'reminderId': reminderId,
        'title': title,
        'message': message,
        'daysOverdue': daysOverdue,
      };

      if (loanId != null) body['loanId'] = loanId;

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
