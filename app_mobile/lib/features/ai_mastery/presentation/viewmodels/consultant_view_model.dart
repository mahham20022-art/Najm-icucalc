import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/consultant_message.dart';
import '../../mastery_providers.dart';

/// Consultant Mode's chat state. Unlike the read-only sections, every
/// reply is unique to the conversation so far, so nothing here is
/// cached — each [ask] is a fresh, un-cached multi-turn call through
/// `AiEngineRepository.chat` (via `AskConsultantUseCase`).
class ConsultantUiState extends Equatable {
  const ConsultantUiState({
    required this.history,
    required this.streamingText,
    required this.sending,
    required this.error,
  });

  factory ConsultantUiState.initial() =>
      const ConsultantUiState(history: [], streamingText: null, sending: false, error: null);

  final List<ConsultantMessage> history;

  /// The assistant's in-progress reply, growing chunk by chunk — `null`
  /// when nothing is currently streaming.
  final String? streamingText;
  final bool sending;
  final Failure? error;

  @override
  List<Object?> get props => [history, streamingText, sending, error];
}

class ConsultantViewModel extends Notifier<ConsultantUiState> {
  ConsultantViewModel(this._topic);
  final Topic _topic;

  @override
  ConsultantUiState build() => ConsultantUiState.initial();

  Future<void> ask(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || state.sending) return;

    final historyBeforeThisTurn = state.history;
    final userMessage = ConsultantMessage(speaker: ConsultantSpeaker.user, content: trimmed);
    state = ConsultantUiState(
      history: [...historyBeforeThisTurn, userMessage],
      streamingText: '',
      sending: true,
      error: null,
    );

    final buffer = StringBuffer();
    final stream = ref.read(askConsultantUseCaseProvider)(
      topic: _topic,
      history: historyBeforeThisTurn,
      question: trimmed,
    );

    await for (final result in stream) {
      final failure = result.failureOrNull;
      if (failure != null) {
        state = ConsultantUiState(
          history: state.history,
          streamingText: null,
          sending: false,
          error: failure,
        );
        return;
      }

      final chunk = result.dataOrNull!;
      buffer.write(chunk.delta);
      if (!chunk.done) {
        state = ConsultantUiState(
          history: state.history,
          streamingText: buffer.toString(),
          sending: true,
          error: null,
        );
        continue;
      }

      final assistantMessage = ConsultantMessage(
        speaker: ConsultantSpeaker.consultant,
        content: buffer.toString(),
      );
      state = ConsultantUiState(
        history: [...state.history, assistantMessage],
        streamingText: null,
        sending: false,
        error: null,
      );
    }
  }
}

final consultantViewModelProvider =
    NotifierProvider.family<ConsultantViewModel, ConsultantUiState, Topic>(ConsultantViewModel.new);
