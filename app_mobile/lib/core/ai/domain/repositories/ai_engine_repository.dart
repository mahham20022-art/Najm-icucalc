import '../../../error/result.dart';
import '../entities/ai_message.dart';
import '../entities/ai_provider_id.dart';
import '../entities/ai_request.dart';
import '../entities/ai_response.dart';
import '../entities/ai_response_chunk.dart';

/// The AI Engine's single entry point. Callers never see a provider,
/// cache, rate limiter, or retry policy directly.
///
/// [generate] and [generateStream] own the whole templated pipeline
/// (cache lookup → rate limit → token-budget trim → provider call with
/// retry → cost accounting → cache write) described in
/// `AiEngineRepositoryImpl`. [chat] is the un-cached, multi-turn escape
/// hatch for a genuine back-and-forth conversation (Mastery Mode's
/// Consultant Mode) where every reply is unique to the conversation so
/// far and caching an answer would make no sense — it still goes through
/// rate limiting, just not the cache or template system.
///
/// Streaming methods wrap each emitted chunk in a [Result] rather than
/// letting the stream throw, so a mid-stream failure (rate limited
/// before any tokens arrive, or a provider error) is just another
/// `Failed` item a consumer handles with the same `.when()` pattern used
/// everywhere else in this codebase, instead of a separate
/// try/catch-around-a-stream code path.
abstract interface class AiEngineRepository {
  Future<Result<AiResponse>> generate(AiRequest request);

  Stream<Result<AiResponseChunk>> generateStream(AiRequest request);

  Stream<Result<AiResponseChunk>> chat({
    required List<AiMessage> messages,
    int maxTokens = 500,
    double temperature = 0.4,
    AiProviderId? providerOverride,
  });
}
