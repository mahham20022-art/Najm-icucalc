import '../models/topic_dto.dart';

/// Local (Drift-backed) data source contract. The foundation-stage
/// implementation below is an in-memory stub — it demonstrates the
/// interface shape and the repository's offline-first read pattern
/// (`MED100_ARCHITECTURE.md` §5, §9) without a real `topics` Drift table,
/// which is feature work for when `daily_topic` is actually built out.
///
/// Every method takes an explicit `userId` and folds it into the cache
/// key — "today's topic" depends on the signed-in user's enrolled path,
/// so caching it under a single shared key would leak one user's content
/// into another's session on a shared/re-logged-in device, exactly the
/// failure mode `MED100_DATABASE_DESIGN.md` §0a exists to prevent. A real
/// Drift-backed implementation must key its table rows the same way.
abstract interface class TopicLocalDataSource {
  Future<TopicDto?> getCachedTopic(String userId, String topicId);
  Future<void> cacheTopic(String userId, TopicDto topic);
}

class InMemoryTopicLocalDataSource implements TopicLocalDataSource {
  final Map<String, TopicDto> _cache = {};

  String _key(String userId, String topicId) => '$userId:$topicId';

  @override
  Future<TopicDto?> getCachedTopic(String userId, String topicId) async =>
      _cache[_key(userId, topicId)];

  @override
  Future<void> cacheTopic(String userId, TopicDto topic) async =>
      _cache[_key(userId, topic.id)] = topic;
}
