// ignore_for_file: prefer_initializing_formals — the external constructor
// parameter names (`local`/`remote`) are deliberately public-friendly
// while the backing fields stay private, which an initializing formal
// can't express.
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/topic_repository.dart';
import '../datasources/topic_local_datasource.dart';
import '../datasources/topic_remote_datasource.dart';
import '../models/topic_dto.dart';

/// Composes the local and remote data sources behind the offline-first
/// pattern from `MED100_ARCHITECTURE.md` §9: serve from cache
/// immediately if present, otherwise fall back to remote and populate
/// the cache for next time. This is the only class in the feature that
/// knows both data sources exist — domain and presentation only ever see
/// [TopicRepository].
class TopicRepositoryImpl implements TopicRepository {
  const TopicRepositoryImpl({
    required TopicLocalDataSource local,
    required TopicRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  final TopicLocalDataSource _local;
  final TopicRemoteDataSource _remote;

  @override
  Future<Result<Topic>> getTodaysTopic() =>
      _resolve(cacheKey: 'todays-topic', fetchRemote: _remote.fetchTodaysTopic);

  @override
  Future<Result<Topic>> getTopicById(String topicId) =>
      _resolve(cacheKey: topicId, fetchRemote: () => _remote.fetchTopicById(topicId));

  Future<Result<Topic>> _resolve({
    required String cacheKey,
    required Future<TopicDto> Function() fetchRemote,
  }) async {
    final cached = await _local.getCachedTopic(cacheKey);
    if (cached != null) return Result.success(cached.toEntity());

    try {
      final dto = await fetchRemote();
      await _local.cacheTopic(dto);
      return Result.success(dto.toEntity());
    } catch (_) {
      return const Result.failure(NetworkFailure());
    }
  }
}
