import 'package:equatable/equatable.dart';

import 'ai_provider_id.dart';
import 'token_usage.dart';

class AiResponse extends Equatable {
  const AiResponse({
    required this.content,
    required this.provider,
    required this.model,
    required this.usage,
    required this.estimatedCostUsd,
    required this.cached,
  });

  final String content;
  final AiProviderId provider;
  final String model;
  final TokenUsage usage;

  /// `0` whenever [cached] is `true` — a cache hit costs nothing, which
  /// is the whole point of caching as a cost-optimization lever.
  final double estimatedCostUsd;
  final bool cached;

  @override
  List<Object?> get props => [content, provider, model, usage, estimatedCostUsd, cached];
}
