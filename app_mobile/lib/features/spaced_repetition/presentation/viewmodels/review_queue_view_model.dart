import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/review_grade.dart';
import '../../spaced_repetition_providers.dart';

/// Whether the currently-shown card is front-up or flipped to its back —
/// the only presentation-only state the Review Queue screen needs.
/// Which card is "current" is always the due queue's first item
/// (`dueQueueProvider`, a live Drift stream): grading a card removes it
/// from the due set (or pushes its due date forward), so the next due
/// card naturally becomes first without this needing to track an index.
class ReviewQueueViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  void flip() => state = !state;

  Future<void> grade(String flashcardId, ReviewGrade grade) async {
    await ref.read(recordReviewUseCaseProvider)(flashcardId: flashcardId, grade: grade);
    state = false;
  }
}

final reviewQueueViewModelProvider = NotifierProvider<ReviewQueueViewModel, bool>(
  ReviewQueueViewModel.new,
);
