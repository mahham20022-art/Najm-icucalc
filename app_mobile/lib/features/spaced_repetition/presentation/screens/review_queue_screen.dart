import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/accessibility/motion.dart';
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
    final key = (topicId: schedule.topicId, flashcardId: schedule.flashcardId);
    final contentAsync = ref.watch(reviewCardContentProvider(key));
    final isFlipped = ref.watch(reviewQueueViewModelProvider);

    return AsyncValueSection(
      value: contentAsync,
      onRetry: () => ref.invalidate(reviewCardContentProvider(key)),
      builder: (context, content) => Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => ref.read(reviewQueueViewModelProvider.notifier).flip(),
                child: _FlipCard(
                  topicTitle: content.topic.title,
                  front: content.flashcard.front,
                  back: content.flashcard.back,
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
                      onPressed: () {
                        unawaited(HapticFeedback.lightImpact());
                        ref
                            .read(reviewQueueViewModelProvider.notifier)
                            .grade(content.flashcard.id, ReviewGrade.again);
                      },
                      child: const Text('Again'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        unawaited(HapticFeedback.mediumImpact());
                        ref
                            .read(reviewQueueViewModelProvider.notifier)
                            .grade(content.flashcard.id, ReviewGrade.good);
                      },
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

/// A 3D flip between [front] and [back] driven by the parent's
/// [isFlipped] flag — matches `ai_mastery`'s `_FlipCard` in
/// `flashcard_stack_view.dart` (the same interaction living in two
/// features previously looked and animated differently; this one had no
/// animation and no screen-reader label at all).
class _FlipCard extends StatefulWidget {
  const _FlipCard({
    required this.topicTitle,
    required this.front,
    required this.back,
    required this.isFlipped,
  });

  final String topicTitle;
  final String front;
  final String back;
  final bool isFlipped;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.isFlipped ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFlipped == widget.isFlipped) return;

    if (prefersReducedMotion(context)) {
      _controller.value = widget.isFlipped ? 1 : 0;
    } else if (widget.isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.isFlipped ? 'Answer: ${widget.back}' : 'Question: ${widget.front}',
      hint: widget.isFlipped ? 'Double tap to flip back' : 'Double tap to reveal the answer',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final showBack = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      topicTitle: widget.topicTitle,
                      text: widget.back,
                      isBack: true,
                    ),
                  )
                : _CardFace(topicTitle: widget.topicTitle, text: widget.front, isBack: false),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.topicTitle, required this.text, required this.isBack});

  final String topicTitle;
  final String text;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: isBack ? colors.accentFill.withValues(alpha: 0.08) : colors.surfaceElevated,
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
