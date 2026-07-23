import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/mcq.dart';
import '../repositories/mastery_repository.dart';

class GetMcqsUseCase {
  const GetMcqsUseCase(this._repository);
  final MasteryRepository _repository;

  Future<Result<List<Mcq>>> call(Topic topic) => _repository.getMcqs(topic);
}
