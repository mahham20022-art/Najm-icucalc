import '../../../../core/error/result.dart';
import '../entities/topic.dart';
import '../repositories/topic_repository.dart';

/// One class per user intent, per `MED100_ARCHITECTURE.md` §3 — a use
/// case is the unit that could be tested in complete isolation from
/// Flutter, Firebase, and Drift, given only a fake [TopicRepository].
class GetTodaysTopicUseCase {
  const GetTodaysTopicUseCase(this._repository);

  final TopicRepository _repository;

  Future<Result<Topic>> call() => _repository.getTodaysTopic();
}
