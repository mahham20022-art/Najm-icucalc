import 'package:equatable/equatable.dart';

enum ConsultantSpeaker { user, consultant }

/// One turn in Consultant Mode's chat — the UI-facing equivalent of
/// `core/ai`'s `AiMessage`, kept separate so this feature never leans on
/// the AI Engine's wire-format type for its own conversation history.
class ConsultantMessage extends Equatable {
  const ConsultantMessage({required this.speaker, required this.content});

  final ConsultantSpeaker speaker;
  final String content;

  @override
  List<Object?> get props => [speaker, content];
}
