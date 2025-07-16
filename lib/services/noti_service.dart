// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  FlutterLocalNotificationsPlugin notificationsPlugin =FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Getter
  bool get isInitialized => _isInitialized;

  // INITIALIZE
  Future<void> initNotification() async {
    if (_isInitialized) return; // To prevent re-initialization

    // INIT timezone handling
    tz.initializeTimeZones();
    final String currentTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimezone));

    // ANDROID init settings
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // IOS init settings
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // INIT settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // Initialize plugin
    await notificationsPlugin.initialize(initSettings);
  }
  // Show Notifications
  Future<void> showInstantNotification ({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    )
    );
  }

  // Schedule Notifications
  Future<void> scheduleReminder({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
}) async {
  final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

  await notificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tzTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    //uiLocalNotificationDateInterpretation:
    //    UILocalNotificationDateInterpretation.absoluteTime,
  );
}

// Schedule Recurring Notifications
Future<void> scheduleRecurringReminder({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
  required RepeatInterval repeatInterval, // daily, weekly, etc.
}) async {
  await notificationsPlugin.periodicallyShow(
    id,
    title,
    body,
    repeatInterval,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'recurring_channel_id',
        'Recurring Notifications',
        channelDescription: 'Recurring Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

  // Cancel all notis
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  // Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}