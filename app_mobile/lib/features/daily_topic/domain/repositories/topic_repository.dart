import '../../../../core/error/result.dart';
import '../entities/topic.dart';

/// Domain-owned interface — the data layer implements this
/// (`TopicRepositoryImpl`), and it is the *only* thing this feature's
/// presentation layer is allowed to depend on, per the Repository
/// Pattern as specified in `MED100_ARCHITECTURE.md` §5. Nothing above
/// this line may import Firestore, Drift, or Dio types.
abstract interface class TopicRepository {
  /// Resolves "today's" topic for the signed-in user's enrolled path.
  Future<Result<Topic>> getTodaysTopic();

  Future<Result<Topic>> getTopicById(String topicId);
}
