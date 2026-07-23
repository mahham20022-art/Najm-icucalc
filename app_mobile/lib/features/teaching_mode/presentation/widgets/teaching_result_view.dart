import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/teaching_session.dart';
import 'mastery_score_gauge.dart';

class TeachingResultView extends StatelessWidget {
  const TeachingResultView({
    super.key,
    required this.session,
    required this.onRetry,
    required this.onDone,
  });

  final TeachingSession session;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final evaluation = session.evaluation;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space5),
      children: [
        Center(child: MasteryScoreGauge(score: session.masteryScore)),
        const SizedBox(height: AppSpacing.space6),
        Text('Breakdown', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space3),
        _ScoreBar(label: 'Accuracy', score: evaluation.accuracyScore),
        _ScoreBar(label: 'Clinical Reasoning', score: evaluation.clinicalReasoningScore),
        _ScoreBar(label: 'Completeness', score: evaluation.completenessScore),
        _ScoreBar(label: 'Confidence', score: evaluation.confidenceScore),
        const SizedBox(height: AppSpacing.space5),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.forum_outlined, size: 18, color: colors.accentFill),
                    const SizedBox(width: AppSpacing.space2),
                    Text('Feedback', style: textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(evaluation.feedback, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        if (evaluation.missingConcepts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space4),
          _ConceptList(
            icon: Icons.playlist_add_check_circle_outlined,
            iconColor: colors.warning,
            title: 'Missing Concepts',
            items: evaluation.missingConcepts,
          ),
        ],
        if (evaluation.hallucinations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space4),
          _ConceptList(
            icon: Icons.report_gmailerrorred_outlined,
            iconColor: colors.danger,
            title: 'Unsupported Claims',
            items: evaluation.hallucinations,
          ),
        ],
        const SizedBox(height: AppSpacing.space6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: FilledButton(onPressed: onDone, child: const Text('Done')),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final color = score >= 80 ? colors.success : (score >= 50 ? colors.warning : colors.danger);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: textTheme.bodyMedium),
              Text('$score', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControlSm),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: colors.separator,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptList extends StatelessWidget {
  const _ConceptList({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: AppSpacing.space2),
                Text(title, style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space1),
                child: Text('• $item', style: textTheme.bodyMedium),
              ),
          ],
        ),
      ),
    );
  }
}
