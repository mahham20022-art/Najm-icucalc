import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/comparison_table.dart';
import '../repositories/mastery_repository.dart';

class GetComparisonTableUseCase {
  const GetComparisonTableUseCase(this._repository);
  final MasteryRepository _repository;

  Future<Result<ComparisonTable>> call(Topic topic) => _repository.getComparisonTable(topic);
}
