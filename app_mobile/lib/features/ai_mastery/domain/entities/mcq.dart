import 'package:equatable/equatable.dart';

class Mcq extends Equatable {
  const Mcq({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  @override
  List<Object?> get props => [question, options, correctIndex, explanation];
}
