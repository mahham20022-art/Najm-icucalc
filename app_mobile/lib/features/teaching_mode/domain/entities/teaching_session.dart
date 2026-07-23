import 'package:equatable/equatable.dart';

import 'explanation_mode.dart';
import 'teaching_evaluation.dart';

/// One completed, persisted Teaching Mode attempt — the "stored
/// progress" this feature is responsible for.
class TeachingSession extends Equatable {
  const TeachingSession({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.mode,
    required this.explanationText,
    required this.evaluation,
    required this.completedAt,
  });

  final String id;
  final String topicId;
  final String topicTitle;
  final ExplanationMode mode;
  final String explanationText;
  final TeachingEvaluation evaluation;
  final DateTime completedAt;

  int get masteryScore => evaluation.masteryScore;

  @override
  List<Object?> get props => [
    id,
    topicId,
    topicTitle,
    mode,
    explanationText,
    evaluation,
    completedAt,
  ];
}
