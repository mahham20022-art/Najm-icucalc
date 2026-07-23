/// The 14 tabs every topic offers in AI Mastery Mode. Content-shaped
/// sections (everything except [mcqs], [flashcards], [examMode], and
/// [consultantMode]) are fetched via `MasteryRepository.getProseSection`
/// or one of its dedicated structured-data methods; see that interface's
/// doc comment for which method backs which section.
enum MasterySectionType {
  summary,
  clinicalPearls,
  diagnosis,
  management,
  guidelines,
  comparisonTables,
  algorithms,
  mcqs,
  flashcards,
  references,
  explainSimply,
  explainDeeply,
  examMode,
  consultantMode,
}

extension MasterySectionTypeLabel on MasterySectionType {
  /// Short label for the section's tab/chip — kept here rather than in
  /// `.arb` files since these are internal fallback labels; the
  /// presentation layer prefers the localized string where one exists
  /// (see `MasteryHomeScreen`).
  String get fallbackLabel => switch (this) {
    MasterySectionType.summary => 'Summary',
    MasterySectionType.clinicalPearls => 'Clinical Pearls',
    MasterySectionType.diagnosis => 'Diagnosis',
    MasterySectionType.management => 'Management',
    MasterySectionType.guidelines => 'Guidelines',
    MasterySectionType.comparisonTables => 'Comparison Tables',
    MasterySectionType.algorithms => 'Algorithms',
    MasterySectionType.mcqs => 'MCQs',
    MasterySectionType.flashcards => 'Flashcards',
    MasterySectionType.references => 'References',
    MasterySectionType.explainSimply => 'Explain Simply',
    MasterySectionType.explainDeeply => 'Explain Deeply',
    MasterySectionType.examMode => 'Exam Mode',
    MasterySectionType.consultantMode => 'Consultant Mode',
  };
}
