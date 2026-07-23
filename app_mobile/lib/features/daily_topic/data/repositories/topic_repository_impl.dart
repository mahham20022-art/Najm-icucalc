// ignore_for_file: prefer_initializing_formals — the external constructor
// parameter names (`local`/`remote`/`currentUser`) are deliberately
// public-friendly while the backing fields stay private, which an
// initializing formal can't express.
import 'dart:async' show unawaited;

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/session/current_user.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/topic_repository.dart';
import '../datasources/topic_local_datasource.dart';
import '../datasources/topic_remote_datasource.dart';
import '../models/topic_dto.dart';

/// Composes the local and remote data sources behind the offline-first
/// pattern from `MED100_ARCHITECTURE.md` §9: serve from cache
/// immediately if present — while still kicking off a background remote
/// refresh so the cache doesn't go stale forever once populated once —
/// otherwise fall back to remote and populate the cache for next time.
/// This is the only class in the feature that knows both data sources
/// exist — domain and presentation only ever see [TopicRepository].
class TopicRepositoryImpl implements TopicRepository {
  const TopicRepositoryImpl({
    required TopicLocalDataSource local,
    required TopicRemoteDataSource remote,
    required CurrentUser currentUser,
  }) : _local = local,
       _remote = remote,
       _currentUser = currentUser;

  final TopicLocalDataSource _local;
  final TopicRemoteDataSource _remote;
  final CurrentUser _currentUser;

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
    final userId = _currentUser.userId ?? guestScopeId;
    final cached = await _local.getCachedTopic(userId, cacheKey);

    if (cached != null) {
      // Don't await this: the whole point of serving from cache first is
      // an instant, non-blocking read. Failures here are silently
      // dropped — a stale cache read is still a successful result for
      // this call; the refresh either lands in time for next read or it
      // doesn't, per the offline-first contract in
      // `MED100_ARCHITECTURE.md` §9.
      unawaited(_refreshInBackground(userId, fetchRemote));
      return Result.success(cached.toEntity());
    }

    try {
      final dto = await fetchRemote();
      await _local.cacheTopic(userId, dto);
      return Result.success(dto.toEntity());
    } catch (_) {
      return const Result.failure(NetworkFailure());
    }
  }

  Future<void> _refreshInBackground(String userId, Future<TopicDto> Function() fetchRemote) async {
    try {
      final dto = await fetchRemote();
      await _local.cacheTopic(userId, dto);
    } catch (_) {
      // Opportunistic refresh — the caller already has a valid (if
      // possibly stale) result, so a failure here has nothing to report
      // to. The next `getTodaysTopic()`/`getTopicById()` call will retry.
    }
  }
}
