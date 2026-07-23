import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../../error/failure.dart';
import '../../../error/result.dart';
import '../../domain/entities/ai_message.dart';
import '../../domain/entities/ai_provider_id.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_response_chunk.dart';
import '../../domain/entities/prompt_template.dart';
import '../../domain/entities/token_usage.dart';
import '../../domain/repositories/ai_engine_repository.dart';
import '../../domain/repositories/ai_provider.dart';
import '../config/ai_engine_config.dart';
import '../cost_estimator.dart';
import '../datasources/ai_cache_local_datasource.dart';
import '../rate_limiter.dart';
import '../retry_policy.dart';
import '../token_estimator.dart';

// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// (`providers`) distinct from their private backing fields (`_providers`)
// for a readable call site — an initializing formal would force the
// parameter name itself to be private.

/// Orchestrates every AI Engine feature into one pipeline, in this order:
///
/// 1. **Cache** — the biggest cost lever: identical input never pays for
///    a second call.
/// 2. **Rate limiting** — reject before sending, never after a vendor
///    429.
/// 3. **Token optimization** — trim to [AiEngineConfig.promptTokenBudget]
///    before it ever leaves the device.
/// 4. **Retry logic** — [RetryPolicy] wraps the non-streaming call only
///    (see its doc comment for why streaming isn't retried).
/// 5. **Cost accounting** — every response (streamed or not) carries an
///    estimated USD cost derived from the vendor's own reported usage.
///
/// Cost optimization is not a single step but the sum of 1, 3, and
/// defaulting every provider to its cheapest viable model
/// (`AiEngineConfig`) — there is deliberately no "pick the cheapest
/// provider at call time" logic, since provider choice here is about
/// vendor redundancy/quality, not price arbitrage between two already-
/// cheap small models.
class AiEngineRepositoryImpl implements AiEngineRepository {
  AiEngineRepositoryImpl({
    required Map<AiProviderId, AiProvider> providers,
    required AiCacheLocalDataSource cache,
    required TokenEstimator tokenEstimator,
    required CostEstimator costEstimator,
    required Map<AiProviderId, RateLimiter> rateLimiters,
    required RetryPolicy retryPolicy,
  }) : _providers = providers,
       _cache = cache,
       _tokenEstimator = tokenEstimator,
       _costEstimator = costEstimator,
       _rateLimiters = rateLimiters,
       _retryPolicy = retryPolicy;

  final Map<AiProviderId, AiProvider> _providers;
  final AiCacheLocalDataSource _cache;
  final TokenEstimator _tokenEstimator;
  final CostEstimator _costEstimator;
  final Map<AiProviderId, RateLimiter> _rateLimiters;
  final RetryPolicy _retryPolicy;

  @override
  Future<Result<AiResponse>> generate(AiRequest request) async {
    final plan = _plan(request);

    final cached = await _cache.getIfFresh(plan.cacheKey);
    if (cached != null) {
      return Result.success(_cachedResponse(plan, cached));
    }

    if (!_rateLimiters[plan.providerId]!.tryAcquire()) {
      return const Result.failure(AiRateLimitedFailure());
    }

    try {
      final completion = await _retryPolicy.run(
        () => plan.provider.complete(
          messages: plan.messages,
          maxTokens: plan.template.maxTokens,
          temperature: plan.template.temperature,
          model: plan.model,
        ),
        retryIf: _isRetryable,
      );

      final cost = _costEstimator.estimateCostUsd(
        provider: plan.provider,
        model: completion.model,
        usage: completion.usage,
      );
      await _cache.save(
        cacheKey: plan.cacheKey,
        itemType: request.itemType,
        itemId: request.itemId,
        content: completion.content,
        expiresAt: DateTime.now().add(AiEngineConfig.cacheTtl),
      );

      return Result.success(
        AiResponse(
          content: completion.content,
          provider: plan.providerId,
          model: completion.model,
          usage: completion.usage,
          estimatedCostUsd: cost,
          cached: false,
        ),
      );
    } catch (_) {
      return const Result.failure(AiProviderFailure());
    }
  }

  @override
  Stream<Result<AiResponseChunk>> generateStream(AiRequest request) async* {
    final plan = _plan(request);

    final cached = await _cache.getIfFresh(plan.cacheKey);
    if (cached != null) {
      yield Result.success(
        AiResponseChunk(delta: cached, done: true, finalResponse: _cachedResponse(plan, cached)),
      );
      return;
    }

    if (!_rateLimiters[plan.providerId]!.tryAcquire()) {
      yield const Result.failure(AiRateLimitedFailure());
      return;
    }

    final buffer = StringBuffer();
    try {
      final events = plan.provider.completeStream(
        messages: plan.messages,
        maxTokens: plan.template.maxTokens,
        temperature: plan.template.temperature,
        model: plan.model,
      );

      await for (final event in events) {
        buffer.write(event.delta);
        if (!event.done) {
          yield Result.success(AiResponseChunk(delta: event.delta, done: false));
          continue;
        }

        final resultModel = event.model ?? plan.model;
        final usage =
            event.usage ??
            TokenUsage(
              promptTokens: _tokenEstimator.estimateMessagesTokens(plan.messages),
              completionTokens: _tokenEstimator.estimateTokens(buffer.toString()),
            );
        final cost = _costEstimator.estimateCostUsd(
          provider: plan.provider,
          model: resultModel,
          usage: usage,
        );
        final finalResponse = AiResponse(
          content: buffer.toString(),
          provider: plan.providerId,
          model: resultModel,
          usage: usage,
          estimatedCostUsd: cost,
          cached: false,
        );

        await _cache.save(
          cacheKey: plan.cacheKey,
          itemType: request.itemType,
          itemId: request.itemId,
          content: buffer.toString(),
          expiresAt: DateTime.now().add(AiEngineConfig.cacheTtl),
        );

        yield Result.success(
          AiResponseChunk(delta: event.delta, done: true, finalResponse: finalResponse),
        );
      }
    } catch (_) {
      yield const Result.failure(AiProviderFailure());
    }
  }

  @override
  Stream<Result<AiResponseChunk>> chat({
    required List<AiMessage> messages,
    int maxTokens = 500,
    double temperature = 0.4,
    AiProviderId? providerOverride,
  }) async* {
    final providerId = providerOverride ?? AiEngineConfig.defaultProvider;
    final provider = _providers[providerId]!;
    final model = provider.defaultModel;
    final optimizedMessages = _tokenEstimator.truncateToBudget(
      messages,
      AiEngineConfig.promptTokenBudget,
    );

    if (!_rateLimiters[providerId]!.tryAcquire()) {
      yield const Result.failure(AiRateLimitedFailure());
      return;
    }

    final buffer = StringBuffer();
    try {
      final events = provider.completeStream(
        messages: optimizedMessages,
        maxTokens: maxTokens,
        temperature: temperature,
        model: model,
      );

      await for (final event in events) {
        buffer.write(event.delta);
        if (!event.done) {
          yield Result.success(AiResponseChunk(delta: event.delta, done: false));
          continue;
        }

        final resultModel = event.model ?? model;
        final usage =
            event.usage ??
            TokenUsage(
              promptTokens: _tokenEstimator.estimateMessagesTokens(optimizedMessages),
              completionTokens: _tokenEstimator.estimateTokens(buffer.toString()),
            );
        final cost = _costEstimator.estimateCostUsd(
          provider: provider,
          model: resultModel,
          usage: usage,
        );

        yield Result.success(
          AiResponseChunk(
            delta: event.delta,
            done: true,
            finalResponse: AiResponse(
              content: buffer.toString(),
              provider: providerId,
              model: resultModel,
              usage: usage,
              estimatedCostUsd: cost,
              cached: false,
            ),
          ),
        );
      }
    } catch (_) {
      yield const Result.failure(AiProviderFailure());
    }
  }

  _GenerationPlan _plan(AiRequest request) {
    final template = request.promptTemplate;
    final messages = template.render(request.variables);
    final providerId = request.providerOverride ?? AiEngineConfig.defaultProvider;
    final provider = _providers[providerId]!;
    final model = provider.defaultModel;
    final optimizedMessages = _tokenEstimator.truncateToBudget(
      messages,
      AiEngineConfig.promptTokenBudget,
    );

    final renderedInput = optimizedMessages.map((m) => '${m.role.name}:${m.content}').join('\n');
    final cacheKey = _cacheKey(templateId: template.id, renderedInput: renderedInput, model: model);

    return _GenerationPlan(
      template: template,
      messages: optimizedMessages,
      providerId: providerId,
      provider: provider,
      model: model,
      cacheKey: cacheKey,
    );
  }

  AiResponse _cachedResponse(_GenerationPlan plan, String content) => AiResponse(
    content: content,
    provider: plan.providerId,
    model: plan.model,
    usage: TokenUsage.zero,
    estimatedCostUsd: 0,
    cached: true,
  );

  /// Only network-level failures (timeout, connection reset/DNS via
  /// `http.ClientException`, cross-platform unlike `dart:io`'s
  /// `SocketException`) and the vendor's own transient statuses (429,
  /// 5xx) are retried. Anything else — a malformed response body, an
  /// auth error — will fail identically every time, so retrying would
  /// only waste the backoff budget and, for a real HTTP failure that
  /// still costs the vendor compute, real money.
  bool _isRetryable(Object error) {
    if (error is AiProviderHttpException) {
      return error.statusCode == 429 || error.statusCode >= 500;
    }
    return error is TimeoutException || error is http.ClientException;
  }

  /// `sha256(promptType + inputHash + modelVersion)` per
  /// `MED100_DATABASE_DESIGN.md` §10 — [templateId] stands in for
  /// `promptType` here since template ids are already unique and
  /// versioned (`topic_summary_v1`), so a template's own identity is a
  /// more precise cache-key input than a shared coarse-grained enum.
  String _cacheKey({
    required String templateId,
    required String renderedInput,
    required String model,
  }) {
    final raw = '$templateId:$renderedInput:$model';
    return sha256.convert(utf8.encode(raw)).toString();
  }
}

class _GenerationPlan {
  const _GenerationPlan({
    required this.template,
    required this.messages,
    required this.providerId,
    required this.provider,
    required this.model,
    required this.cacheKey,
  });

  final PromptTemplate template;
  final List<AiMessage> messages;
  final AiProviderId providerId;
  final AiProvider provider;
  final String model;
  final String cacheKey;
}
