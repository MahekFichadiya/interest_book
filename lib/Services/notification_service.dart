import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:interest_book/Model/ReminderModel.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap
    print('Notification tapped: ${notificationResponse.payload}');
    // You can navigate to specific screens based on the payload
  }

  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Notifications for payment reminders',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      autoCancel: false,
      ongoing: false,
      styleInformation: BigTextStyleInformation(''),
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Notifications for payment reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> scheduleReminderNotification(ReminderModel reminder) async {
    final int notificationId = int.tryParse(reminder.reminderId) ?? 0;
    final DateTime reminderDateTime = reminder.reminderDateTime;

    // Schedule notification at the exact reminder time
    if (reminderDateTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: notificationId,
        title: 'Reminder: ${reminder.reminderTitle}',
        body: reminder.reminderMessage ?? 'Time to call ${reminder.custName}',
        scheduledDate: reminderDateTime,
        payload: 'reminder_${reminder.reminderId}',
      );

      print('Scheduled notification for ${reminder.reminderTitle} at ${reminderDateTime}');
    }

    // Also schedule a notification 5 minutes before
    final DateTime earlyNotificationTime = reminderDateTime.subtract(
      const Duration(minutes: 5),
    );

    if (earlyNotificationTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: notificationId + 50000, // Different ID for early notification
        title: 'Upcoming: ${reminder.reminderTitle}',
        body: 'Reminder in 5 minutes - ${reminder.custName}',
        scheduledDate: earlyNotificationTime,
        payload: 'early_reminder_${reminder.reminderId}',
      );

      print('Scheduled early notification for ${reminder.reminderTitle} at ${earlyNotificationTime}');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Schedule daily reminder check
  Future<void> scheduleDailyReminderCheck() async {
    const int dailyCheckId = 999999;
    
    // Schedule for 9 AM every day
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);
    
    // If 9 AM has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: dailyCheckId,
      title: 'Daily Reminder Check',
      body: 'Check your reminders for today',
      scheduledDate: scheduledDate,
      payload: 'daily_check',
    );
  }

  // Show payment due notification
  Future<void> showPaymentDueNotification({
    required String customerName,
    required String amount,
    required String dueDate,
  }) async {
    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Payment Due - $customerName',
      body: 'Interest payment of ₹$amount is due on $dueDate',
      payload: 'payment_due_$customerName',
    );
  }
}
