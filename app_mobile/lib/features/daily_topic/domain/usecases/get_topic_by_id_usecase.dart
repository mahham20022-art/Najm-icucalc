import '../../../../core/error/result.dart';
import '../entities/topic.dart';
import '../repositories/topic_repository.dart';

class GetTopicByIdUseCase {
  const GetTopicByIdUseCase(this._repository);

  final TopicRepository _repository;

  Future<Result<Topic>> call(String topicId) => _repository.getTopicById(topicId);
}
