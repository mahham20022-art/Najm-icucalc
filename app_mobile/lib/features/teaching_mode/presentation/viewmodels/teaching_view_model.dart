import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/explanation_mode.dart';
import '../../domain/entities/teaching_session.dart';
import '../../teaching_providers.dart';

/// Teaching Mode's step-by-step flow, modeled as one sealed state per
/// step rather than a handful of independent booleans — a
/// `TeachingSubmitting` state, say, can't coexist with `TeachingResult`
/// by construction, which a flat "isSubmitting"/"result" field pair
/// would allow by accident.
sealed class TeachingUiState extends Equatable {
  const TeachingUiState();

  @override
  List<Object?> get props => [];
}

class TeachingModeSelection extends TeachingUiState {
  const TeachingModeSelection();
}

class TeachingInput extends TeachingUiState {
  const TeachingInput({required this.mode, required this.draftText, required this.isListening});

  final ExplanationMode mode;
  final String draftText;
  final bool isListening;

  @override
  List<Object?> get props => [mode, draftText, isListening];
}

class TeachingSubmitting extends TeachingUiState {
  const TeachingSubmitting({required this.mode, required this.explanationText});

  final ExplanationMode mode;
  final String explanationText;

  @override
  List<Object?> get props => [mode, explanationText];
}

class TeachingResult extends TeachingUiState {
  const TeachingResult(this.session);
  final TeachingSession session;

  @override
  List<Object?> get props => [session];
}

class TeachingSubmitFailed extends TeachingUiState {
  const TeachingSubmitFailed({
    required this.failure,
    required this.mode,
    required this.explanationText,
  });

  final Failure failure;
  final ExplanationMode mode;

  /// Preserved so a failed submission (e.g. rate-limited) doesn't throw
  /// away what the learner just wrote/said — retrying resumes editing
  /// from here rather than starting over.
  final String explanationText;

  @override
  List<Object?> get props => [failure, mode, explanationText];
}

class TeachingViewModel extends Notifier<TeachingUiState> {
  TeachingViewModel(this._topic);
  final Topic _topic;

  @override
  TeachingUiState build() {
    ref.onDispose(() {
      ref.read(speechRecognitionDataSourceProvider).cancel();
    });
    return const TeachingModeSelection();
  }

  void selectMode(ExplanationMode mode) {
    state = TeachingInput(mode: mode, draftText: '', isListening: false);
  }

  void updateDraftText(String text) {
    final current = state;
    if (current is! TeachingInput) return;
    state = TeachingInput(mode: current.mode, draftText: text, isListening: current.isListening);
  }

  Future<void> startVoiceInput() async {
    final current = state;
    if (current is! TeachingInput || current.mode != ExplanationMode.voice) return;

    state = TeachingInput(mode: current.mode, draftText: current.draftText, isListening: true);
    await ref
        .read(speechRecognitionDataSourceProvider)
        .startListening(
          onResult: (text, isFinal) {
            final latest = state;
            if (latest is! TeachingInput) return;
            state = TeachingInput(mode: latest.mode, draftText: text, isListening: !isFinal);
          },
          onError: (_) {
            final latest = state;
            if (latest is! TeachingInput) return;
            state = TeachingInput(
              mode: latest.mode,
              draftText: latest.draftText,
              isListening: false,
            );
          },
        );
  }

  Future<void> stopVoiceInput() async {
    await ref.read(speechRecognitionDataSourceProvider).stopListening();
    final current = state;
    if (current is TeachingInput) {
      state = TeachingInput(mode: current.mode, draftText: current.draftText, isListening: false);
    }
  }

  Future<void> submit() async {
    final current = state;
    final explanationText = current is TeachingInput
        ? current.draftText.trim()
        : current is TeachingSubmitFailed
        ? current.explanationText
        : null;
    final mode = current is TeachingInput
        ? current.mode
        : current is TeachingSubmitFailed
        ? current.mode
        : null;
    if (explanationText == null || mode == null || explanationText.isEmpty) return;

    state = TeachingSubmitting(mode: mode, explanationText: explanationText);
    final result = await ref.read(submitExplanationUseCaseProvider)(
      topic: _topic,
      mode: mode,
      explanationText: explanationText,
    );
    state = result.when(
      success: TeachingResult.new,
      failure: (failure) =>
          TeachingSubmitFailed(failure: failure, mode: mode, explanationText: explanationText),
    );
  }

  void restart() => state = const TeachingModeSelection();
}

final teachingViewModelProvider =
    NotifierProvider.family<TeachingViewModel, TeachingUiState, Topic>(TeachingViewModel.new);
