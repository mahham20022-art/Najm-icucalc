import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/error/failure.dart';

/// Renders an `AsyncValue<T>` (from a `FutureProvider`/`StreamProvider`
/// wrapping a use case that returns `Result<T>`, with the `Failure`
/// thrown into `AsyncValue.error` on the failure branch) with a
/// consistent loading/error/data shell. Originally AI Mastery Mode's,
/// promoted to `shared/` once Teaching Mode needed the exact same
/// "resolve a Topic from a route param" loading/error pattern —
/// extracting on the second consumer, not speculatively before one
/// existed.
class AsyncValueSection<T> extends StatelessWidget {
  const AsyncValueSection({
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
      loading: () => const ThinkingIndicator(),
      error: (error, _) => InlineErrorView(
        message: error is Failure ? error.message : 'Something went wrong.',
        onRetry: onRetry,
      ),
    );
  }
}

/// The "actively generating" state — deliberately distinct from a
/// content skeleton (`MED100_UI_UX_SPEC.md` §13): AI generation is real
/// work happening right now, not a fetch of already-known data.
class ThinkingIndicator extends StatelessWidget {
  const ThinkingIndicator({super.key});

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

class InlineErrorView extends StatelessWidget {
  const InlineErrorView({super.key, required this.message, required this.onRetry});

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
