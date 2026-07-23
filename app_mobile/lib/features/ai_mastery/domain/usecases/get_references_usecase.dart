import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/reference_entry.dart';
import '../repositories/mastery_repository.dart';

class GetReferencesUseCase {
  const GetReferencesUseCase(this._repository);
  final MasteryRepository _repository;

  Future<Result<List<ReferenceEntry>>> call(Topic topic) => _repository.getReferences(topic);
}
