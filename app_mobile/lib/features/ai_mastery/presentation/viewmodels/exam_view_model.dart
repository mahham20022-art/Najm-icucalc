import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/exam_session.dart';
import '../../mastery_providers.dart';

/// Exam Mode's UI state — reuses the same generated MCQ bank as the
/// MCQs section (`getMcqsUseCaseProvider`) but presents it sequentially
/// with no per-question feedback, per `ExamSession`'s doc comment.
sealed class ExamUiState extends Equatable {
  const ExamUiState();

  @override
  List<Object?> get props => [];
}

class ExamNotStarted extends ExamUiState {
  const ExamNotStarted();
}

class ExamLoading extends ExamUiState {
  const ExamLoading();
}

class ExamInProgress extends ExamUiState {
  const ExamInProgress(this.session);
  final ExamSession session;

  @override
  List<Object?> get props => [session];
}

class ExamLoadFailed extends ExamUiState {
  const ExamLoadFailed(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class ExamViewModel extends Notifier<ExamUiState> {
  ExamViewModel(this._topic);
  final Topic _topic;

  @override
  ExamUiState build() => const ExamNotStarted();

  Future<void> start() async {
    state = const ExamLoading();
    final result = await ref.read(getMcqsUseCaseProvider)(_topic);
    state = result.when(
      success: (mcqs) => ExamInProgress(ExamSession.start(mcqs)),
      failure: ExamLoadFailed.new,
    );
  }

  void answer(int optionIndex) {
    final current = state;
    if (current is! ExamInProgress || current.session.isComplete) return;
    state = ExamInProgress(current.session.answer(optionIndex));
  }

  void restart() => state = const ExamNotStarted();
}

final examViewModelProvider = NotifierProvider.family<ExamViewModel, ExamUiState, Topic>(
  ExamViewModel.new,
);
