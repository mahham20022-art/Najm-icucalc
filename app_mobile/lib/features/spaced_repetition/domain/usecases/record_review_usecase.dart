import '../entities/review_grade.dart';
import '../repositories/spaced_repetition_repository.dart';

class RecordReviewUseCase {
  const RecordReviewUseCase(this._repository);
  final SpacedRepetitionRepository _repository;

  Future<void> call({required String flashcardId, required ReviewGrade grade}) =>
      _repository.recordReview(flashcardId: flashcardId, grade: grade);
}
