import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';

/// Renders an `AsyncValue<T>` from one of `mastery_content_providers.dart`'s
/// `FutureProvider.family`s with a consistent loading/error/data shell,
/// so every one of the six read-only sections looks and behaves the
/// same way rather than each screen re-implementing its own spinner and
/// error card.
class MasteryAsyncSection<T> extends StatelessWidget {
  const MasteryAsyncSection({
    super.key,
    required this.value,
    required this.builder,
    required this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      loading: () => const MasteryThinkingIndicator(),
      error: (error, _) => MasteryErrorView(
        message: error is Failure ? error.message : 'Something went wrong.',
        onRetry: onRetry,
      ),
    );
  }
}

/// The "actively generating" state — deliberately distinct from a
/// content skeleton (`MED100_UI_UX_SPEC.md` §13): AI generation is real
/// work happening right now, not a fetch of already-known data.
class MasteryThinkingIndicator extends StatelessWidget {
  const MasteryThinkingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.accentFill),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Thinking…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class MasteryErrorView extends StatelessWidget {
  const MasteryErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colors.danger, size: 32),
            const SizedBox(height: AppSpacing.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.space4),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
