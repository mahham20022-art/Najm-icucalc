import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import '../../core/ai/ai_providers.dart';
import '../../core/session/current_user.dart';
import 'data/datasources/speech_recognition_datasource.dart';
import 'data/datasources/teaching_sessions_local_datasource.dart';
import 'data/repositories/teaching_repository_impl.dart';
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

final teachingRepositoryProvider = Provider<TeachingRepository>((ref) {
  return TeachingRepositoryImpl(
    aiEngine: ref.watch(aiEngineRepositoryProvider),
    localDataSource: ref.watch(teachingSessionsLocalDataSourceProvider),
    currentUser: ref.watch(currentUserProvider),
  );
});

final submitExplanationUseCaseProvider = Provider<SubmitExplanationUseCase>((ref) {
  return SubmitExplanationUseCase(ref.watch(teachingRepositoryProvider));
});

final watchSessionsForTopicUseCaseProvider = Provider<WatchSessionsForTopicUseCase>((ref) {
  return WatchSessionsForTopicUseCase(ref.watch(teachingRepositoryProvider));
});
