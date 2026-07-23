import '../../../core/ai/domain/entities/prompt_template.dart';
import '../../../core/ai/domain/entities/prompt_type.dart';

/// Teaching Mode's own bundled template — feature-owned, per
/// `AiRequest`'s doc comment on why prompts are passed by value instead
/// of looked up in `core/ai`'s shared registry.
abstract final class TeachingPromptTemplates {
  static const evaluation = PromptTemplate(
    id: 'teaching_evaluation_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You are a rigorous but encouraging clinical education evaluator. '
        'A learner just tried to teach back what they understood about a '
        'topic, in their own words (the Feynman technique). Evaluate their '
        'explanation strictly against the provided source material — never '
        "penalize for something the source doesn't cover, and never credit "
        "a claim the source doesn't support. Respond with ONLY valid JSON — "
        'no markdown code fences, no commentary — matching exactly this '
        'shape: {"accuracyScore": number, "clinicalReasoningScore": number, '
        '"completenessScore": number, "confidenceScore": number, '
        '"missingConcepts": string[], "hallucinations": string[], '
        '"feedback": string}. All four scores are 0-100. "confidenceScore" '
        "reflects how assured vs. hedging the explanation's language was, "
        'not whether it was correct. "missingConcepts" lists important '
        'source concepts the explanation left out entirely. '
        '"hallucinations" lists specific claims the explanation made that '
        "the source doesn't support or that contradict it. \"feedback\" is "
        '2-4 sentences of direct, specific, encouraging-but-honest '
        'narrative feedback the learner will read.',
    userTemplate:
        'Topic: {{title}}\n\n'
        'Source content (ground truth):\n{{body}}\n\n'
        "Learner's {{mode}} explanation:\n{{explanation}}\n\n"
        'Evaluate this explanation now.',
    maxTokens: 700,
    temperature: 0.2,
  );
}
