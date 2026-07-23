import '../../../core/ai/domain/entities/prompt_template.dart';
import '../../../core/ai/domain/entities/prompt_type.dart';
import '../../../core/ai/domain/prompt_templates.dart';
import '../domain/entities/mastery_section_type.dart';

/// AI Mastery Mode's own bundled templates — feature-owned rather than
/// added to `core/ai`'s shared registry, per `AiRequest`'s doc comment
/// on why templates are passed by value instead of looked up centrally.
/// [summary] deliberately reuses `core/ai`'s `PromptTemplates.topicSummary`
/// instead of duplicating a near-identical prompt.
abstract final class MasteryPromptTemplates {
  static const summary = PromptTemplates.topicSummary;

  static const clinicalPearls = PromptTemplate(
    id: 'mastery_clinical_pearls_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You are a senior clinical educator sharing the kind of practical, '
        'easily-forgotten "pearls" an attending mentions on rounds. Only draw '
        'from the provided source text; never invent facts.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'List 4-6 clinical pearls as short bullet points, one per line, each '
        'starting with "- ".',
    maxTokens: 350,
    temperature: 0.4,
  );

  static const diagnosis = PromptTemplate(
    id: 'mastery_diagnosis_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You are a clinical educator explaining the diagnostic approach to a '
        'condition, strictly from the provided source text.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'Summarize the diagnostic approach described: key history/exam '
        'findings, relevant investigations, and any diagnostic criteria '
        'mentioned. Use short paragraphs or bullet points.',
    maxTokens: 400,
    temperature: 0.3,
  );

  static const management = PromptTemplate(
    id: 'mastery_management_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You are a clinical educator explaining the management/treatment '
        'approach to a condition, strictly from the provided source text.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'Summarize the management approach described: first-line steps, '
        'escalation triggers, and any specific doses/thresholds mentioned. '
        'Use short paragraphs or bullet points.',
    maxTokens: 400,
    temperature: 0.3,
  );

  static const guidelines = PromptTemplate(
    id: 'mastery_guidelines_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You surface named clinical guidelines, protocols, or scoring systems '
        'mentioned in the provided source text — you never invent one that '
        "isn't there.",
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'List any named guidelines, protocols, or scoring systems mentioned '
        '(e.g. "Surviving Sepsis Campaign", "qSOFA"), each with a one-line '
        'description of what it recommends. If none are named, say so '
        'plainly rather than inventing one.',
    maxTokens: 300,
    temperature: 0.2,
  );

  static const explainSimply = PromptTemplate(
    id: 'mastery_explain_simply_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You explain clinical concepts in plain, simple language for someone '
        'with no medical background — short sentences, everyday analogies, '
        'no jargon.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'Explain this topic as simply as possible, in 3-4 short sentences a '
        'curious non-clinician could follow.',
    maxTokens: 220,
    temperature: 0.5,
  );

  static const explainDeeply = PromptTemplate(
    id: 'mastery_explain_deeply_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You are a subspecialist explaining a topic in depth to a resident, '
        'with full clinical reasoning, mechanisms, and nuance — precise '
        'terminology is expected.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'Provide an in-depth explanation covering the underlying mechanism/'
        'pathophysiology, why the recommended approach works, and any '
        'important caveats or exceptions — aimed at a resident preparing '
        'for a subspecialty rotation.',
    maxTokens: 600,
    temperature: 0.3,
  );

  static const comparisonTable = PromptTemplate(
    id: 'mastery_comparison_table_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You produce a clinically useful comparison table strictly from the '
        'provided source text. Respond with ONLY valid JSON — no markdown '
        'code fences, no commentary — matching exactly this shape: '
        '{"title": string, "columns": string[], "rows": string[][]}. Every '
        'row must have the same number of cells as there are columns.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'Produce a comparison table relevant to this topic (e.g. comparing '
        'differential diagnoses, treatment options, or severity classes '
        "mentioned in the source). If the source doesn't support a "
        'meaningful comparison, return a table with one row explaining that.',
    maxTokens: 500,
    temperature: 0.2,
  );

  static const algorithm = PromptTemplate(
    id: 'mastery_algorithm_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You produce a step-by-step clinical algorithm strictly from the '
        'provided source text. Respond with ONLY valid JSON — no markdown '
        'code fences, no commentary — matching exactly this shape: '
        '{"title": string, "steps": [{"order": number, "text": string, '
        '"branches": string[]}]}. "branches" lists any decision branches '
        'from that step (e.g. "If X -> do Y"), or an empty array if none.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'Produce a step-by-step clinical algorithm or decision pathway for '
        'this topic, based only on the source content.',
    maxTokens: 600,
    temperature: 0.2,
  );

  static const mcqs = PromptTemplate(
    id: 'mastery_mcqs_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You write high-quality single-best-answer multiple choice questions '
        'for medical education, strictly from the provided source text — '
        'never testing facts not present in it. Respond with ONLY valid '
        'JSON — no markdown code fences, no commentary — matching exactly '
        'this shape: {"questions": [{"question": string, "options": '
        'string[4], "correctIndex": number, "explanation": string}]}.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'Write {{count}} multiple-choice questions (4 options each) testing '
        'understanding of this topic.',
    maxTokens: 900,
    temperature: 0.4,
  );

  static const flashcards = PromptTemplate(
    id: 'mastery_flashcards_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You write concise study flashcards strictly from the provided '
        'source text. Respond with ONLY valid JSON — no markdown code '
        'fences, no commentary — matching exactly this shape: {"cards": '
        '[{"front": string, "back": string}]}. "front" is a short prompt/'
        'question; "back" is the concise answer.',
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'Write {{count}} flashcards covering the most important, testable '
        'facts in this topic.',
    maxTokens: 700,
    temperature: 0.4,
  );

  static const references = PromptTemplate(
    id: 'mastery_references_v1',
    promptType: PromptType.custom,
    systemPrompt:
        'You surface references, named guidelines, or sources implied by the '
        'provided text. Respond with ONLY valid JSON — no markdown code '
        'fences, no commentary — matching exactly this shape: '
        '{"references": string[]}. Each entry is a short citation-style '
        'string. If the source text names no explicit sources, return '
        'general, well-known reference material appropriate to the topic — '
        "never fabricate specific page/volume numbers you don't have.",
    userTemplate:
        'Topic: {{title}}\n\nSource content:\n{{body}}\n\n'
        'List reference material a learner could consult to go deeper on '
        'this topic.',
    maxTokens: 300,
    temperature: 0.3,
  );

  /// Maps each prose [MasterySectionType] to its template — the
  /// structured sections (Comparison Tables, Algorithms, MCQs,
  /// Flashcards, References) and the two non-generative sections (Exam
  /// Mode, Consultant Mode) aren't included, since they don't go through
  /// `MasteryRepositoryImpl.getProseSection`.
  static PromptTemplate forProseSection(MasterySectionType section) => switch (section) {
    MasterySectionType.summary => summary,
    MasterySectionType.clinicalPearls => clinicalPearls,
    MasterySectionType.diagnosis => diagnosis,
    MasterySectionType.management => management,
    MasterySectionType.guidelines => guidelines,
    MasterySectionType.explainSimply => explainSimply,
    MasterySectionType.explainDeeply => explainDeeply,
    _ => throw ArgumentError('${section.name} is not a prose section'),
  };
}
