import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_book/Api/notification_api.dart';
import 'package:interest_book/Model/NotificationModel.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _unreadNotifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  bool get hasUnreadNotifications => _unreadCount > 0;

  // Load notifications from API
  Future<void> loadNotifications({
    int? isRead,
    String? notificationType,
    String? priority,
    int limit = 50,
    int offset = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final result = await NotificationApi.getNotifications(
        userId: userId,
        isRead: isRead,
        notificationType: notificationType,
        priority: priority,
        limit: limit,
        offset: offset,
      );

      if (result['success'] == true) {
        _notifications = result['notifications'] as List<NotificationModel>;
        _unreadCount = result['unreadCount'] ?? 0;
        _filterNotifications();
      } else {
        _error = result['message'] ?? 'Failed to load notifications';
      }
    } catch (e) {
      _error = 'Error loading notifications: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter notifications
  void _filterNotifications() {
    _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    
    // Sort by creation date (newest first)
    _notifications.sort((a, b) => b.createdDateTime.compareTo(a.createdDateTime));
    _unreadNotifications.sort((a, b) => b.createdDateTime.compareTo(a.createdDateTime));
  }

  // Load only unread notifications
  Future<void> loadUnreadNotifications() async {
    await loadNotifications(isRead: 0);
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      final result = await NotificationApi.markAsRead(
        notificationId: notificationId,
        userId: userId,
      );

      if (result['success'] == true) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now().toIso8601String(),
          );
          _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
          _filterNotifications();
          notifyListeners();
        }
        return true;
      } else {
        _error = result['message'] ?? 'Failed to mark notification as read';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error marking notification as read: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      final result = await NotificationApi.markAllAsRead(userId: userId);

      if (result['success'] == true) {
        // Update local state
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = _notifications[i].copyWith(
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
            );
          }
        }
        _unreadCount = 0;
        _filterNotifications();
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to mark all notifications as read';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error marking all notifications as read: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.notificationType == type).toList();
  }

  // Get high priority notifications
  List<NotificationModel> getHighPriorityNotifications() {
    return _notifications.where((n) => n.isHighPriority).toList();
  }

  // Get urgent notifications
  List<NotificationModel> getUrgentNotifications() {
    return _notifications.where((n) => n.isUrgent).toList();
  }

  // Get notifications requiring action
  List<NotificationModel> getActionRequiredNotifications() {
    return _notifications.where((n) => n.isActionRequired && !n.isRead).toList();
  }

  // Update unread count only
  Future<void> updateUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        final count = await NotificationApi.getUnreadCount(userId: userId);
        if (_unreadCount != count) {
          _unreadCount = count;
          notifyListeners();
        }
      }
    } catch (e) {
      // Silently handle error for background updates
      print('Error updating unread count: ${e.toString()}');
    }
  }

  // Refresh notifications (pull to refresh)
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add a new notification locally (for real-time updates)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    _filterNotifications();
    notifyListeners();
  }

  // Remove notification locally
  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications.removeAt(index);
      if (!notification.isRead) {
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
      }
      _filterNotifications();
      notifyListeners();
    }
  }

  // Check for new overdue notifications
  Future<void> checkForOverdueNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        // Get urgent/overdue notifications
        final result = await NotificationApi.getNotifications(
          userId: userId,
          isRead: 0,
          priority: 'urgent',
          limit: 20,
        );

        if (result['success'] == true) {
          final List<NotificationModel> urgentNotifications = result['notifications'];
          final overdueNotifications = urgentNotifications.where((n) =>
            n.title.contains('OVERDUE') && n.notificationType == 'reminder'
          ).toList();

          if (overdueNotifications.isNotEmpty) {
            // Update local state with new overdue notifications
            for (final notification in overdueNotifications) {
              final exists = _notifications.any((n) => n.notificationId == notification.notificationId);
              if (!exists) {
                addNotification(notification);
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error checking for overdue notifications: $e');
    }
  }
}
