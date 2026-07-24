import '../entities/flashcard_schedule.dart';
import '../repositories/spaced_repetition_repository.dart';

class WatchDueQueueUseCase {
  const WatchDueQueueUseCase(this._repository);
  final SpacedRepetitionRepository _repository;

  Stream<List<FlashcardSchedule>> call() => _repository.watchDueQueue();
}
