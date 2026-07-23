import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/topic_local_datasource.dart';
import 'data/datasources/topic_remote_datasource.dart';
import 'data/repositories/topic_repository_impl.dart';
import 'domain/repositories/topic_repository.dart';
import 'domain/usecases/get_todays_topic_usecase.dart';

/// The DI graph for this feature, following
/// `MED100_ARCHITECTURE.md` §6 exactly:
/// dataSourceProvider → repositoryProvider (the only providers allowed to
/// reference Firebase/Drift types) → useCaseProvider → viewModelProvider.
///
/// Every provider here is overridable in tests — none of them reach for
/// a global singleton.
final topicLocalDataSourceProvider = Provider<TopicLocalDataSource>((ref) {
  return InMemoryTopicLocalDataSource();
});

final topicRemoteDataSourceProvider = Provider<TopicRemoteDataSource>((ref) {
  return SampleTopicRemoteDataSource();
});

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepositoryImpl(
    local: ref.watch(topicLocalDataSourceProvider),
    remote: ref.watch(topicRemoteDataSourceProvider),
  );
});

final getTodaysTopicUseCaseProvider = Provider<GetTodaysTopicUseCase>((ref) {
  return GetTodaysTopicUseCase(ref.watch(topicRepositoryProvider));
});
