import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';

/// Owns all Drift access for the shared `Outbox` table — every
/// client-writable feature enqueues its pending mutations here and a
/// `SyncWorker` implementation drains them (see `sync_worker.dart`).
/// `features/notes` is the first real consumer; this datasource is kept
/// in `core/sync` rather than duplicated per-feature since the table
/// itself was already declared as shared, cross-cutting infrastructure.
class OutboxLocalDataSource {
  OutboxLocalDataSource(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  Future<void> enqueue({
    required String userId,
    required String entityType,
    required String entityId,
    required String operation,
    Map<String, dynamic> payload = const {},
  }) async {
    await _db
        .into(_db.outbox)
        .insert(
          OutboxCompanion.insert(
            id: _uuid.v4(),
            userId: userId,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: jsonEncode(payload),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Every not-yet-synced row for [userId] across [entityTypes], oldest
  /// first — includes previously-`failed` rows, not just `pending` ones,
  /// so a transient failure gets retried on the next drain rather than
  /// stalling forever.
  Future<List<OutboxData>> pendingFor({required String userId, required List<String> entityTypes}) {
    final query = _db.select(_db.outbox)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.entityType.isIn(entityTypes) &
            t.status.isNotValue('synced'),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  Future<void> markSynced(String id) async {
    await (_db.delete(_db.outbox)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markFailed(OutboxData row) async {
    await (_db.update(_db.outbox)..where((t) => t.id.equals(row.id))).write(
      OutboxCompanion(
        status: const Value('failed'),
        lastAttemptAt: Value(DateTime.now()),
        retryCount: Value(row.retryCount + 1),
      ),
    );
  }
}
