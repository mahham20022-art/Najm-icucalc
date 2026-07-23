import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  const Flashcard({required this.front, required this.back});

  final String front;
  final String back;

  @override
  List<Object?> get props => [front, back];
}
