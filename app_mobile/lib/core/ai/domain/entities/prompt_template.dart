import 'package:equatable/equatable.dart';

import 'ai_message.dart';
import 'prompt_type.dart';

/// A named, versioned prompt — bundled and offline like
/// `features/challenge_mode/domain/challenge_content.dart`'s day
/// content, not fetched or user-authored. The `_v1` suffix on template
/// ids is deliberate: bumping a template's wording to `_v2` naturally
/// invalidates any cache entries keyed against the old id, without
/// needing a separate cache-busting mechanism.
class PromptTemplate extends Equatable {
  const PromptTemplate({
    required this.id,
    required this.promptType,
    required this.systemPrompt,
    required this.userTemplate,
    this.maxTokens = 400,
    this.temperature = 0.3,
  });

  final String id;
  final PromptType promptType;
  final String systemPrompt;

  /// May contain `{{variableName}}` placeholders, substituted by [render].
  final String userTemplate;
  final int maxTokens;
  final double temperature;

  /// Substitutes every `{{key}}` in both [systemPrompt] and
  /// [userTemplate] with `variables[key]` and returns the ready-to-send
  /// message pair. Throws [ArgumentError] if a placeholder is left
  /// unfilled — a missing variable is a caller bug (typo'd key,
  /// forgotten argument), not something that should silently reach the
  /// model as literal `{{...}}` text.
  List<AiMessage> render(Map<String, String> variables) {
    return [
      AiMessage(role: AiMessageRole.system, content: _substitute(systemPrompt, variables)),
      AiMessage(role: AiMessageRole.user, content: _substitute(userTemplate, variables)),
    ];
  }

  String _substitute(String template, Map<String, String> variables) {
    var rendered = template;
    for (final entry in variables.entries) {
      rendered = rendered.replaceAll('{{${entry.key}}}', entry.value);
    }
    final leftoverMatch = RegExp(r'\{\{(\w+)\}\}').firstMatch(rendered);
    if (leftoverMatch != null) {
      throw ArgumentError(
        'PromptTemplate "$id": missing variable "${leftoverMatch.group(1)}" — '
        'every {{placeholder}} in the template must be supplied.',
      );
    }
    return rendered;
  }

  @override
  List<Object?> get props => [id, promptType, systemPrompt, userTemplate, maxTokens, temperature];
}
