import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/current_user.dart';
import 'data/datasources/topic_local_datasource.dart';
import 'data/datasources/topic_remote_datasource.dart';
import 'data/repositories/topic_repository_impl.dart';
import 'domain/entities/topic.dart';
import 'domain/repositories/topic_repository.dart';
import 'domain/usecases/get_todays_topic_usecase.dart';
import 'domain/usecases/get_topic_by_id_usecase.dart';

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
    currentUser: ref.watch(currentUserProvider),
  );
});

final getTodaysTopicUseCaseProvider = Provider<GetTodaysTopicUseCase>((ref) {
  return GetTodaysTopicUseCase(ref.watch(topicRepositoryProvider));
});

final getTopicByIdUseCaseProvider = Provider<GetTopicByIdUseCase>((ref) {
  return GetTopicByIdUseCase(ref.watch(topicRepositoryProvider));
});

/// Resolves a route's `:topicId` param into a [Topic] — used by
/// `features/ai_mastery`'s routed screen, which needs the full entity
/// (title/body) a path parameter alone can't provide.
final topicByIdProvider = FutureProvider.family<Topic, String>((ref, topicId) async {
  final result = await ref.watch(getTopicByIdUseCaseProvider)(topicId);
  return result.when(success: (topic) => topic, failure: (failure) => throw failure);
});
