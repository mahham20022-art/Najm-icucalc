import '../entities/ai_message.dart';
import '../entities/ai_provider_id.dart';
import '../entities/token_usage.dart';

/// The vendor-abstraction boundary `MED100_ARCHITECTURE.md` §10.3 calls
/// for (`ContentGenerationPort`, generalized here to any vendor call, not
/// just content-assist) — every OpenAI/Claude-specific detail (wire
/// format, auth header, SSE event shape) stays behind this interface, so
/// `AiEngineRepositoryImpl` and everything above it never needs to know
/// which vendor answered.
abstract interface class AiProvider {
  AiProviderId get id;

  /// The model used when a caller/template doesn't pin one — chosen for
  /// cost, not capability ceiling, per the AI Engine's cost-optimization
  /// strategy (see `AiEngineRepositoryImpl`'s doc comment).
  String get defaultModel;

  double costPerThousandPromptTokensUsd(String model);
  double costPerThousandCompletionTokensUsd(String model);

  Future<AiProviderCompletion> complete({
    required List<AiMessage> messages,
    required int maxTokens,
    required double temperature,
    String? model,
  });

  /// Streamed equivalent of [complete]. Implementations yield one event
  /// per incremental delta, then a final `done: true` event carrying
  /// usage if the vendor reports it (some don't, in which case the
  /// caller falls back to [TokenEstimator]).
  Stream<AiProviderStreamEvent> completeStream({
    required List<AiMessage> messages,
    required int maxTokens,
    required double temperature,
    String? model,
  });
}

class AiProviderCompletion {
  const AiProviderCompletion({required this.content, required this.model, required this.usage});

  final String content;
  final String model;
  final TokenUsage usage;
}

class AiProviderStreamEvent {
  const AiProviderStreamEvent({required this.delta, required this.done, this.model, this.usage});

  final String delta;
  final bool done;
  final String? model;
  final TokenUsage? usage;
}

/// Thrown by an [AiProvider] implementation on a non-2xx HTTP response —
/// carries the status code so [RetryPolicy] can distinguish transient
/// failures (429, 5xx) from permanent ones (400, 401) without parsing
/// vendor-specific error bodies.
class AiProviderHttpException implements Exception {
  const AiProviderHttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'AiProviderHttpException($statusCode): $body';
}
