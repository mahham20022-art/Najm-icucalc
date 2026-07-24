import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import '../../core/session/current_user.dart';
import '../../core/sync/sync_providers.dart';
import 'data/datasources/flashcard_schedules_local_datasource.dart';
import 'data/datasources/flashcard_schedules_remote_datasource.dart';
import 'data/repositories/spaced_repetition_repository_impl.dart';
import 'data/spaced_repetition_sync_worker.dart';
import 'domain/entities/flashcard_schedule.dart';
import 'domain/entities/spaced_repetition_statistics.dart';
import 'domain/repositories/spaced_repetition_repository.dart';
import 'domain/usecases/ensure_scheduled_usecase.dart';
import 'domain/usecases/get_due_count_usecase.dart';
import 'domain/usecases/record_review_usecase.dart';
import 'domain/usecases/watch_due_queue_usecase.dart';
import 'domain/usecases/watch_statistics_usecase.dart';

final flashcardSchedulesLocalDataSourceProvider = Provider<FlashcardSchedulesLocalDataSource>((
  ref,
) {
  return FlashcardSchedulesLocalDataSource(ref.watch(appDatabaseProvider));
});

final flashcardSchedulesRemoteDataSourceProvider = Provider<FlashcardSchedulesRemoteDataSource>((
  ref,
) {
  return FlashcardSchedulesRemoteDataSource();
});

final spacedRepetitionSyncWorkerProvider = Provider<SpacedRepetitionSyncWorker>((ref) {
  return SpacedRepetitionSyncWorker(
    localDataSource: ref.watch(flashcardSchedulesLocalDataSourceProvider),
    remoteDataSource: ref.watch(flashcardSchedulesRemoteDataSourceProvider),
    outbox: ref.watch(outboxLocalDataSourceProvider),
    syncState: ref.watch(syncStateLocalDataSourceProvider),
    currentUser: ref.watch(currentUserProvider),
  );
});

final spacedRepetitionRepositoryProvider = Provider<SpacedRepetitionRepository>((ref) {
  return SpacedRepetitionRepositoryImpl(
    localDataSource: ref.watch(flashcardSchedulesLocalDataSourceProvider),
    outbox: ref.watch(outboxLocalDataSourceProvider),
    currentUser: ref.watch(currentUserProvider),
  );
});

final ensureScheduledUseCaseProvider = Provider<EnsureScheduledUseCase>((ref) {
  return EnsureScheduledUseCase(ref.watch(spacedRepetitionRepositoryProvider));
});

final watchDueQueueUseCaseProvider = Provider<WatchDueQueueUseCase>((ref) {
  return WatchDueQueueUseCase(ref.watch(spacedRepetitionRepositoryProvider));
});

final getDueCountUseCaseProvider = Provider<GetDueCountUseCase>((ref) {
  return GetDueCountUseCase(ref.watch(spacedRepetitionRepositoryProvider));
});

final recordReviewUseCaseProvider = Provider<RecordReviewUseCase>((ref) {
  return RecordReviewUseCase(ref.watch(spacedRepetitionRepositoryProvider));
});

final watchStatisticsUseCaseProvider = Provider<WatchStatisticsUseCase>((ref) {
  return WatchStatisticsUseCase(ref.watch(spacedRepetitionRepositoryProvider));
});

/// The Review Queue screen's due cards, live-updating as reviews are
/// recorded — watched directly rather than through a ViewModel since
/// there's no additional presentation-only state to layer on top of it
/// (unlike the queue-progression/flip state in
/// `ReviewQueueViewModel`, which reads this provider's snapshots).
final dueQueueProvider = StreamProvider<List<FlashcardSchedule>>((ref) {
  return ref.watch(watchDueQueueUseCaseProvider)();
});

final spacedRepetitionStatisticsProvider = StreamProvider<SpacedRepetitionStatistics>((ref) {
  return ref.watch(watchStatisticsUseCaseProvider)();
});

/// Pulls any schedule changes from another device, then drains this
/// device's pending grades/new-schedules — safe to call opportunistically
/// (app resume, connectivity restore); a no-op for a guest session.
/// Mirrors `notes_providers.dart`'s `triggerNotesSync`.
Future<void> triggerSpacedRepetitionSync(WidgetRef ref) async {
  final userId = ref.read(currentUserProvider).userId;
  if (userId == null) return;

  final worker = ref.read(spacedRepetitionSyncWorkerProvider);
  await worker.pullIncremental(SpacedRepetitionSyncWorker.entityType);
  await worker.drainOutbox(userId);
}
