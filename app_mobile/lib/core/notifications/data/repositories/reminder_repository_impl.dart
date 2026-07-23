// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// (`settingsDataSource`) distinct from their private backing fields
// (`_settingsDataSource`) for a readable call site — an initializing
// formal would force the parameter name itself to be private.

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../session/current_user.dart';
import '../../domain/entities/notification_permission_status.dart';
import '../../domain/entities/reminder_settings.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/battery_optimization_datasource.dart';
import '../datasources/fcm_datasource.dart';
import '../datasources/local_notification_datasource.dart';
import '../datasources/notification_log_datasource.dart';
import '../datasources/reminder_settings_datasource.dart';

const _dailyReminderType = 'daily_reminder';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({
    required ReminderSettingsDataSource settingsDataSource,
    required LocalNotificationDataSource localNotifications,
    required FcmDataSource fcm,
    required BatteryOptimizationDataSource batteryOptimization,
    required NotificationLogDataSource notificationLog,
    required CurrentUser currentUser,
  }) : _settingsDataSource = settingsDataSource,
       _localNotifications = localNotifications,
       _fcm = fcm,
       _batteryOptimization = batteryOptimization,
       _notificationLog = notificationLog,
       _currentUser = currentUser;

  final ReminderSettingsDataSource _settingsDataSource;
  final LocalNotificationDataSource _localNotifications;
  final FcmDataSource _fcm;
  final BatteryOptimizationDataSource _batteryOptimization;
  final NotificationLogDataSource _notificationLog;
  final CurrentUser _currentUser;

  String get _userId => _currentUser.userId ?? guestScopeId;

  @override
  Stream<ReminderSettings> watchSettings() => _settingsDataSource.watchSettings(_userId);

  @override
  Future<ReminderSettings> getSettings() => _settingsDataSource.getSettings(_userId);

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final localGranted = await _localNotifications.requestPermission();
    final fcmAuth = await _fcm.requestPermission();

    if (fcmAuth == AuthorizationStatus.provisional) {
      return NotificationPermissionStatus.provisional;
    }
    final fcmGranted =
        fcmAuth == AuthorizationStatus.authorized || fcmAuth == AuthorizationStatus.notDetermined;
    final granted = localGranted && fcmGranted;

    if (granted) {
      // Best-effort, non-blocking: the daily reminder still works purely
      // locally even if this never reaches the server.
      unawaited(_fcm.registerToken(_userId));
    }

    return granted ? NotificationPermissionStatus.granted : NotificationPermissionStatus.denied;
  }

  @override
  Future<bool> isIgnoringBatteryOptimizations() =>
      _batteryOptimization.isIgnoringBatteryOptimizations();

  @override
  Future<bool> requestIgnoreBatteryOptimizations() =>
      _batteryOptimization.requestIgnoreBatteryOptimizations();

  @override
  Future<void> setSchedule({required bool enabled, required int hour, required int minute}) async {
    final current = await getSettings();
    final timezoneId = enabled ? await _localNotifications.currentTimezoneId() : current.timezoneId;
    final next = current.copyWith(
      enabled: enabled,
      hour: hour,
      minute: minute,
      timezoneId: timezoneId,
    );
    await _settingsDataSource.saveSettings(_userId, next);

    if (enabled) {
      await _localNotifications.scheduleDaily(hour: hour, minute: minute);
    } else {
      await _localNotifications.cancelDaily();
    }
  }

  @override
  Future<void> rescheduleIfNeeded() async {
    final current = await getSettings();
    if (!current.enabled) return;

    final deviceTimezoneId = await _localNotifications.currentTimezoneId();
    if (current.timezoneId == deviceTimezoneId) return;

    await _localNotifications.scheduleDaily(hour: current.hour, minute: current.minute);
    await _settingsDataSource.saveSettings(_userId, current.copyWith(timezoneId: deviceTimezoneId));
  }

  @override
  Future<void> checkMissedReminder({required Future<bool> Function() isTodayDone}) async {
    final current = await getSettings();
    if (!current.enabled) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledToday = DateTime(now.year, now.month, now.day, current.hour, current.minute);
    if (now.isBefore(scheduledToday)) return; // Today's slot hasn't happened yet.

    if (current.lastNotifiedDate != null && _isSameDate(current.lastNotifiedDate!, today)) {
      return; // Already caught up today.
    }
    if (await _notificationLog.hasLoggedOn(
      userId: _userId,
      type: _dailyReminderType,
      date: today,
    )) {
      return; // The scheduled fire (or an earlier catch-up) already got through.
    }
    if (await isTodayDone()) return; // Nothing to nudge about.

    const title = 'Your Challenge is waiting';
    const body = "You haven't completed today's step yet — it only takes a minute.";
    await _localNotifications.showNow(
      id: LocalNotificationDataSource.dailyReminderNotificationId,
      title: title,
      body: body,
    );
    await _notificationLog.record(
      userId: _userId,
      type: _dailyReminderType,
      title: title,
      body: body,
    );
    await _settingsDataSource.saveSettings(_userId, current.copyWith(lastNotifiedDate: today));
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
