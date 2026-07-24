import '../../../../core/error/result.dart';
import '../entities/flashcard_schedule.dart';
import '../entities/review_grade.dart';
import '../entities/spaced_repetition_statistics.dart';

abstract class SpacedRepetitionRepository {
  /// Creates a `newCard`-stage, immediately-due schedule row for
  /// `flashcardId` if one doesn't already exist for this user — a no-op
  /// otherwise. Called as a side effect whenever a topic's flashcards are
  /// fetched, since a flashcard without a review schedule is just static
  /// content.
  Future<Result<void>> ensureScheduled({required String flashcardId, required String topicId});

  /// All non-mastered schedules currently due (`dueDate <= now`),
  /// ordered oldest-due-first, live-updating as reviews are recorded.
  Stream<List<FlashcardSchedule>> watchDueQueue();

  /// How many cards are currently due — the reminder engine's due-cards
  /// check reads this without needing the full queue.
  Future<int> getDueCount();

  /// Applies [grade] to the schedule for [flashcardId], advancing it to
  /// the next stage (`good`) or resetting it to `newCard` (`again`), and
  /// recomputing its due date.
  Future<Result<void>> recordReview({required String flashcardId, required ReviewGrade grade});

  Stream<SpacedRepetitionStatistics> watchStatistics();
}
