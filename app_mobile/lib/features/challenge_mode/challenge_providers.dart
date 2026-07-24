import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import '../../core/session/current_user.dart';
import '../../core/sync/sync_providers.dart';
import 'data/challenge_sync_worker.dart';
import 'data/datasources/challenge_local_datasource.dart';
import 'data/datasources/challenge_remote_datasource.dart';
import 'data/repositories/challenge_repository_impl.dart';
import 'domain/repositories/challenge_repository.dart';
import 'domain/usecases/mark_day_done_usecase.dart';
import 'domain/usecases/restart_challenge_usecase.dart';
import 'domain/usecases/skip_day_usecase.dart';
import 'domain/usecases/toggle_bookmark_usecase.dart';

/// The DI graph for Challenge Mode, following the same
/// dataSourceProvider → repositoryProvider → useCaseProvider chain as
/// every other feature (`MED100_ARCHITECTURE.md` §6).
final challengeLocalDataSourceProvider = Provider<ChallengeLocalDataSource>((ref) {
  return ChallengeLocalDataSource(ref.watch(appDatabaseProvider));
});

final challengeRemoteDataSourceProvider = Provider<ChallengeRemoteDataSource>((ref) {
  return ChallengeRemoteDataSource();
});

final challengeSyncWorkerProvider = Provider<ChallengeSyncWorker>((ref) {
  return ChallengeSyncWorker(
    localDataSource: ref.watch(challengeLocalDataSourceProvider),
    remoteDataSource: ref.watch(challengeRemoteDataSourceProvider),
    outbox: ref.watch(outboxLocalDataSourceProvider),
  );
});

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepositoryImpl(
    ref.watch(challengeLocalDataSourceProvider),
    ref.watch(currentUserProvider),
    ref.watch(outboxLocalDataSourceProvider),
  );
});

final markDayDoneUseCaseProvider = Provider<MarkDayDoneUseCase>((ref) {
  return MarkDayDoneUseCase(ref.watch(challengeRepositoryProvider));
});

final skipDayUseCaseProvider = Provider<SkipDayUseCase>((ref) {
  return SkipDayUseCase(ref.watch(challengeRepositoryProvider));
});

final restartChallengeUseCaseProvider = Provider<RestartChallengeUseCase>((ref) {
  return RestartChallengeUseCase(ref.watch(challengeRepositoryProvider));
});

final toggleBookmarkUseCaseProvider = Provider<ToggleBookmarkUseCase>((ref) {
  return ToggleBookmarkUseCase(ref.watch(challengeRepositoryProvider));
});

/// Pulls the remote copy if it's more advanced than this device's, then
/// drains any locally-queued mutations — safe to call opportunistically
/// (app resume, connectivity restore) since both sides are idempotent and
/// a no-op for a guest session. Mirrors `notes_providers.dart`'s
/// `triggerNotesSync`.
Future<void> triggerChallengeSync(WidgetRef ref) async {
  final userId = ref.read(currentUserProvider).userId;
  if (userId == null) return;

  final worker = ref.read(challengeSyncWorkerProvider);
  await worker.pullIfMoreAdvanced(userId);
  await worker.drainOutbox(userId);
}
