import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import '../../core/session/current_user.dart';
import 'data/datasources/flashcard_schedules_local_datasource.dart';
import 'data/repositories/spaced_repetition_repository_impl.dart';
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

final spacedRepetitionRepositoryProvider = Provider<SpacedRepetitionRepository>((ref) {
  return SpacedRepetitionRepositoryImpl(
    localDataSource: ref.watch(flashcardSchedulesLocalDataSourceProvider),
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
