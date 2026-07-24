// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// distinct from their private backing fields for a readable call site —
// an initializing formal would force the parameter name itself to be
// private (see `NotesSyncWorker` for the same convention).

import '../../../core/session/current_user.dart';
import '../../../core/sync/data/outbox_local_datasource.dart';
import '../../../core/sync/sync_worker.dart';
import '../domain/entities/challenge_state.dart';
import 'datasources/challenge_local_datasource.dart';
import 'datasources/challenge_remote_datasource.dart';

/// Challenge Mode's [SyncWorker] — a single per-user progress document,
/// much simpler than `NotesSyncWorker`'s per-entity CRUD: every mutation
/// enqueues one outbox row for the same fixed entity id (`'state'`), so
/// draining just re-pushes the current local state; pulling compares
/// [ChallengeState.daysActioned] against the remote copy rather than a
/// timestamp, since each day is actioned at most once ("Daily Unlock"),
/// making it a reasonable monotonic proxy for "more recent" without this
/// single-active-device app needing real timestamp-based conflict
/// resolution.
class ChallengeSyncWorker implements SyncWorker {
  ChallengeSyncWorker({
    required ChallengeLocalDataSource localDataSource,
    required ChallengeRemoteDataSource remoteDataSource,
    required OutboxLocalDataSource outbox,
  }) : _local = localDataSource,
       _remote = remoteDataSource,
       _outbox = outbox;

  final ChallengeLocalDataSource _local;
  final ChallengeRemoteDataSource _remote;
  final OutboxLocalDataSource _outbox;

  static const entityType = 'challenge_progress';

  /// The single fixed document id every outbox row and Firestore document
  /// uses — there's only ever one progress document per user, so this
  /// isn't a per-entity id the way Notes' are. Shared with
  /// `ChallengeRepositoryImpl._enqueueSync` so the literal exists once.
  static const entityId = 'state';

  @override
  Future<void> drainOutbox(String userId) async {
    if (userId == guestScopeId) return;

    final pending = await _outbox.pendingFor(userId: userId, entityTypes: const [entityType]);
    if (pending.isEmpty) return;

    try {
      final state = await _local.getState(userId);
      await _remote.push(userId, state);
      for (final row in pending) {
        await _outbox.markSynced(row.id);
      }
    } catch (_) {
      for (final row in pending) {
        await _outbox.markFailed(row);
      }
    }
  }

  @override
  Future<void> pullIncremental(String entityType) async {
    // No `SyncState` watermark needed — this is a single document, not
    // an incrementally-paged collection, so every pull just fetches it.
  }

  /// Not part of [SyncWorker]: called once at app start (see
  /// `challenge_providers.dart`) rather than through the generic
  /// `pullIncremental(entityType)` signature, since there's nothing to
  /// incrementally page through.
  Future<void> pullIfMoreAdvanced(String userId) async {
    if (userId == guestScopeId) return;
    final remote = await _remote.pull(userId);
    if (remote == null) return;
    final local = await _local.getState(userId);
    if (remote.daysActioned > local.daysActioned) {
      await _local.saveState(userId, remote);
    }
  }
}
