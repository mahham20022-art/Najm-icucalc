import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import '../../core/ai/ai_providers.dart';
import '../../core/session/current_user.dart';
import '../../core/sync/sync_providers.dart';
import 'data/datasources/speech_recognition_datasource.dart';
import 'data/datasources/teaching_sessions_local_datasource.dart';
import 'data/datasources/teaching_sessions_remote_datasource.dart';
import 'data/repositories/teaching_repository_impl.dart';
import 'data/teaching_sync_worker.dart';
import 'domain/repositories/teaching_repository.dart';
import 'domain/usecases/submit_explanation_usecase.dart';
import 'domain/usecases/watch_sessions_for_topic_usecase.dart';

/// The DI graph for Teaching Mode, following the same
/// dataSourceProvider → repositoryProvider → useCaseProvider chain as
/// every other feature.
final speechRecognitionDataSourceProvider = Provider<SpeechRecognitionDataSource>((ref) {
  return SpeechRecognitionDataSource();
});

final teachingSessionsLocalDataSourceProvider = Provider<TeachingSessionsLocalDataSource>((ref) {
  return TeachingSessionsLocalDataSource(ref.watch(appDatabaseProvider));
});

final teachingSessionsRemoteDataSourceProvider = Provider<TeachingSessionsRemoteDataSource>((ref) {
  return TeachingSessionsRemoteDataSource();
});

final teachingSyncWorkerProvider = Provider<TeachingSyncWorker>((ref) {
  return TeachingSyncWorker(
    localDataSource: ref.watch(teachingSessionsLocalDataSourceProvider),
    remoteDataSource: ref.watch(teachingSessionsRemoteDataSourceProvider),
    outbox: ref.watch(outboxLocalDataSourceProvider),
    syncState: ref.watch(syncStateLocalDataSourceProvider),
    currentUser: ref.watch(currentUserProvider),
  );
});

final teachingRepositoryProvider = Provider<TeachingRepository>((ref) {
  return TeachingRepositoryImpl(
    aiEngine: ref.watch(aiEngineRepositoryProvider),
    localDataSource: ref.watch(teachingSessionsLocalDataSourceProvider),
    outbox: ref.watch(outboxLocalDataSourceProvider),
    currentUser: ref.watch(currentUserProvider),
  );
});

final submitExplanationUseCaseProvider = Provider<SubmitExplanationUseCase>((ref) {
  return SubmitExplanationUseCase(ref.watch(teachingRepositoryProvider));
});

final watchSessionsForTopicUseCaseProvider = Provider<WatchSessionsForTopicUseCase>((ref) {
  return WatchSessionsForTopicUseCase(ref.watch(teachingRepositoryProvider));
});

/// Pulls any sessions created on another device, then drains this
/// device's pending submissions — safe to call opportunistically (app
/// resume, connectivity restore); a no-op for a guest session. Mirrors
/// `notes_providers.dart`'s `triggerNotesSync`.
Future<void> triggerTeachingSync(WidgetRef ref) async {
  final userId = ref.read(currentUserProvider).userId;
  if (userId == null) return;

  final worker = ref.read(teachingSyncWorkerProvider);
  await worker.pullIncremental(TeachingSyncWorker.entityType);
  await worker.drainOutbox(userId);
}
