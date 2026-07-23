import 'package:equatable/equatable.dart';

import 'mcq.dart';

/// Exam Mode's in-progress state — sequential, one question at a time,
/// with no per-question feedback until [isComplete] (unlike the MCQs
/// section's practice list, which reveals the answer immediately). Both
/// draw from the same generated question bank
/// (`MasteryRepository.getMcqs`); Exam Mode is a presentation mode over
/// that data, not a separately-generated question set.
class ExamSession extends Equatable {
  const ExamSession({required this.mcqs, required this.currentIndex, required this.answers});

  factory ExamSession.start(List<Mcq> mcqs) =>
      ExamSession(mcqs: mcqs, currentIndex: 0, answers: const {});

  final List<Mcq> mcqs;
  final int currentIndex;

  /// Question index → the option index the user selected.
  final Map<int, int> answers;

  bool get isComplete => currentIndex >= mcqs.length;

  Mcq? get currentQuestion => isComplete ? null : mcqs[currentIndex];

  int get correctCount =>
      answers.entries.where((entry) => mcqs[entry.key].correctIndex == entry.value).length;

  double get scoreFraction => mcqs.isEmpty ? 0 : correctCount / mcqs.length;

  ExamSession answer(int optionIndex) {
    return ExamSession(
      mcqs: mcqs,
      currentIndex: currentIndex + 1,
      answers: {...answers, currentIndex: optionIndex},
    );
  }

  @override
  List<Object?> get props => [mcqs, currentIndex, answers];
}
