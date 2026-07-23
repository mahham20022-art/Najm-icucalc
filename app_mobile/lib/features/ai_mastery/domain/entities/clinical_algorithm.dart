import 'package:equatable/equatable.dart';

/// One step of a [ClinicalAlgorithm] — [branches] describes any
/// decision points from this step (e.g. "If troponin positive → admit
/// for ACS workup") as plain text, not an interactive graph; a learner
/// reads the algorithm top to bottom rather than tapping through a
/// decision tree.
class AlgorithmStep extends Equatable {
  const AlgorithmStep({required this.order, required this.text, this.branches = const []});

  final int order;
  final String text;
  final List<String> branches;

  @override
  List<Object?> get props => [order, text, branches];
}

class ClinicalAlgorithm extends Equatable {
  const ClinicalAlgorithm({required this.title, required this.steps});

  final String title;
  final List<AlgorithmStep> steps;

  @override
  List<Object?> get props => [title, steps];
}
