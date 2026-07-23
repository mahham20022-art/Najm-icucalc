import '../entities/notification_permission_status.dart';
import '../entities/reminder_settings.dart';

/// The reminder engine's own domain-owned interface, exactly one per
/// signed-in user. Deliberately feature-agnostic: it knows how to
/// request permission, schedule/reschedule a daily local notification,
/// register the device for Firebase Cloud Messaging, and detect a missed
/// reminder — but it has no idea what "today's task" means for any given
/// feature. Callers that need missed-reminder detection pass in their
/// own "is today already done" predicate (see [checkMissedReminder]),
/// keeping this module below every feature in the dependency graph
/// (`MED100_ARCHITECTURE.md` §3).
abstract interface class ReminderRepository {
  Stream<ReminderSettings> watchSettings();

  Future<ReminderSettings> getSettings();

  /// Requests both the local-notification permission (Android 13+, iOS)
  /// and the Firebase Messaging authorization in one call, since to the
  /// user this is a single "can Med100 notify you?" decision.
  Future<NotificationPermissionStatus> requestPermission();

  /// Android only — whether the app is already exempt from Doze/App
  /// Standby battery optimization. Always `true` on platforms where the
  /// concept doesn't apply (iOS, web).
  Future<bool> isIgnoringBatteryOptimizations();

  /// Opens the OS's "ignore battery optimizations" dialog for this app.
  /// A no-op returning `true` on platforms without the concept.
  Future<bool> requestIgnoreBatteryOptimizations();

  /// Persists [enabled]/[hour]/[minute] and (re)schedules or cancels the
  /// daily local notification to match.
  Future<void> setSchedule({required bool enabled, required int hour, required int minute});

  /// Re-applies the persisted schedule against the device's *current*
  /// timezone. A no-op if the reminder is disabled or the timezone
  /// hasn't changed since it was last scheduled — call this on every
  /// app resume so travel across timezones corrects the fire time
  /// without the user having to touch the reminder settings again.
  Future<void> rescheduleIfNeeded();

  /// If the reminder is enabled, today's scheduled time has already
  /// passed, nothing has been logged for today yet, and [isTodayDone]
  /// reports the day's task is still outstanding, fires an immediate
  /// local notification instead of silently waiting for tomorrow's slot
  /// — the fallback described in `MED100_ARCHITECTURE.md` §11 for when
  /// the OS drops a scheduled alarm (Doze, battery optimization, a
  /// missed boot-reschedule).
  Future<void> checkMissedReminder({required Future<bool> Function() isTodayDone});
}
