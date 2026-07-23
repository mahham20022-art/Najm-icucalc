import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/mastery_content.dart';
import '../entities/mastery_section_type.dart';
import '../repositories/mastery_repository.dart';

class GetProseSectionUseCase {
  const GetProseSectionUseCase(this._repository);
  final MasteryRepository _repository;

  Future<Result<MasteryContent>> call({
    required Topic topic,
    required MasterySectionType section,
  }) => _repository.getProseSection(topic: topic, section: section);
}
