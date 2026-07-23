import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/session/current_user.dart';
import '../../domain/entities/challenge_state.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/challenge_local_datasource.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  ChallengeRepositoryImpl(this._localDataSource, this._currentUser);

  final ChallengeLocalDataSource _localDataSource;
  final CurrentUser _currentUser;

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
    return Result.success(fresh);
  }

  @override
  Future<Result<ChallengeState>> toggleBookmark(int day) async {
    final current = await _localDataSource.getState(_userId);
    final bookmarks = {...current.bookmarkedDays};
    if (!bookmarks.remove(day)) bookmarks.add(day);
    final next = current.copyWith(bookmarkedDays: bookmarks);
    await _localDataSource.saveState(_userId, next);
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
    return Result.success(next);
  }
}
