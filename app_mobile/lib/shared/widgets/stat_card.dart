import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// A small "value + label" tile used by every stats screen in the app —
/// previously reimplemented near-identically as a private widget in both
/// `review_queue_screen.dart` (`_StatChip`) and
/// `challenge_statistics_screen.dart` (`_StatCard`).
///
/// [icon] is optional so both the icon-less compact chip and the
/// icon-led card variant share one implementation; [asCard] switches
/// between a bordered-box chip (Spaced Repetition's inline row of three)
/// and a full `Card` (Challenge Mode's 2-column grid), matching the two
/// call sites' existing visual designs rather than forcing one look on
/// both. `admin_dashboard`'s own `_StatCard` in `analytics_screen.dart`
/// is a separate Flutter project with no shared package between the two
/// apps, so it stays local there — there's nothing to dedupe within that
/// project since it has only the one call site.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.asCard = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final bool asCard;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tint = color ?? colors.accentFill;

    final content = Column(
      crossAxisAlignment: asCard ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, color: tint), const SizedBox(height: AppSpacing.space2)],
        Text(
          value,
          style: (asCard ? textTheme.headlineSmall : textTheme.titleLarge)?.copyWith(
            color: icon == null ? tint : null,
          ),
        ),
        Text(
          label,
          style: (asCard ? textTheme.bodySmall : textTheme.labelSmall)?.copyWith(
            color: colors.labelSecondary,
          ),
          textAlign: asCard ? TextAlign.start : TextAlign.center,
        ),
      ],
    );

    if (asCard) {
      return Card(
        child: Padding(padding: const EdgeInsets.all(AppSpacing.space4), child: content),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space3,
        horizontal: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusControlSm),
        border: Border.all(color: colors.separator),
      ),
      child: content,
    );
  }
}
