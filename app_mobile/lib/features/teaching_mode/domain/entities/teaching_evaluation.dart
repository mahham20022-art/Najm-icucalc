import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// The AI's structured judgment of one teach-back explanation, across
/// the six dimensions Teaching Mode evaluates. Every score is 0-100.
class TeachingEvaluation extends Equatable {
  const TeachingEvaluation({
    required this.accuracyScore,
    required this.clinicalReasoningScore,
    required this.completenessScore,
    required this.confidenceScore,
    required this.missingConcepts,
    required this.hallucinations,
    required this.feedback,
  });

  /// How factually correct the explanation is against the topic's
  /// source content.
  final int accuracyScore;

  /// Whether the explanation shows genuine clinical reasoning (why),
  /// not just recited facts (what).
  final int clinicalReasoningScore;

  /// How much of the topic's key content the explanation actually
  /// covered.
  final int completenessScore;

  /// How confidently/assuredly the explanation was delivered — a
  /// correct-but-hedging answer and a confidently wrong one are
  /// different problems, so this is tracked separately from accuracy.
  final int confidenceScore;

  /// Important concepts from the source material the explanation left
  /// out entirely.
  final List<String> missingConcepts;

  /// Claims the explanation made that are not supported by (or
  /// contradict) the topic's source content.
  final List<String> hallucinations;

  /// Narrative feedback — what to keep doing, what to fix.
  final String feedback;

  /// A deterministic, auditable synthesis of the four sub-scores,
  /// weighted toward accuracy and reasoning over raw completeness or
  /// confidence, then penalized per hallucinated claim — computed here
  /// rather than asked of the model, so "Generate Mastery Score" is a
  /// transparent step this codebase controls, not an LLM arithmetic
  /// result that could vary between otherwise-identical evaluations.
  int get masteryScore {
    final weighted =
        accuracyScore * 0.35 +
        clinicalReasoningScore * 0.30 +
        completenessScore * 0.20 +
        confidenceScore * 0.15;
    final hallucinationPenalty = math.min(30, hallucinations.length * 10);
    return (weighted - hallucinationPenalty).clamp(0, 100).round();
  }

  @override
  List<Object?> get props => [
    accuracyScore,
    clinicalReasoningScore,
    completenessScore,
    confidenceScore,
    missingConcepts,
    hallucinations,
    feedback,
  ];
}
