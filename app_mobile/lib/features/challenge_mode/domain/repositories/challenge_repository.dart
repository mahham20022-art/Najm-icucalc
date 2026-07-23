import '../../../../core/error/result.dart';
import '../entities/challenge_state.dart';

/// Domain-owned interface — the data layer implements this against
/// Drift, so Challenge Mode is fully offline by construction (no
/// Firestore, no network, no AI), per the Repository Pattern
/// (`MED100_ARCHITECTURE.md` §5).
abstract interface class ChallengeRepository {
  /// Reactive — the ViewModel watches this directly so any change (mark
  /// done, skip, restart, bookmark) is reflected immediately without a
  /// manual refetch.
  Stream<ChallengeState> watchState();

  Future<Result<ChallengeState>> markDone();

  Future<Result<ChallengeState>> markSkip();

  /// Wipes all progress back to day 1 — destructive, gated behind a
  /// confirmation dialog in the UI, not here.
  Future<Result<ChallengeState>> restart();

  Future<Result<ChallengeState>> toggleBookmark(int day);
}
