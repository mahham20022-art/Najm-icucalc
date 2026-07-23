import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../domain/entities/reminder_settings.dart';

/// Owns all Drift access for the reminder engine's persisted schedule
/// (`ReminderPreference`) — the only place that touches the raw row
/// type, same pattern as `ChallengeLocalDataSource`.
class ReminderSettingsDataSource {
  ReminderSettingsDataSource(this._db);
  final AppDatabase _db;

  Stream<ReminderSettings> watchSettings(String userId) {
    final query = _db.select(_db.reminderPreference)..where((t) => t.userId.equals(userId));
    return query.watchSingleOrNull().map((row) => _toEntity(row) ?? ReminderSettings.defaults());
  }

  Future<ReminderSettings> getSettings(String userId) async {
    final query = _db.select(_db.reminderPreference)..where((t) => t.userId.equals(userId));
    final row = await query.getSingleOrNull();
    return _toEntity(row) ?? ReminderSettings.defaults();
  }

  Future<void> saveSettings(String userId, ReminderSettings settings) async {
    await _db
        .into(_db.reminderPreference)
        .insertOnConflictUpdate(
          ReminderPreferenceCompanion(
            userId: Value(userId),
            enabled: Value(settings.enabled),
            hour: Value(settings.hour),
            minute: Value(settings.minute),
            timezoneId: Value(settings.timezoneId),
            lastNotifiedDate: Value(settings.lastNotifiedDate),
          ),
        );
  }

  ReminderSettings? _toEntity(ReminderPreferenceData? row) {
    if (row == null) return null;
    return ReminderSettings(
      enabled: row.enabled,
      hour: row.hour,
      minute: row.minute,
      timezoneId: row.timezoneId,
      lastNotifiedDate: row.lastNotifiedDate,
    );
  }
}
