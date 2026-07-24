import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../daily_topic/domain/entities/topic.dart';
import '../../../spaced_repetition/spaced_repetition_providers.dart';
import '../../domain/entities/clinical_algorithm.dart';
import '../../domain/entities/comparison_table.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/mastery_content.dart';
import '../../domain/entities/mastery_section_type.dart';
import '../../domain/entities/mcq.dart';
import '../../domain/entities/reference_entry.dart';
import '../../mastery_providers.dart';

/// The six read-only sections are plain fetch-once-and-display data, so
/// they're modeled as `FutureProvider.family` rather than a hand-rolled
/// sealed UI state per section — `AsyncValue.when(data:, loading:,
/// error:)` already gives the same three states
/// (`ChallengeLoading`/`ChallengeLoaded`/`ChallengeError` elsewhere in
/// this codebase model by hand) natively. A thrown [Failure] lands in
/// `AsyncValue.error`, which the presentation layer reads back out via
/// `error as Failure` — see `MasterySectionBody`.
///
/// Exam Mode and Consultant Mode are genuinely interactive (answering a
/// question, sending a chat message) and so get real `Notifier`
/// ViewModels instead — see `exam_view_model.dart` /
/// `consultant_view_model.dart`.
typedef ProseSectionKey = ({Topic topic, MasterySectionType section});

final proseSectionProvider = FutureProvider.family<MasteryContent, ProseSectionKey>((
  ref,
  key,
) async {
  final result = await ref.watch(getProseSectionUseCaseProvider)(
    topic: key.topic,
    section: key.section,
  );
  return result.when(success: (content) => content, failure: (failure) => throw failure);
});

final comparisonTableProvider = FutureProvider.family<ComparisonTable, Topic>((ref, topic) async {
  final result = await ref.watch(getComparisonTableUseCaseProvider)(topic);
  return result.when(success: (table) => table, failure: (failure) => throw failure);
});

final algorithmProvider = FutureProvider.family<ClinicalAlgorithm, Topic>((ref, topic) async {
  final result = await ref.watch(getAlgorithmUseCaseProvider)(topic);
  return result.when(success: (algorithm) => algorithm, failure: (failure) => throw failure);
});

final mcqsProvider = FutureProvider.family<List<Mcq>, Topic>((ref, topic) async {
  final result = await ref.watch(getMcqsUseCaseProvider)(topic);
  return result.when(success: (mcqs) => mcqs, failure: (failure) => throw failure);
});

final flashcardsProvider = FutureProvider.family<List<Flashcard>, Topic>((ref, topic) async {
  final result = await ref.watch(getFlashcardsUseCaseProvider)(topic);
  return result.when(
    success: (cards) {
      // A flashcard without a review schedule is just static content —
      // `features/spaced_repetition` needs a schedule row per card to
      // ever surface it in the due queue, so this is created as a side
      // effect the moment a topic's flashcards are fetched, rather than
      // needing an app-layer mediator the way Challenge Mode/Reminder
      // Engine do (that coupling exists to keep unrelated features from
      // depending on each other directly; this one is a much tighter,
      // more natural dependency).
      final ensureScheduled = ref.read(ensureScheduledUseCaseProvider);
      for (final card in cards) {
        unawaited(ensureScheduled(flashcardId: card.id, topicId: topic.id));
      }
      return cards;
    },
    failure: (failure) => throw failure,
  );
});

final referencesProvider = FutureProvider.family<List<ReferenceEntry>, Topic>((ref, topic) async {
  final result = await ref.watch(getReferencesUseCaseProvider)(topic);
  return result.when(success: (references) => references, failure: (failure) => throw failure);
});
