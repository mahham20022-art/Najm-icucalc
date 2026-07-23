import '../../domain/entities/ai_provider_id.dart';

/// Static configuration for the AI Engine — model choices, budgets, and
/// API credentials.
///
/// **Security note, read before shipping:** [openAiApiKey] and
/// [claudeApiKey] are read via `--dart-define` at build time, exactly
/// like `firebase_options.dart`'s foundation-stage placeholder project —
/// convenient for building and testing this engine now, but **not safe
/// to ship**. Unlike a Firebase Web API key (safe-by-design to expose;
/// access is enforced by Firestore Security Rules and App Check), an
/// OpenAI/Anthropic API key embedded in a compiled mobile binary can be
/// extracted via static analysis of the APK/IPA, letting anyone drain
/// the account's budget or scrape prompts. Before a real release, every
/// provider call in `data/providers/` must instead go through a backend
/// proxy (a Cloud Function) that holds the real vendor keys server-side
/// — precisely the `ai_bridge` vendor-abstraction boundary
/// `MED100_ARCHITECTURE.md` §10.3 already calls for; only the HTTP base
/// URL each provider points at would need to change, not the rest of
/// this module.
abstract final class AiEngineConfig {
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const claudeApiKey = String.fromEnvironment('ANTHROPIC_API_KEY');

  static const openAiBaseUrl = 'https://api.openai.com/v1';
  static const claudeBaseUrl = 'https://api.anthropic.com/v1';
  static const claudeApiVersion = '2023-06-01';

  /// Cost optimization: default to each vendor's small/cheap model,
  /// never the flagship one — topic summaries and MCQ explanations are
  /// short, well-specified tasks that don't need frontier-model
  /// capability, and the cost difference between tiers is roughly an
  /// order of magnitude.
  static const openAiDefaultModel = 'gpt-4o-mini';
  static const claudeDefaultModel = 'claude-3-5-haiku-20241022';

  static const defaultProvider = AiProviderId.openAi;

  static const requestsPerMinutePerProvider = 20;
  static const maxRetryAttempts = 3;

  /// A conservative shared prompt-token budget per request — keeps a
  /// single call's cost bounded regardless of how much variable content
  /// (a long topic body, a verbose MCQ stem) gets interpolated into a
  /// template. Enforced by [TokenEstimator.truncateToBudget].
  static const promptTokenBudget = 3000;

  /// How long a cached response is served before a fresh call is made
  /// again. A content or model change invalidates the cache immediately
  /// regardless of this TTL: the cache key hashes the fully-rendered
  /// prompt text and model name together (`AiEngineRepositoryImpl`), so
  /// if the source topic/MCQ text changes, the rendered prompt changes,
  /// and a different key is looked up automatically — this TTL only
  /// bounds how long an *unchanged* input's answer is reused.
  static const cacheTtl = Duration(days: 30);
}
