import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper over `flutter_local_notifications` — the on-device half
/// of the reminder engine. Used both for the recurring daily reminder
/// and for showing an FCM message that arrived while the app was
/// foregrounded (which platforms don't auto-display on their own).
class LocalNotificationDataSource {
  LocalNotificationDataSource({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const dailyReminderNotificationId = 1001;
  static const _channelId = 'daily_reminder';
  static const _channelName = 'Daily Reminders';
  static const _channelDescription = 'Reminds you to complete today\'s step';

  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(await currentTimezoneId()));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit, macOS: iosInit),
    );
    _initialized = true;
  }

  /// The device's current IANA timezone identifier — the single source
  /// of truth [ReminderRepositoryImpl.rescheduleIfNeeded] compares
  /// against the persisted [ReminderSettings.timezoneId].
  Future<String> currentTimezoneId() async {
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    return localTimezone.identifier;
  }

  Future<bool> requestPermission() async {
    await ensureInitialized();
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return androidGranted ?? iosGranted ?? true;
  }

  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await ensureInitialized();
    tz.setLocalLocation(tz.getLocation(await currentTimezoneId()));

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: dailyReminderNotificationId,
      title: 'Your Challenge is waiting',
      body: "Come back and complete today's step in your 100-day journey.",
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDaily() async {
    await ensureInitialized();
    await _plugin.cancel(id: dailyReminderNotificationId);
  }

  /// Shows a notification immediately — used for the missed-reminder
  /// catch-up and for surfacing a foregrounded FCM message, neither of
  /// which go through [scheduleDaily]'s recurring alarm.
  Future<void> showNow({required int id, required String title, required String body}) async {
    await ensureInitialized();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
