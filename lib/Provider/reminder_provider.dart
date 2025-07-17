import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_book/Api/reminder_api.dart';
import 'package:interest_book/Model/ReminderModel.dart';
import 'package:interest_book/Services/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  List<ReminderModel> _reminders = [];
  List<ReminderModel> _activeReminders = [];
  List<ReminderModel> _completedReminders = [];
  List<ReminderModel> _todayReminders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ReminderModel> get reminders => _reminders;
  List<ReminderModel> get activeReminders => _activeReminders;
  List<ReminderModel> get completedReminders => _completedReminders;
  List<ReminderModel> get todayReminders => _todayReminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get activeReminderCount => _activeReminders.length;
  int get todayReminderCount => _todayReminders.length;
  int get overdueReminderCount => _activeReminders.where((r) => r.isDue).length;

  // Load reminders from API
  Future<void> loadReminders({String? custId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final result = await ReminderApi.getReminders(
        userId: userId,
        custId: custId,
      );

      if (result['success'] == true) {
        _reminders = result['reminders'] as List<ReminderModel>;
        _filterReminders();
      } else {
        _error = result['message'] ?? 'Failed to load reminders';
      }
    } catch (e) {
      _error = 'Error loading reminders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter reminders into categories
  void _filterReminders() {
    _activeReminders = _reminders.where((r) => r.isActive && !r.isCompleted).toList();
    _completedReminders = _reminders.where((r) => r.isCompleted).toList();
    _todayReminders = _activeReminders.where((r) => r.isToday).toList();
    
    // Sort by date and time
    _activeReminders.sort((a, b) => a.reminderDateTime.compareTo(b.reminderDateTime));
    _todayReminders.sort((a, b) => a.reminderDateTime.compareTo(b.reminderDateTime));
  }

  // Add new reminder
  Future<bool> addReminder({
    required String custId,
    String? loanId,
    required String reminderType,
    required String reminderTitle,
    String? reminderMessage,
    required String reminderDate,
    String reminderTime = '10:00:00',
    bool isRecurring = false,
    String? recurringInterval,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      final result = await ReminderApi.addReminder(
        custId: custId,
        loanId: loanId,
        userId: userId,
        reminderType: reminderType,
        reminderTitle: reminderTitle,
        reminderMessage: reminderMessage,
        reminderDate: reminderDate,
        reminderTime: reminderTime,
        isRecurring: isRecurring,
        recurringInterval: recurringInterval,
      );

      if (result['success'] == true) {
        await loadReminders(); // Reload to get updated list
        
        // Schedule local notification if reminder is in the future
        final reminderDateTime = DateTime.parse('$reminderDate $reminderTime');
        if (reminderDateTime.isAfter(DateTime.now())) {
          final reminder = _reminders.firstWhere(
            (r) => r.reminderId == result['reminderId'].toString(),
            orElse: () => ReminderModel(
              reminderId: result['reminderId'].toString(),
              custId: custId,
              custName: '',
              custPhn: '',
              reminderType: reminderType,
              reminderTitle: reminderTitle,
              reminderMessage: reminderMessage,
              reminderDate: reminderDate,
              reminderTime: reminderTime,
              isRecurring: isRecurring,
              recurringInterval: recurringInterval,
              isActive: true,
              isCompleted: false,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ),
          );
          
          await NotificationService().scheduleReminderNotification(reminder);
        }
        
        return true;
      } else {
        _error = result['message'] ?? 'Failed to add reminder';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error adding reminder: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update reminder
  Future<bool> updateReminder({
    required String reminderId,
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
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      final result = await ReminderApi.updateReminder(
        reminderId: reminderId,
        userId: userId,
        reminderTitle: reminderTitle,
        reminderMessage: reminderMessage,
        reminderDate: reminderDate,
        reminderTime: reminderTime,
        isRecurring: isRecurring,
        recurringInterval: recurringInterval,
        isActive: isActive,
        isCompleted: isCompleted,
      );

      if (result['success'] == true) {
        await loadReminders(); // Reload to get updated list
        
        // Cancel old notification and schedule new one if needed
        final notificationId = int.tryParse(reminderId) ?? 0;
        await NotificationService().cancelNotification(notificationId);
        
        if (isActive != false && isCompleted != true) {
          final updatedReminder = _reminders.firstWhere(
            (r) => r.reminderId == reminderId,
            orElse: () => _reminders.first,
          );
          await NotificationService().scheduleReminderNotification(updatedReminder);
        }
        
        return true;
      } else {
        _error = result['message'] ?? 'Failed to update reminder';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating reminder: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Mark reminder as completed
  Future<bool> markReminderCompleted(String reminderId) async {
    return await updateReminder(
      reminderId: reminderId,
      isCompleted: true,
    );
  }

  // Delete reminder
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      final result = await ReminderApi.deleteReminder(
        reminderId: reminderId,
        userId: userId,
      );

      if (result['success'] == true) {
        // Cancel local notification
        final notificationId = int.tryParse(reminderId) ?? 0;
        await NotificationService().cancelNotification(notificationId);
        
        await loadReminders(); // Reload to get updated list
        return true;
      } else {
        _error = result['message'] ?? 'Failed to delete reminder';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting reminder: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Generate automatic reminders
  Future<bool> generateAutomaticReminders({int daysAhead = 2}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _error = 'User not logged in';
        notifyListeners();
        return false;
      }

      final result = await ReminderApi.generateAutomaticReminders(
        userId: userId,
        daysAhead: daysAhead,
      );

      if (result['success'] == true) {
        await loadReminders(); // Reload to get updated list
        return true;
      } else {
        _error = result['message'] ?? 'Failed to generate automatic reminders';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error generating automatic reminders: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
