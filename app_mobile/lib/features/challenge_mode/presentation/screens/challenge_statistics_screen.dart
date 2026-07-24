import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../domain/challenge_content.dart';
import '../viewmodels/challenge_view_model.dart';

/// Replaces `/progress/statistics`'s placeholder — completed/skipped
/// counts, current streak, and overall completion, all re-derived from
/// `ChallengeState` rather than tracked as separately-maintained fields.
class ChallengeStatisticsScreen extends ConsumerWidget {
  const ChallengeStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uiState = ref.watch(challengeViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.challengeStatisticsTitle)),
      body: switch (uiState) {
        ChallengeLoading() => const Center(child: CircularProgressIndicator()),
        ChallengeError(:final failure) => Center(child: Text(failure.message)),
        ChallengeLoaded(:final state) => ListView(
          padding: const EdgeInsets.all(AppSpacing.space5),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.space4,
              crossAxisSpacing: AppSpacing.space4,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  icon: Icons.check_circle_outline,
                  label: l10n.challengeCompletedLabel,
                  value: '${state.completedDays.length}',
                  color: AppColors.of(context).success,
                  asCard: true,
                ),
                StatCard(
                  icon: Icons.skip_next_outlined,
                  label: l10n.challengeSkippedLabel,
                  value: '${state.skippedDays.length}',
                  color: AppColors.of(context).warning,
                  asCard: true,
                ),
                StatCard(
                  icon: Icons.local_fire_department_outlined,
                  label: l10n.challengeCurrentStreak,
                  value: l10n.challengeStreakDays(state.currentStreak),
                  color: AppColors.of(context).accentFill,
                  asCard: true,
                ),
                StatCard(
                  icon: Icons.donut_large_outlined,
                  label: l10n.challengeCompletionRate,
                  value: '${(state.progressFraction * 100).round()}%',
                  color: AppColors.of(context).accentFill,
                  asCard: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space5),
            LinearProgressIndicator(
              value: state.progressFraction,
              minHeight: 8,
              borderRadius: BorderRadius.circular(AppSpacing.radiusControlSm),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              '${state.daysActioned} / ${ChallengeContent.totalDays}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      },
    );
  }
}
