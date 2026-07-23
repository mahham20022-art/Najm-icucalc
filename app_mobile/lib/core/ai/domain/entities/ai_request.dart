import 'package:equatable/equatable.dart';

import 'ai_provider_id.dart';

/// What a caller asks the AI Engine for — a [PromptTemplate] id plus the
/// variables to render it with, and enough item identity
/// (`itemType`/`itemId`) to populate the local cache row the same way
/// `MED100_DATABASE_DESIGN.md` §10's `ai_cache_local` table expects.
class AiRequest extends Equatable {
  const AiRequest({
    required this.promptTemplateId,
    required this.variables,
    required this.itemType,
    required this.itemId,
    this.providerOverride,
  });

  final String promptTemplateId;
  final Map<String, String> variables;

  /// `mcq | topic | flashcard` — mirrors `ai_cache_local.itemType`.
  final String itemType;
  final String itemId;

  /// `null` lets the engine choose (cost optimization); set this only
  /// when a caller has a specific reason to pin a vendor.
  final AiProviderId? providerOverride;

  @override
  List<Object?> get props => [promptTemplateId, variables, itemType, itemId, providerOverride];
}
