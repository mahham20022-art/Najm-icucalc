import '../models/topic_dto.dart';

/// Remote (Firestore/CDN-backed) data source contract. The foundation-
/// stage implementation below returns fixed sample data instead of
/// calling Firestore or the CDN — wiring up real content delivery
/// (including the free/premium split from `MED100_DATABASE_DESIGN.md`
/// §2) is feature work, not foundation work.
abstract interface class TopicRemoteDataSource {
  Future<TopicDto> fetchTodaysTopic();
  Future<TopicDto> fetchTopicById(String topicId);
}

class SampleTopicRemoteDataSource implements TopicRemoteDataSource {
  static const _sample = TopicDto(
    id: 'sample-topic-001',
    title: 'Recognizing Early Sepsis (Sample Content)',
    specialtyId: 'critical-care',
    estimatedMinutes: 4,
    isFree: true,
    version: 1,
  );

  @override
  Future<TopicDto> fetchTodaysTopic() async => _sample;

  @override
  Future<TopicDto> fetchTopicById(String topicId) async => _sample;
}
