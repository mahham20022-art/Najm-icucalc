import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// A daily local reminder — deliberately `flutter_local_notifications`,
/// not Firebase Cloud Messaging: this is a device-local, offline
/// reminder ("come back and do today's challenge"), not a
/// server-triggered push, so it works with zero network/backend
/// involvement, consistent with Challenge Mode's fully-offline scope.
class ChallengeReminderScheduler {
  ChallengeReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const _reminderNotificationId = 1001;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit, macOS: iosInit),
    );
    _initialized = true;
  }

  /// Requests OS notification permission (Android 13+, iOS) — call this
  /// from the toggle's `onChanged`, i.e. in direct response to a user
  /// interaction, not proactively at app launch.
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return androidGranted ?? iosGranted ?? true;
  }

  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await _ensureInitialized();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _reminderNotificationId,
      title: 'Your Challenge is waiting',
      body: "Come back and complete today's step in your 100-day journey.",
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'challenge_reminder',
          'Challenge Reminders',
          channelDescription: 'Daily reminder for the 100-day Challenge Mode journey',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel() async {
    await _ensureInitialized();
    await _plugin.cancel(id: _reminderNotificationId);
  }
}
