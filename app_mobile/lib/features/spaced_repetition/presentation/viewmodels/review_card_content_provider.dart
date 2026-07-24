import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_mastery/domain/entities/flashcard.dart';
import '../../../ai_mastery/presentation/viewmodels/mastery_content_providers.dart';
import '../../../daily_topic/daily_topic_providers.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/flashcard_schedule.dart';

typedef ResolvedReviewCard = ({Topic topic, Flashcard flashcard});

/// Joins a due [FlashcardSchedule] (which only carries id references) back
/// to its actual front/back text — flashcard content lives with
/// `features/ai_mastery` (an AI-generated, cached-by-topic list), not
/// duplicated into the schedule row itself, so the Review Queue screen
/// resolves it here rather than the schedule carrying stale copies of
/// text that could change if the topic's cached flashcards regenerate.
final reviewCardContentProvider = FutureProvider.family<ResolvedReviewCard, FlashcardSchedule>((
  ref,
  schedule,
) async {
  final topic = await ref.watch(topicByIdProvider(schedule.topicId).future);
  final cards = await ref.watch(flashcardsProvider(topic).future);
  final flashcard = cards.firstWhere((c) => c.id == schedule.flashcardId);
  return (topic: topic, flashcard: flashcard);
});
