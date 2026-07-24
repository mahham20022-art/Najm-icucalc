// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// distinct from their private backing fields for a readable call site —
// an initializing formal would force the parameter name itself to be
// private (see `NotesSyncWorker` for the same convention).

import '../../../core/session/current_user.dart';
import '../../../core/sync/data/outbox_local_datasource.dart';
import '../../../core/sync/data/sync_state_local_datasource.dart';
import '../../../core/sync/sync_worker.dart';
import 'datasources/teaching_sessions_local_datasource.dart';
import 'datasources/teaching_sessions_remote_datasource.dart';

/// Teaching Mode's [SyncWorker] — sessions are append-only (see
/// `TeachingSessionsRemoteDataSource`'s doc comment), so unlike Notes
/// there is no update/delete branch to drain, and unlike Challenge Mode's
/// single document, this is a genuinely incrementally-paged collection,
/// so it keeps its own `SyncState` watermark by `completedAt`.
class TeachingSyncWorker implements SyncWorker {
  TeachingSyncWorker({
    required TeachingSessionsLocalDataSource localDataSource,
    required TeachingSessionsRemoteDataSource remoteDataSource,
    required OutboxLocalDataSource outbox,
    required SyncStateLocalDataSource syncState,
    required CurrentUser currentUser,
  }) : _local = localDataSource,
       _remote = remoteDataSource,
       _outbox = outbox,
       _syncState = syncState,
       _currentUser = currentUser;

  final TeachingSessionsLocalDataSource _local;
  final TeachingSessionsRemoteDataSource _remote;
  final OutboxLocalDataSource _outbox;
  final SyncStateLocalDataSource _syncState;
  final CurrentUser _currentUser;

  static const entityType = 'teaching_session';

  @override
  Future<void> drainOutbox(String userId) async {
    if (userId == guestScopeId) return;

    final pending = await _outbox.pendingFor(userId: userId, entityTypes: const [entityType]);
    for (final row in pending) {
      try {
        final session = await _local.getById(userId, row.entityId);
        if (session != null) {
          await _remote.push(userId, session);
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
    if (entityType != TeachingSyncWorker.entityType) return;

    final since = await _syncState.getLastPulledAt(userId: userId, entityType: entityType);
    final remoteSessions = await _remote.pullSince(userId, since);
    for (final session in remoteSessions) {
      await _local.upsertFromRemote(userId, session);
    }
    if (remoteSessions.isNotEmpty) {
      await _syncState.setLastPulledAt(
        userId: userId,
        entityType: entityType,
        lastPulledAt: remoteSessions
            .map((s) => s.completedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b),
      );
    }
  }
}
