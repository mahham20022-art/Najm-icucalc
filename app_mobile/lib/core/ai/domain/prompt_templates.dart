import 'entities/prompt_template.dart';
import 'entities/prompt_type.dart';

/// Bundled, hand-authored prompt templates — the AI Engine's equivalent
/// of `features/challenge_mode/domain/challenge_content.dart`'s static
/// content registry. Prompts are reviewed and shipped with the app, not
/// user-editable or server-fetched, matching the PRD's
/// clinician-reviewed-content posture even for AI-generated output.
abstract final class PromptTemplates {
  static const topicSummary = PromptTemplate(
    id: 'topic_summary_v1',
    promptType: PromptType.topicSummary,
    systemPrompt:
        'You are a clinical education assistant summarizing content for a busy '
        'clinician or medical trainee. Be accurate, concise, and never invent '
        'facts not present in the source text.',
    userTemplate:
        'Topic title: {{title}}\n\n'
        'Full content:\n{{body}}\n\n'
        'Write a concise 3-4 sentence summary a learner could read in under '
        '15 seconds, capturing only the most clinically important points.',
    maxTokens: 300,
    temperature: 0.3,
  );

  static const mcqExplanation = PromptTemplate(
    id: 'mcq_explanation_v1',
    promptType: PromptType.mcqExplanation,
    systemPrompt:
        'You are a clinical education assistant explaining why an MCQ answer '
        'is correct, for a {{specialty}} learner. Be precise and cite the '
        'relevant clinical reasoning, not just "because the guideline says so."',
    userTemplate:
        'Question: {{question}}\n'
        'Correct answer: {{correctAnswer}}\n\n'
        'Explain in 2-3 sentences why this is the correct answer.',
    maxTokens: 220,
    temperature: 0.2,
  );

  static const all = [topicSummary, mcqExplanation];

  static PromptTemplate byId(String id) => all.firstWhere(
    (template) => template.id == id,
    orElse: () => throw ArgumentError('No PromptTemplate registered with id "$id"'),
  );
}
