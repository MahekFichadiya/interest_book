import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_book/Api/reminder_api.dart';
import 'package:interest_book/Services/notification_service.dart';
import 'package:interest_book/Services/sms_service.dart';
import 'package:interest_book/Model/ReminderModel.dart';

class RealtimeReminderService {
  static final RealtimeReminderService _instance = RealtimeReminderService._internal();
  factory RealtimeReminderService() => _instance;
  RealtimeReminderService._internal();

  Timer? _reminderCheckTimer;
  bool _isRunning = false;
  List<String> _notifiedReminders = [];

  /// Start real-time reminder checking (every minute)
  void startRealtimeChecking() {
    if (_isRunning) return;
    
    _isRunning = true;
    _reminderCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkDueReminders();
    });
    
    // Also check immediately
    _checkDueReminders();
    
    print('Started real-time reminder checking');
  }

  /// Stop real-time reminder checking
  void stopRealtimeChecking() {
    _reminderCheckTimer?.cancel();
    _isRunning = false;
    print('Stopped real-time reminder checking');
  }

  /// Check for due reminders and send notifications
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
        
        for (final reminder in reminders) {
          await _checkIndividualReminder(reminder, now);
        }
      }
    } catch (e) {
      print('Error checking due reminders: $e');
    }
  }

  /// Check individual reminder and send notification if due
  Future<void> _checkIndividualReminder(ReminderModel reminder, DateTime now) async {
    try {
      final reminderDateTime = reminder.reminderDateTime;
      final reminderKey = '${reminder.reminderId}_${reminderDateTime.millisecondsSinceEpoch}';
      
      // Check if reminder time has passed and we haven't notified yet
      if (now.isAfter(reminderDateTime) || now.isAtSameMomentAs(reminderDateTime)) {
        if (!_notifiedReminders.contains(reminderKey)) {
          await _sendDueReminderNotification(reminder);
          _notifiedReminders.add(reminderKey);
          
          // Clean up old notifications (keep only last 50)
          if (_notifiedReminders.length > 50) {
            _notifiedReminders.removeRange(0, _notifiedReminders.length - 50);
          }
        }
      }
      
      // Check for 5-minute warning
      final fiveMinutesBefore = reminderDateTime.subtract(const Duration(minutes: 5));
      final warningKey = '${reminder.reminderId}_warning_${reminderDateTime.millisecondsSinceEpoch}';
      
      if ((now.isAfter(fiveMinutesBefore) || now.isAtSameMomentAs(fiveMinutesBefore)) && 
          now.isBefore(reminderDateTime)) {
        if (!_notifiedReminders.contains(warningKey)) {
          await _sendWarningReminderNotification(reminder);
          _notifiedReminders.add(warningKey);
        }
      }
      
    } catch (e) {
      print('Error checking individual reminder: $e');
    }
  }

  /// Send due reminder notification
  Future<void> _sendDueReminderNotification(ReminderModel reminder) async {
    try {
      final notificationId = int.tryParse(reminder.reminderId) ?? 0;

      // Send local notification
      await NotificationService().showInstantNotification(
        id: notificationId,
        title: '🔔 Reminder Due: ${reminder.reminderTitle}',
        body: 'Time to call ${reminder.custName} - ${reminder.reminderMessage ?? "Payment reminder"}',
        payload: 'due_reminder_${reminder.reminderId}',
      );

      // Send SMS to customer if phone number is available
      if (reminder.custPhn.isNotEmpty) {
        await _sendReminderSms(reminder);
      }

      print('Sent due reminder notification for: ${reminder.reminderTitle}');
    } catch (e) {
      print('Error sending due reminder notification: $e');
    }
  }

  /// Send 5-minute warning notification
  Future<void> _sendWarningReminderNotification(ReminderModel reminder) async {
    try {
      final notificationId = int.tryParse(reminder.reminderId) ?? 0 + 60000;
      
      await NotificationService().showInstantNotification(
        id: notificationId,
        title: '⏰ Reminder in 5 minutes',
        body: 'Upcoming: ${reminder.reminderTitle} - ${reminder.custName}',
        payload: 'warning_reminder_${reminder.reminderId}',
      );
      
      print('Sent warning reminder notification for: ${reminder.reminderTitle}');
    } catch (e) {
      print('Error sending warning reminder notification: $e');
    }
  }

  /// Manual check for due reminders (can be called from UI)
  Future<void> checkNow() async {
    await _checkDueReminders();
  }

  /// Clear notification history (useful for testing)
  void clearNotificationHistory() {
    _notifiedReminders.clear();
    print('Cleared notification history');
  }

  /// Get status of the service
  bool get isRunning => _isRunning;
  
  /// Get count of notified reminders
  int get notifiedCount => _notifiedReminders.length;

  /// Send SMS reminder to customer
  Future<void> _sendReminderSms(ReminderModel reminder) async {
    try {
      // Get loan amount and interest for SMS
      final principalAmount = double.tryParse(reminder.loanAmount ?? '0') ?? 0.0;
      final interestAmount = 0.0; // You might want to calculate this from the loan data

      final result = await SmsService().sendReminderSms(
        customerName: reminder.custName,
        customerPhone: reminder.custPhn,
        reminderTitle: reminder.reminderTitle,
        reminderMessage: reminder.reminderMessage,
        principalAmount: principalAmount,
        interestAmount: interestAmount,
        dueDate: reminder.formattedDate,
      );

      if (result['success'] == true) {
        print('SMS sent successfully to ${reminder.custName}');
      } else {
        print('Failed to send SMS to ${reminder.custName}: ${result['message']}');
      }
    } catch (e) {
      print('Error sending SMS to ${reminder.custName}: $e');
    }
  }

  /// Send overdue SMS to customer
  Future<void> _sendOverdueSms(ReminderModel reminder, int daysOverdue) async {
    try {
      final principalAmount = double.tryParse(reminder.loanAmount ?? '0') ?? 0.0;
      final interestAmount = 0.0; // Calculate from loan data

      final result = await SmsService().sendOverdueSms(
        customerName: reminder.custName,
        customerPhone: reminder.custPhn,
        reminderTitle: reminder.reminderTitle,
        daysOverdue: daysOverdue,
        principalAmount: principalAmount,
        interestAmount: interestAmount,
      );

      if (result['success'] == true) {
        print('Overdue SMS sent successfully to ${reminder.custName}');
      } else {
        print('Failed to send overdue SMS to ${reminder.custName}: ${result['message']}');
      }
    } catch (e) {
      print('Error sending overdue SMS to ${reminder.custName}: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    stopRealtimeChecking();
  }
}
