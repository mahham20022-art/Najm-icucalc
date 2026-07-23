import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/explanation_mode.dart';
import '../viewmodels/teaching_history_provider.dart';

/// Teaching Mode's entry step — "explain it back, your way." Shows the
/// topic's best past Mastery Score, if any, as the visible proof that
/// past attempts were actually stored.
class ModeSelectionView extends ConsumerWidget {
  const ModeSelectionView({super.key, required this.topicId, required this.onSelect});

  final String topicId;
  final ValueChanged<ExplanationMode> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final history = ref.watch(teachingSessionsForTopicProvider(topicId));

    final bestScore = history.maybeWhen(
      data: (sessions) => sessions.isEmpty
          ? null
          : sessions.map((s) => s.masteryScore).reduce((a, b) => a > b ? a : b),
      orElse: () => null,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.record_voice_over_outlined, size: 44, color: colors.accentFill),
            const SizedBox(height: AppSpacing.space4),
            Text('Teach It Back', style: textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Explain this topic in your own words — the Feynman technique. '
              "We'll evaluate your explanation and score your mastery.",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
            ),
            if (bestScore != null) ...[
              const SizedBox(height: AppSpacing.space4),
              Chip(
                avatar: Icon(Icons.emoji_events_outlined, size: 18, color: colors.warning),
                label: Text('Best score so far: $bestScore'),
              ),
            ],
            const SizedBox(height: AppSpacing.space6),
            _ModeCard(
              icon: Icons.mic_outlined,
              title: 'Voice Explanation',
              subtitle: 'Speak your explanation out loud',
              onTap: () => onSelect(ExplanationMode.voice),
            ),
            const SizedBox(height: AppSpacing.space3),
            _ModeCard(
              icon: Icons.edit_outlined,
              title: 'Written Explanation',
              subtitle: 'Type your explanation',
              onTap: () => onSelect(ExplanationMode.written),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.accentFill.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.accentFill),
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(color: colors.labelSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.labelTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
