import 'package:equatable/equatable.dart';

/// The reminder engine's persisted schedule for one user — mirrors
/// `ReminderPreference` (`core/database/app_database.dart`), but the
/// domain layer never sees a Drift row type directly.
class ReminderSettings extends Equatable {
  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.timezoneId,
    required this.lastNotifiedDate,
  });

  factory ReminderSettings.defaults() => const ReminderSettings(
    enabled: false,
    hour: 19,
    minute: 0,
    timezoneId: null,
    lastNotifiedDate: null,
  );

  final bool enabled;
  final int hour;
  final int minute;

  /// The IANA identifier the daily notification was last scheduled
  /// against — `null` until the first successful schedule.
  final String? timezoneId;

  /// The last calendar date (time-of-day stripped) a reminder was shown
  /// for, by any path (scheduled fire, FCM, or missed-reminder catch-up).
  final DateTime? lastNotifiedDate;

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    String? timezoneId,
    DateTime? lastNotifiedDate,
  }) => ReminderSettings(
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    timezoneId: timezoneId ?? this.timezoneId,
    lastNotifiedDate: lastNotifiedDate ?? this.lastNotifiedDate,
  );

  @override
  List<Object?> get props => [enabled, hour, minute, timezoneId, lastNotifiedDate];
}
