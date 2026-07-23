import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/explanation_mode.dart';
import '../entities/teaching_session.dart';
import '../repositories/teaching_repository.dart';

class SubmitExplanationUseCase {
  const SubmitExplanationUseCase(this._repository);
  final TeachingRepository _repository;

  Future<Result<TeachingSession>> call({
    required Topic topic,
    required ExplanationMode mode,
    required String explanationText,
  }) => _repository.submitExplanation(topic: topic, mode: mode, explanationText: explanationText);
}
