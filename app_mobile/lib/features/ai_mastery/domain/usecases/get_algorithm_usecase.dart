import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/clinical_algorithm.dart';
import '../repositories/mastery_repository.dart';

class GetAlgorithmUseCase {
  const GetAlgorithmUseCase(this._repository);
  final MasteryRepository _repository;

  Future<Result<ClinicalAlgorithm>> call(Topic topic) => _repository.getAlgorithm(topic);
}
