import 'package:drift/drift.dart';

import '../../database/app_database.dart';

/// Owns all Drift access for the shared `SyncState` table (per-user,
/// per-entity-type pull watermarks) — see that table's doc comment in
/// `app_database.dart` for why it's scoped by `userId` as of schema v8.
class SyncStateLocalDataSource {
  SyncStateLocalDataSource(this._db);
  final AppDatabase _db;

  Future<DateTime?> getLastPulledAt({required String userId, required String entityType}) async {
    final query = _db.select(_db.syncState)
      ..where((t) => t.userId.equals(userId) & t.entityType.equals(entityType));
    final row = await query.getSingleOrNull();
    return row?.lastPulledAt;
  }

  Future<void> setLastPulledAt({
    required String userId,
    required String entityType,
    required DateTime lastPulledAt,
  }) async {
    await _db
        .into(_db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            userId: userId,
            entityType: entityType,
            lastPulledAt: Value(lastPulledAt),
          ),
        );
  }
}
