import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/exam_session.dart';
import '../viewmodels/exam_view_model.dart';
import 'mastery_async_section.dart';

/// A timed-feeling, sequential test flow over the same generated
/// question bank the MCQs section practices with — one question at a
/// time, no feedback until the final score, per `ExamSession`'s doc
/// comment.
class ExamModeView extends ConsumerWidget {
  const ExamModeView({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examViewModelProvider(topic));
    final viewModel = ref.read(examViewModelProvider(topic).notifier);

    return switch (state) {
      ExamNotStarted() => _StartCard(onStart: viewModel.start),
      ExamLoading() => const MasteryThinkingIndicator(),
      ExamLoadFailed(:final failure) => MasteryErrorView(
        message: failure.message,
        onRetry: viewModel.start,
      ),
      ExamInProgress(:final session) =>
        session.isComplete
            ? _ResultsCard(session: session, onRestart: viewModel.restart)
            : _QuestionCard(session: session, onAnswer: viewModel.answer),
    };
  }
}

class _StartCard extends StatelessWidget {
  const _StartCard({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 40, color: colors.accentFill),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Test yourself with a short exam on this topic — one question at a '
              'time, with your score at the end.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.space5),
            FilledButton(onPressed: onStart, child: const Text('Start Exam')),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.session, required this.onAnswer});

  final ExamSession session;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final question = session.currentQuestion!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControlSm),
            child: LinearProgressIndicator(
              value: session.currentIndex / session.mcqs.length,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Question ${session.currentIndex + 1} of ${session.mcqs.length}',
            style: textTheme.labelMedium?.copyWith(color: colors.labelSecondary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(question.question, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.space4),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < question.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(AppSpacing.space3),
                      ),
                      onPressed: () => onAnswer(i),
                      child: Text(question.options[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.session, required this.onRestart});

  final ExamSession session;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 40, color: colors.success),
            const SizedBox(height: AppSpacing.space4),
            Text('${session.correctCount} / ${session.mcqs.length}', style: textTheme.displayLarge),
            const SizedBox(height: AppSpacing.space2),
            Text(
              '${(session.scoreFraction * 100).round()}% correct',
              style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
            ),
            const SizedBox(height: AppSpacing.space5),
            FilledButton(onPressed: onRestart, child: const Text('Retake Exam')),
          ],
        ),
      ),
    );
  }
}
