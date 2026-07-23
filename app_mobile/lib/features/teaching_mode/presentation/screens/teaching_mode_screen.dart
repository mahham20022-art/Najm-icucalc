import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../viewmodels/teaching_view_model.dart';
import '../widgets/explanation_input_view.dart';
import '../widgets/mode_selection_view.dart';
import '../widgets/teaching_result_view.dart';

/// Med100's signature feature: after studying a topic, the learner
/// teaches it back — by voice or in writing — and the AI Engine
/// evaluates the explanation across six dimensions, synthesizes a
/// Mastery Score, and stores the attempt. One screen, one sealed
/// `TeachingUiState` driving which step shows, with `AnimatedSwitcher`
/// for a polished step-to-step transition rather than a hard cut.
class TeachingModeScreen extends ConsumerWidget {
  const TeachingModeScreen({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachingViewModelProvider(topic));
    final viewModel = ref.read(teachingViewModelProvider(topic).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Teaching Mode')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (state) {
          TeachingModeSelection() => ModeSelectionView(
            key: const ValueKey('selection'),
            topicId: topic.id,
            onSelect: viewModel.selectMode,
          ),
          TeachingInput(:final mode, :final draftText, :final isListening) => ExplanationInputView(
            key: const ValueKey('input'),
            mode: mode,
            draftText: draftText,
            isListening: isListening,
            onTextChanged: viewModel.updateDraftText,
            onStartVoice: viewModel.startVoiceInput,
            onStopVoice: viewModel.stopVoiceInput,
            onSubmit: viewModel.submit,
          ),
          TeachingSubmitting() => const _EvaluatingView(key: ValueKey('submitting')),
          TeachingResult(:final session) => TeachingResultView(
            key: const ValueKey('result'),
            session: session,
            onRetry: viewModel.restart,
            onDone: () => Navigator.of(context).maybePop(),
          ),
          TeachingSubmitFailed(:final failure) => _SubmitFailedView(
            key: const ValueKey('failed'),
            message: failure.message,
            onRetry: viewModel.submit,
          ),
        },
      ),
    );
  }
}

class _EvaluatingView extends StatelessWidget {
  const _EvaluatingView({super.key});

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
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3, color: colors.accentFill),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Evaluating your explanation…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitFailedView extends StatelessWidget {
  const _SubmitFailedView({super.key, required this.message, required this.onRetry});

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
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
