import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/widgets/async_value_section.dart';
import '../../domain/entities/flashcard_schedule.dart';
import '../../domain/entities/review_grade.dart';
import '../../domain/entities/spaced_repetition_statistics.dart';
import '../../spaced_repetition_providers.dart';
import '../viewmodels/review_card_content_provider.dart';
import '../viewmodels/review_queue_view_model.dart';

/// Replaces the `/flashcards` placeholder — the spaced-repetition Review
/// Queue: today's due cards (7/30/90-day ladder), a flip-to-reveal card,
/// Again/Good grading, and a statistics header.
class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(dueQueueProvider);
    final statsAsync = ref.watch(spacedRepetitionStatisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Queue')),
      body: Column(
        children: [
          if (statsAsync.value != null) _StatisticsHeader(stats: statsAsync.value!),
          Expanded(
            child: queueAsync.when(
              data: (queue) => queue.isEmpty
                  ? const _EmptyQueueView()
                  : _ReviewCardSection(schedule: queue.first),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text(error is Failure ? error.message : 'Something went wrong.')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCardSection extends ConsumerWidget {
  const _ReviewCardSection({required this.schedule});
  final FlashcardSchedule schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(reviewCardContentProvider(schedule));
    final isFlipped = ref.watch(reviewQueueViewModelProvider);

    return AsyncValueSection(
      value: contentAsync,
      onRetry: () => ref.invalidate(reviewCardContentProvider(schedule)),
      builder: (context, content) => Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => ref.read(reviewQueueViewModelProvider.notifier).flip(),
                child: _FlipCard(
                  topicTitle: content.topic.title,
                  text: isFlipped ? content.flashcard.back : content.flashcard.front,
                  isFlipped: isFlipped,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            if (isFlipped)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(reviewQueueViewModelProvider.notifier)
                          .grade(content.flashcard.id, ReviewGrade.again),
                      child: const Text('Again'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => ref
                          .read(reviewQueueViewModelProvider.notifier)
                          .grade(content.flashcard.id, ReviewGrade.good),
                      child: const Text('Good'),
                    ),
                  ),
                ],
              )
            else
              Text(
                'Tap the card to reveal the answer',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.of(context).labelSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.topicTitle, required this.text, required this.isFlipped});

  final String topicTitle;
  final String text;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: isFlipped ? colors.accentFill.withValues(alpha: 0.08) : colors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.separator),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topicTitle, style: textTheme.labelMedium?.copyWith(color: colors.labelTertiary)),
          const SizedBox(height: AppSpacing.space4),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(text, style: textTheme.headlineSmall, textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyQueueView extends StatelessWidget {
  const _EmptyQueueView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: colors.success),
            const SizedBox(height: AppSpacing.space4),
            Text('All caught up', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'No flashcards are due for review right now.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsHeader extends StatelessWidget {
  const _StatisticsHeader({required this.stats});
  final SpacedRepetitionStatistics stats;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final retention = stats.retentionRate;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space5,
        AppSpacing.space4,
        AppSpacing.space5,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              label: 'Due today',
              value: '${stats.dueToday}',
              color: colors.accentFill,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: _StatChip(
              label: 'Mastered',
              value: '${stats.masteredCount}',
              color: colors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: _StatChip(
              label: 'Retention',
              value: retention == null ? '—' : '${(retention * 100).round()}%',
              color: colors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space3,
        horizontal: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusControlSm),
        border: Border.all(color: colors.separator),
      ),
      child: Column(
        children: [
          Text(value, style: textTheme.titleLarge?.copyWith(color: color)),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: colors.labelSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
