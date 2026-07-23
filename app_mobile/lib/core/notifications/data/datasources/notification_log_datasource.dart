import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../database/app_database.dart';

/// Owns all Drift access for `NotificationLog` — the local record of
/// every notification shown, whether by the recurring daily schedule,
/// an FCM push, or a missed-reminder catch-up (`MED100_DATABASE_DESIGN.md`
/// §11). Used here only for missed-reminder / duplicate-suppression
/// checks; a full notification-center UI is out of scope for this task.
class NotificationLogDataSource {
  NotificationLogDataSource(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  Future<void> record({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? deepLink,
  }) async {
    await _db
        .into(_db.notificationLog)
        .insert(
          NotificationLogCompanion.insert(
            id: _uuid.v4(),
            userId: userId,
            type: type,
            title: title,
            body: body,
            deepLink: Value(deepLink),
            receivedAt: DateTime.now(),
          ),
        );
  }

  /// Whether a notification of [type] has already been logged for
  /// [userId] on [date]'s calendar day — the missed-reminder check's
  /// duplicate-suppression guard.
  Future<bool> hasLoggedOn({
    required String userId,
    required String type,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfNextDay = startOfDay.add(const Duration(days: 1));
    final query = _db.select(_db.notificationLog)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.type.equals(type) &
            t.receivedAt.isBiggerOrEqualValue(startOfDay) &
            t.receivedAt.isSmallerThanValue(startOfNextDay),
      );
    final rows = await query.get();
    return rows.isNotEmpty;
  }
}
