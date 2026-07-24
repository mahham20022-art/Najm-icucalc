import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  const Flashcard({required this.id, required this.front, required this.back});

  /// A stable identity (`'<topicId>_<ordinal>'`, assigned by
  /// `MasteryRepositoryImpl` from the generated card's position) — the
  /// same topic's flashcards come back in the same order for as long as
  /// the AI Engine's cache entry is fresh, which is what lets
  /// `features/spaced_repetition` schedule reviews against a specific
  /// card rather than just "some flashcard for this topic."
  final String id;
  final String front;
  final String back;

  @override
  List<Object?> get props => [id, front, back];
}
