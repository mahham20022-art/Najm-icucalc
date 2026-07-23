import 'package:equatable/equatable.dart';

import 'ai_provider_id.dart';
import 'prompt_template.dart';

/// What a caller asks the AI Engine for — a [PromptTemplate] plus the
/// variables to render it with, and enough item identity
/// (`itemType`/`itemId`) to populate the local cache row the same way
/// `MED100_DATABASE_DESIGN.md` §10's `ai_cache_local` table expects.
///
/// Carries the [PromptTemplate] itself rather than an id looked up in a
/// single central registry — `core/ai`'s own `PromptTemplates` holds the
/// generic, cross-feature templates, but any feature (e.g.
/// `features/ai_mastery`) is free to define and own its own templates
/// without `core` needing to know about them, per the dependency
/// direction in `MED100_ARCHITECTURE.md` §3.
class AiRequest extends Equatable {
  const AiRequest({
    required this.promptTemplate,
    required this.variables,
    required this.itemType,
    required this.itemId,
    this.providerOverride,
  });

  final PromptTemplate promptTemplate;
  final Map<String, String> variables;

  /// `mcq | topic | flashcard` — mirrors `ai_cache_local.itemType`.
  final String itemType;
  final String itemId;

  /// `null` lets the engine choose (cost optimization); set this only
  /// when a caller has a specific reason to pin a vendor.
  final AiProviderId? providerOverride;

  @override
  List<Object?> get props => [promptTemplate, variables, itemType, itemId, providerOverride];
}
