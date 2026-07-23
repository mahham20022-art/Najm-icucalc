import '../domain/entities/token_usage.dart';
import '../domain/repositories/ai_provider.dart';

/// Turns a provider's reported [TokenUsage] into an estimated USD cost,
/// using each provider's own published per-model pricing (see
/// `OpenAiProvider`/`ClaudeProvider`'s pricing tables). This is the
/// *measurement* half of cost optimization; the *decision* half — always
/// checking cache before calling a provider at all, defaulting to cheap
/// models, and trimming prompts to budget — lives in
/// `AiEngineRepositoryImpl` and `TokenEstimator`.
class CostEstimator {
  const CostEstimator();

  double estimateCostUsd({
    required AiProvider provider,
    required String model,
    required TokenUsage usage,
  }) {
    final promptCost = usage.promptTokens / 1000 * provider.costPerThousandPromptTokensUsd(model);
    final completionCost =
        usage.completionTokens / 1000 * provider.costPerThousandCompletionTokensUsd(model);
    return promptCost + completionCost;
  }
}
