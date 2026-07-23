import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../app/bootstrap/bootstrap.dart';
import 'data/config/ai_engine_config.dart';
import 'data/cost_estimator.dart';
import 'data/datasources/ai_cache_local_datasource.dart';
import 'data/providers/claude_provider.dart';
import 'data/providers/openai_provider.dart';
import 'data/rate_limiter.dart';
import 'data/repositories/ai_engine_repository_impl.dart';
import 'data/retry_policy.dart';
import 'data/token_estimator.dart';
import 'domain/entities/ai_provider_id.dart';
import 'domain/repositories/ai_engine_repository.dart';
import 'domain/repositories/ai_provider.dart';
import 'domain/usecases/generate_ai_content_usecase.dart';
import 'domain/usecases/stream_ai_content_usecase.dart';

/// The AI Engine's DI graph. Every provider is overridable in tests —
/// nothing here reaches for a global singleton (`http.Client()` and the
/// two vendor `AiProvider`s are all constructed inside the provider
/// definitions below, using `ref.watch` for their dependencies).
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final openAiProviderInstanceProvider = Provider<AiProvider>((ref) {
  return OpenAiProvider(client: ref.watch(httpClientProvider));
});

final claudeProviderInstanceProvider = Provider<AiProvider>((ref) {
  return ClaudeProvider(client: ref.watch(httpClientProvider));
});

final aiCacheLocalDataSourceProvider = Provider<AiCacheLocalDataSource>((ref) {
  return AiCacheLocalDataSource(ref.watch(appDatabaseProvider));
});

final tokenEstimatorProvider = Provider<TokenEstimator>((ref) => const TokenEstimator());

final costEstimatorProvider = Provider<CostEstimator>((ref) => const CostEstimator());

final retryPolicyProvider = Provider<RetryPolicy>((ref) {
  return const RetryPolicy(maxAttempts: AiEngineConfig.maxRetryAttempts);
});

/// One rate limiter per provider — see `RateLimiter`'s doc comment on
/// why a shared instance would be wrong.
final _openAiRateLimiterProvider = Provider<RateLimiter>((ref) {
  return RateLimiter(
    maxRequests: AiEngineConfig.requestsPerMinutePerProvider,
    window: const Duration(minutes: 1),
  );
});

final _claudeRateLimiterProvider = Provider<RateLimiter>((ref) {
  return RateLimiter(
    maxRequests: AiEngineConfig.requestsPerMinutePerProvider,
    window: const Duration(minutes: 1),
  );
});

final aiEngineRepositoryProvider = Provider<AiEngineRepository>((ref) {
  return AiEngineRepositoryImpl(
    providers: {
      AiProviderId.openAi: ref.watch(openAiProviderInstanceProvider),
      AiProviderId.claude: ref.watch(claudeProviderInstanceProvider),
    },
    cache: ref.watch(aiCacheLocalDataSourceProvider),
    tokenEstimator: ref.watch(tokenEstimatorProvider),
    costEstimator: ref.watch(costEstimatorProvider),
    rateLimiters: {
      AiProviderId.openAi: ref.watch(_openAiRateLimiterProvider),
      AiProviderId.claude: ref.watch(_claudeRateLimiterProvider),
    },
    retryPolicy: ref.watch(retryPolicyProvider),
  );
});

final generateAiContentUseCaseProvider = Provider<GenerateAiContentUseCase>((ref) {
  return GenerateAiContentUseCase(ref.watch(aiEngineRepositoryProvider));
});

final streamAiContentUseCaseProvider = Provider<StreamAiContentUseCase>((ref) {
  return StreamAiContentUseCase(ref.watch(aiEngineRepositoryProvider));
});
