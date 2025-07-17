import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_book/Api/reminder_api.dart';
import 'package:interest_book/Api/notification_api.dart';
import 'package:interest_book/Services/notification_service.dart';
import 'package:interest_book/Model/ReminderModel.dart';
import 'package:interest_book/Model/NotificationModel.dart';

class ReminderScheduler {
  static final ReminderScheduler _instance = ReminderScheduler._internal();
  factory ReminderScheduler() => _instance;
  ReminderScheduler._internal();

  Timer? _dailyCheckTimer;
  Timer? _periodicUpdateTimer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Schedule daily reminder check at 9 AM
    await _scheduleDailyReminderCheck();
    
    // Schedule periodic updates every 30 minutes
    _schedulePeriodicUpdates();
    
    // Generate initial automatic reminders
    await generateAutomaticReminders();
    
    _isInitialized = true;
  }

  void dispose() {
    _dailyCheckTimer?.cancel();
    _periodicUpdateTimer?.cancel();
    _isInitialized = false;
  }

  Future<void> _scheduleDailyReminderCheck() async {
    final now = DateTime.now();
    DateTime nextRun = DateTime(now.year, now.month, now.day, 9, 0); // 9 AM today
    
    // If 9 AM has passed today, schedule for tomorrow
    if (nextRun.isBefore(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }
    
    final duration = nextRun.difference(now);
    
    _dailyCheckTimer = Timer(duration, () {
      _performDailyReminderCheck();
      // Schedule next day's check
      _dailyCheckTimer = Timer.periodic(const Duration(days: 1), (timer) {
        _performDailyReminderCheck();
      });
    });
  }

  void _schedulePeriodicUpdates() {
    _periodicUpdateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _performPeriodicUpdate();
    });
  }

  Future<void> _performDailyReminderCheck() async {
    try {
      print('Performing daily reminder check...');
      
      // Generate automatic reminders for upcoming payments
      await generateAutomaticReminders();
      
      // Check for due reminders and send notifications
      await _checkDueReminders();
      
      // Schedule local notifications for today's reminders
      await _scheduleLocalNotifications();
      
      print('Daily reminder check completed');
    } catch (e) {
      print('Error in daily reminder check: $e');
    }
  }

  Future<void> _performPeriodicUpdate() async {
    try {
      // Update notification counts and check for urgent reminders
      await _checkUrgentReminders();
    } catch (e) {
      print('Error in periodic update: $e');
    }
  }

  Future<void> generateAutomaticReminders({int daysAhead = 2}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) return;

      final result = await ReminderApi.generateAutomaticReminders(
        userId: userId,
        daysAhead: daysAhead,
      );

      if (result['success'] == true) {
        print('Generated ${result['remindersCreated']} automatic reminders');
        
        // Show notification about new reminders if any were created
        if (result['remindersCreated'] > 0) {
          await NotificationService().showInstantNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: 'New Payment Reminders',
            body: '${result['remindersCreated']} new payment reminders have been created',
            payload: 'auto_reminders',
          );
        }
      }
    } catch (e) {
      print('Error generating automatic reminders: $e');
    }
  }

  Future<void> _checkDueReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return;

      // Get all active reminders
      final result = await ReminderApi.getReminders(
        userId: userId,
        isActive: 1,
        isCompleted: 0,
      );

      if (result['success'] == true) {
        final List<ReminderModel> reminders = result['reminders'];
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (final reminder in reminders) {
          final reminderDate = DateTime.parse(reminder.reminderDate);
          final reminderDateOnly = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);

          // Check if reminder is overdue (past due date)
          if (reminderDateOnly.isBefore(today)) {
            await _createOverdueNotification(reminder, now.difference(reminderDateOnly).inDays);
          }
          // Check if reminder is due today
          else if (reminderDateOnly.isAtSameMomentAs(today)) {
            await _sendReminderNotification(reminder);
          }
        }
      }
    } catch (e) {
      print('Error checking due reminders: $e');
    }
  }

  Future<void> _checkUrgentReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) return;

      // Get urgent notifications
      final result = await NotificationApi.getNotifications(
        userId: userId,
        isRead: 0,
        priority: 'urgent',
        limit: 10,
      );

      if (result['success'] == true) {
        final List<NotificationModel> urgentNotifications = result['notifications'];
        
        for (final notification in urgentNotifications) {
          if (notification.isActionRequired) {
            await NotificationService().showInstantNotification(
              id: int.tryParse(notification.notificationId) ?? 0,
              title: 'URGENT: ${notification.title}',
              body: notification.message,
              payload: 'urgent_${notification.notificationId}',
            );
          }
        }
      }
    } catch (e) {
      print('Error checking urgent reminders: $e');
    }
  }

  Future<void> _scheduleLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) return;

      // Get today's reminders
      final result = await ReminderApi.getReminders(
        userId: userId,
        isActive: 1,
        isCompleted: 0,
      );

      if (result['success'] == true) {
        final List<ReminderModel> reminders = result['reminders'];
        final today = DateTime.now();
        
        for (final reminder in reminders) {
          final reminderDateTime = reminder.reminderDateTime;
          
          // Schedule notification for reminders that are today and in the future
          if (reminderDateTime.year == today.year &&
              reminderDateTime.month == today.month &&
              reminderDateTime.day == today.day &&
              reminderDateTime.isAfter(today)) {
            
            await NotificationService().scheduleReminderNotification(reminder);
          }
        }
      }
    } catch (e) {
      print('Error scheduling local notifications: $e');
    }
  }

  Future<void> _sendReminderNotification(ReminderModel reminder) async {
    try {
      // Send immediate notification for due reminder
      await NotificationService().showInstantNotification(
        id: int.tryParse(reminder.reminderId) ?? 0,
        title: 'Reminder Due: ${reminder.reminderTitle}',
        body: 'Time to call ${reminder.custName} - ${reminder.reminderMessage ?? "Payment reminder"}',
        payload: 'reminder_due_${reminder.reminderId}',
      );
    } catch (e) {
      print('Error sending reminder notification: $e');
    }
  }

  Future<void> _createOverdueNotification(ReminderModel reminder, int daysOverdue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return;

      // Check if we already created an overdue notification for this reminder today
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Check if notification already exists for today
      final existingNotifications = await NotificationApi.getNotifications(
        userId: userId,
        notificationType: 'reminder',
        limit: 50,
      );

      if (existingNotifications['success'] == true) {
        final notifications = existingNotifications['notifications'] as List;
        final alreadyExists = notifications.any((n) =>
          n.title.contains('OVERDUE') &&
          n.custId == reminder.custId &&
          n.reminderId == reminder.reminderId &&
          n.createdAt.startsWith(todayStr)
        );

        if (alreadyExists) {
          return; // Don't create duplicate overdue notifications
        }
      }

      // Create overdue notification in database
      final notificationTitle = 'OVERDUE: ${reminder.reminderTitle}';
      final notificationMessage = '${reminder.custName} reminder is $daysOverdue day${daysOverdue > 1 ? 's' : ''} overdue. Please call immediately!';

      // Create notification in database
      final dbResult = await NotificationApi.addOverdueNotification(
        userId: userId,
        custId: reminder.custId,
        loanId: reminder.loanId,
        reminderId: reminder.reminderId,
        title: notificationTitle,
        message: notificationMessage,
        daysOverdue: daysOverdue,
      );

      if (dbResult['success'] == true && dbResult['alreadyExists'] != true) {
        // Send local notification only if database notification was created
        await NotificationService().showInstantNotification(
          id: int.tryParse(reminder.reminderId) ?? 0 + 10000, // Add offset to avoid ID conflicts
          title: notificationTitle,
          body: notificationMessage,
          payload: 'overdue_reminder_${reminder.reminderId}',
        );

        print('Created overdue notification for reminder ${reminder.reminderId} ($daysOverdue days overdue)');
      }

    } catch (e) {
      print('Error creating overdue notification: $e');
    }
  }

  // Manual trigger for generating reminders (can be called from UI)
  Future<bool> triggerAutomaticReminders({int daysAhead = 2}) async {
    try {
      await generateAutomaticReminders(daysAhead: daysAhead);
      return true;
    } catch (e) {
      print('Error triggering automatic reminders: $e');
      return false;
    }
  }

  // Check and schedule reminders for a specific customer
  Future<void> scheduleCustomerReminders(String custId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) return;

      final result = await ReminderApi.getReminders(
        userId: userId,
        custId: custId,
        isActive: 1,
        isCompleted: 0,
      );

      if (result['success'] == true) {
        final List<ReminderModel> reminders = result['reminders'];
        
        for (final reminder in reminders) {
          if (reminder.reminderDateTime.isAfter(DateTime.now())) {
            await NotificationService().scheduleReminderNotification(reminder);
          }
        }
      }
    } catch (e) {
      print('Error scheduling customer reminders: $e');
    }
  }

  // Get reminder statistics
  Future<Map<String, int>> getReminderStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return {
          'total': 0,
          'active': 0,
          'completed': 0,
          'overdue': 0,
          'today': 0,
        };
      }

      final result = await ReminderApi.getReminders(userId: userId);

      if (result['success'] == true) {
        final List<ReminderModel> reminders = result['reminders'];
        final today = DateTime.now();
        
        int total = reminders.length;
        int active = reminders.where((r) => r.isActive && !r.isCompleted).length;
        int completed = reminders.where((r) => r.isCompleted).length;
        int overdue = reminders.where((r) => r.isDue && !r.isCompleted).length;
        int todayCount = reminders.where((r) => r.isToday && !r.isCompleted).length;
        
        return {
          'total': total,
          'active': active,
          'completed': completed,
          'overdue': overdue,
          'today': todayCount,
        };
      }
    } catch (e) {
      print('Error getting reminder stats: $e');
    }
    
    return {
      'total': 0,
      'active': 0,
      'completed': 0,
      'overdue': 0,
      'today': 0,
    };
  }
}
