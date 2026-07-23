import '../models/topic_dto.dart';

/// Local (Drift-backed) data source contract. The foundation-stage
/// implementation below is an in-memory stub — it demonstrates the
/// interface shape and the repository's offline-first read pattern
/// (`MED100_ARCHITECTURE.md` §5, §9) without a real `topics` Drift table,
/// which is feature work for when `daily_topic` is actually built out.
abstract interface class TopicLocalDataSource {
  Future<TopicDto?> getCachedTopic(String topicId);
  Future<void> cacheTopic(TopicDto topic);
}

class InMemoryTopicLocalDataSource implements TopicLocalDataSource {
  final Map<String, TopicDto> _cache = {};

  @override
  Future<TopicDto?> getCachedTopic(String topicId) async => _cache[topicId];

  @override
  Future<void> cacheTopic(TopicDto topic) async => _cache[topic.id] = topic;
}
