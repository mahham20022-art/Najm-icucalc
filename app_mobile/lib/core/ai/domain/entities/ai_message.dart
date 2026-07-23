import 'package:equatable/equatable.dart';

enum AiMessageRole { system, user, assistant }

/// One turn in a prompt — the vendor-agnostic shape every [AiProvider]
/// implementation adapts to its own wire format (OpenAI's flat
/// `messages` array including `system`; Claude's separate top-level
/// `system` field plus a `user`/`assistant`-only `messages` array).
class AiMessage extends Equatable {
  const AiMessage({required this.role, required this.content});

  final AiMessageRole role;
  final String content;

  @override
  List<Object?> get props => [role, content];
}
