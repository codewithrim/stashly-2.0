import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final ReminderService instance = ReminderService._internal();

  ReminderService._internal();

  Future<void> initialize({void Function(String? itemId)? onSelectNotification}) async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          onSelectNotification?.call(response.payload);
        }
      },
    );
  }

  /// Request POST_NOTIFICATIONS permission on Android 13+ with graceful denial handling
  Future<bool> requestPermission() async {
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedule notification for an item using inexact scheduling (no exact-alarm permission needed)
  Future<void> scheduleReminder({
    required String itemId,
    required String title,
    required DateTime scheduledDate,
  }) async {
    final notificationId = itemId.hashCode.abs() % 2147483647;

    const androidDetails = AndroidNotificationDetails(
      'stashly_reminders',
      'Stashly Reminders',
      channelDescription: 'Notifications for items scheduled to resurface later',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

    // If time is already in the past, do not schedule
    if (scheduledTz.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Reminder: $title',
      "Tap to view this item you stashed for later.",
      scheduledTz,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: itemId,
    );
  }

  /// Cancel reminder when item or reminder is cleared
  Future<void> cancelReminder(String itemId) async {
    final notificationId = itemId.hashCode.abs() % 2147483647;
    await _notificationsPlugin.cancel(notificationId);
  }
}
