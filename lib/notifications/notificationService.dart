import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';
import 'dart:io';
class LocalNotificationService {
  // Singleton pattern
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permissions
    await _requestPermissions();

    // Initializing timezone (Mandatory for scheduling)
    tz.initializeTimeZones();
    // Set local timezone, e.g., for VN or wherever you like
    tz.setLocalLocation(tz.getLocation('America/New_York')); // Change to your local timezone if needed

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handling user tap on notification (e.g., navigate to Todo detail page)
        if (response.payload != null) {
          log('Notification payload: ${response.payload}');
        }
      },
    );
  }

  // Key function: Scheduling reminder
  Future<void> scheduleTodoReminder({
    required int id,
    required String title,
    required String body,
    required DateTime taskTime,
    String? payload,
  }) async {
    // Calculate time for 15-minute advance reminder
    final reminderTime = taskTime.subtract(const Duration(minutes: 15));

    // Check if the reminder time has already passed; if so, skip it.
    if (reminderTime.isBefore(DateTime.now())) {
      log('Reminder time has already passed, notification will not be set.');
      return;
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      reminderTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'todo_reminders', // channel id
          'Todo Reminders', // channel name
          channelDescription: 'Reminder for tasks 15 minutes before due time',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Show notification immediately
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'instant_notifications',
          'Instant Notifications',
          channelDescription: 'Immediate notifications for test or quick alerts',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Hủy thông báo nếu user xóa task hoặc đổi giờ
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Private method to request permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request notification permission for Android 13+
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
      
      // Request exact alarm permission for Android 12+ (if needed for scheduling)
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      // For iOS, the request is typically handled by initialize()
      // but we can also use permission_handler if needed.
      await Permission.notification.request();
    }
  }
}
