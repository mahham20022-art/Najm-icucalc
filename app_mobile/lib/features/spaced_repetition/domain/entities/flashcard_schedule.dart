import 'package:equatable/equatable.dart';

import 'repetition_stage.dart';

/// One flashcard's persisted spaced-repetition state — the domain-layer
/// counterpart of `core/database/app_database.dart`'s
/// `FlashcardSchedules` table (`FlashcardScheduleRow`).
class FlashcardSchedule extends Equatable {
  const FlashcardSchedule({
    required this.flashcardId,
    required this.topicId,
    required this.stage,
    required this.dueDate,
    required this.lastReviewedAt,
    required this.timesReviewed,
    required this.timesLapsed,
    required this.createdAt,
  });

  final String flashcardId;
  final String topicId;
  final RepetitionStage stage;
  final DateTime dueDate;
  final DateTime? lastReviewedAt;
  final int timesReviewed;
  final int timesLapsed;
  final DateTime createdAt;

  bool get isMastered => stage == RepetitionStage.mastered;

  bool isDue(DateTime asOf) => !isMastered && !dueDate.isAfter(asOf);

  @override
  List<Object?> get props => [
    flashcardId,
    topicId,
    stage,
    dueDate,
    lastReviewedAt,
    timesReviewed,
    timesLapsed,
    createdAt,
  ];
}
