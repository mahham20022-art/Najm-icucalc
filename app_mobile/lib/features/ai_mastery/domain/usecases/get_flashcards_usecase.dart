import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/flashcard.dart';
import '../repositories/mastery_repository.dart';

class GetFlashcardsUseCase {
  const GetFlashcardsUseCase(this._repository);
  final MasteryRepository _repository;

  Future<Result<List<Flashcard>>> call(Topic topic) => _repository.getFlashcards(topic);
}
