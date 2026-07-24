// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// distinct from their private backing fields for a readable call site —
// an initializing formal would force the parameter name itself to be
// private (see `NotesSyncWorker` for the same convention).

import '../../../core/database/app_database.dart';
import '../../../core/session/current_user.dart';
import '../../../core/sync/data/outbox_local_datasource.dart';
import '../../../core/sync/data/sync_state_local_datasource.dart';
import '../../../core/sync/sync_worker.dart';
import 'datasources/flashcard_schedules_local_datasource.dart';
import 'datasources/flashcard_schedules_remote_datasource.dart';

/// Spaced Repetition's [SyncWorker] — every schedule row is client-owned
/// (see `FlashcardSchedulesRemoteDataSource`'s doc comment), so, like
/// Notes, `create` and `update` both just push the current local row;
/// there is no delete path (a schedule is never removed, only advanced
/// through stages).
class SpacedRepetitionSyncWorker implements SyncWorker {
  SpacedRepetitionSyncWorker({
    required FlashcardSchedulesLocalDataSource localDataSource,
    required FlashcardSchedulesRemoteDataSource remoteDataSource,
    required OutboxLocalDataSource outbox,
    required SyncStateLocalDataSource syncState,
    required CurrentUser currentUser,
  }) : _local = localDataSource,
       _remote = remoteDataSource,
       _outbox = outbox,
       _syncState = syncState,
       _currentUser = currentUser;

  final FlashcardSchedulesLocalDataSource _local;
  final FlashcardSchedulesRemoteDataSource _remote;
  final OutboxLocalDataSource _outbox;
  final SyncStateLocalDataSource _syncState;
  final CurrentUser _currentUser;

  static const entityType = 'flashcard_schedule';

  @override
  Future<void> drainOutbox(String userId) async {
    if (userId == guestScopeId) return;

    final pending = await _outbox.pendingFor(userId: userId, entityTypes: const [entityType]);

    // Collapse duplicate pending rows for the same flashcard (e.g. several
    // grades recorded in a row while offline) to the last one — every
    // push reads the *current* local row, never a per-row payload, so
    // replaying the earlier ones would only repeat the same final write.
    final latestByEntity = <String, OutboxData>{};
    for (final row in pending) {
      latestByEntity[row.entityId] = row;
    }
    for (final row in pending) {
      if (!identical(row, latestByEntity[row.entityId])) {
        await _outbox.markSynced(row.id);
      }
    }

    for (final row in latestByEntity.values) {
      try {
        final schedule = await _local.getEntityByFlashcardId(userId, row.entityId);
        if (schedule != null) {
          await _remote.push(userId, schedule);
        }
        await _outbox.markSynced(row.id);
      } catch (_) {
        await _outbox.markFailed(row);
      }
    }
  }

  @override
  Future<void> pullIncremental(String entityType) async {
    final userId = _currentUser.userId;
    if (userId == null) return;
    if (entityType != SpacedRepetitionSyncWorker.entityType) return;

    final since = await _syncState.getLastPulledAt(userId: userId, entityType: entityType);
    final remoteSchedules = await _remote.pullSince(userId, since);
    for (final schedule in remoteSchedules) {
      await _local.upsertFromRemote(userId, schedule);
    }
    if (remoteSchedules.isNotEmpty) {
      await _syncState.setLastPulledAt(
        userId: userId,
        entityType: entityType,
        lastPulledAt: DateTime.now(),
      );
    }
  }
}
