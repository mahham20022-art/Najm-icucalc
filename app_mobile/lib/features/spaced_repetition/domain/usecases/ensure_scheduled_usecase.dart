import '../../../../core/error/result.dart';
import '../repositories/spaced_repetition_repository.dart';

class EnsureScheduledUseCase {
  const EnsureScheduledUseCase(this._repository);
  final SpacedRepetitionRepository _repository;

  Future<Result<void>> call({required String flashcardId, required String topicId}) =>
      _repository.ensureScheduled(flashcardId: flashcardId, topicId: topicId);
}
