import '../entities/teaching_session.dart';
import '../repositories/teaching_repository.dart';

class WatchSessionsForTopicUseCase {
  const WatchSessionsForTopicUseCase(this._repository);
  final TeachingRepository _repository;

  Stream<List<TeachingSession>> call(String topicId) => _repository.watchSessionsForTopic(topicId);
}
