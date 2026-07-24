import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_mastery/domain/entities/flashcard.dart';
import '../../../ai_mastery/presentation/viewmodels/mastery_content_providers.dart';
import '../../../daily_topic/daily_topic_providers.dart';
import '../../../daily_topic/domain/entities/topic.dart';

typedef ResolvedReviewCard = ({Topic topic, Flashcard flashcard});

/// Only the two ids actually needed to resolve a card's content —
/// deliberately *not* the whole [FlashcardSchedule], whose `dueDate`,
/// `timesReviewed`, etc. change on every review. Keying `.family` on the
/// full schedule meant each graded review minted a brand-new provider
/// instance (its `Equatable` equality includes those mutable fields), so
/// the previous instance's cached AI content was never reused and never
/// disposed of by anything other than app-wide GC pressure.
typedef ReviewCardKey = ({String topicId, String flashcardId});

/// Joins a due schedule's id references back to its actual front/back
/// text — flashcard content lives with `features/ai_mastery` (an
/// AI-generated, cached-by-topic list), not duplicated into the schedule
/// row itself, so the Review Queue screen resolves it here rather than
/// the schedule carrying stale copies of text that could change if the
/// topic's cached flashcards regenerate.
final reviewCardContentProvider = FutureProvider.autoDispose
    .family<ResolvedReviewCard, ReviewCardKey>((ref, key) async {
      final topic = await ref.watch(topicByIdProvider(key.topicId).future);
      final cards = await ref.watch(flashcardsProvider(topic).future);
      final flashcard = cards.firstWhere((c) => c.id == key.flashcardId);
      return (topic: topic, flashcard: flashcard);
    });
