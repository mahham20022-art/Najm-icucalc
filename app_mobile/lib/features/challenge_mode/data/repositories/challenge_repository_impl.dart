import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/session/current_user.dart';
import '../../../../core/sync/data/outbox_local_datasource.dart';
import '../../domain/entities/challenge_state.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../challenge_sync_worker.dart' show ChallengeSyncWorker;
import '../datasources/challenge_local_datasource.dart';

/// Local-first, same convention as `NotesRepositoryImpl`: every write
/// lands in Drift first (so `watchState()` reflects it immediately
/// regardless of connectivity) and enqueues an `Outbox` entry;
/// `ChallengeSyncWorker` (triggered from `challenge_providers.dart` on
/// connectivity restore and app resume) is what actually reaches
/// Firestore. Added after this feature's own self-review flagged that
/// "fully offline by construction" meant a 100-day journey was one
/// reinstall away from being lost forever.
class ChallengeRepositoryImpl implements ChallengeRepository {
  ChallengeRepositoryImpl(this._localDataSource, this._currentUser, this._outbox);

  final ChallengeLocalDataSource _localDataSource;
  final CurrentUser _currentUser;
  final OutboxLocalDataSource _outbox;

  String get _userId => _currentUser.userId ?? guestScopeId;

  @override
  Stream<ChallengeState> watchState() => _localDataSource.watchState(_userId);

  @override
  Future<Result<ChallengeState>> markDone() => _actionToday(
    (state) => state.copyWith(
      completedDays: {...state.completedDays, state.currentDay},
      lastActionDate: DateTime.now(),
    ),
  );

  @override
  Future<Result<ChallengeState>> markSkip() => _actionToday(
    (state) => state.copyWith(
      skippedDays: {...state.skippedDays, state.currentDay},
      lastActionDate: DateTime.now(),
    ),
  );

  @override
  Future<Result<ChallengeState>> restart() async {
    final fresh = ChallengeState.fresh();
    await _localDataSource.saveState(_userId, fresh);
    await _enqueueSync();
    return Result.success(fresh);
  }

  @override
  Future<Result<ChallengeState>> toggleBookmark(int day) async {
    final current = await _localDataSource.getState(_userId);
    final bookmarks = {...current.bookmarkedDays};
    if (!bookmarks.remove(day)) bookmarks.add(day);
    final next = current.copyWith(bookmarkedDays: bookmarks);
    await _localDataSource.saveState(_userId, next);
    await _enqueueSync();
    return Result.success(next);
  }

  /// Daily Unlock's actual enforcement point: reads the current state,
  /// refuses if today has already been actioned, otherwise applies
  /// [apply] and persists. Both Done and Skip go through this so the
  /// "one action per calendar day" rule can't be bypassed by either path.
  Future<Result<ChallengeState>> _actionToday(
    ChallengeState Function(ChallengeState state) apply,
  ) async {
    final current = await _localDataSource.getState(_userId);
    if (current.isComplete) {
      return const Result.failure(ValidationFailure('The 100-day journey is already complete.'));
    }
    if (current.isActionedToday()) {
      return const Result.failure(AlreadyActionedTodayFailure());
    }
    final next = apply(current);
    await _localDataSource.saveState(_userId, next);
    await _enqueueSync();
    return Result.success(next);
  }

  Future<void> _enqueueSync() => _outbox.enqueue(
    userId: _userId,
    entityType: ChallengeSyncWorker.entityType,
    entityId: ChallengeSyncWorker.entityId,
    operation: 'update',
  );
}
