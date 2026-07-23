import '../domain/entities/ai_message.dart';

/// Token counting without a vendor-specific tokenizer (no Dart port of
/// tiktoken/Claude's tokenizer exists that would justify the dependency
/// weight for what's only ever used as a budget heuristic here) — uses
/// OpenAI's own documented rule of thumb, "~4 characters per token" for
/// English text, which is accurate enough to keep requests under budget
/// without needing exact counts. The AI Engine's actual accounting uses
/// each vendor's *reported* usage from the response, not this estimate;
/// this is only for the pre-flight truncation decision.
class TokenEstimator {
  const TokenEstimator();

  static const _charsPerToken = 4;

  /// Per-message overhead OpenAI's own docs use to account for role/
  /// formatting tokens that don't appear in the content string itself.
  static const _perMessageOverhead = 4;

  int estimateTokens(String text) => (text.length / _charsPerToken).ceil();

  int estimateMessagesTokens(List<AiMessage> messages) => messages.fold(
    0,
    (sum, message) => sum + estimateTokens(message.content) + _perMessageOverhead,
  );

  /// Token optimization: if [messages] would exceed [budget], drops the
  /// oldest non-system message first — repeatedly, until the estimate
  /// fits or only the system prompt remains. The system prompt is never
  /// trimmed: it carries the instructions that make the rest of the
  /// output usable at all, unlike conversation history, which degrades
  /// gracefully when shortened.
  List<AiMessage> truncateToBudget(List<AiMessage> messages, int budget) {
    final result = [...messages];
    while (estimateMessagesTokens(result) > budget) {
      final indexToRemove = result.indexWhere((message) => message.role != AiMessageRole.system);
      if (indexToRemove == -1) break;
      result.removeAt(indexToRemove);
    }
    return result;
  }
}
