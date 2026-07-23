import 'entities/challenge_day_content.dart';

/// Bundled, offline, deterministic 100-day content — generated once here
/// rather than fetched from Firestore or any AI service, per Challenge
/// Mode's explicit no-AI, fully-offline scope. This is placeholder
/// content: real day-by-day clinical material is an editorial task for
/// `MED100_ARCHITECTURE.md`'s content pipeline, not something to
/// hand-author or generate here.
abstract final class ChallengeContent {
  static final List<ChallengeDayContent> days = List.unmodifiable(
    List.generate(totalDays, (index) {
      final day = index + 1;
      final theme = _themes[index % _themes.length];
      return ChallengeDayContent(day: day, title: 'Day $day · ${theme.title}', body: theme.body);
    }),
  );

  static const totalDays = 100;

  static ChallengeDayContent forDay(int day) => days[day - 1];
}

class _Theme {
  const _Theme(this.title, this.body);
  final String title;
  final String body;
}

const _themes = [
  _Theme(
    'Airway Basics',
    'Review the sequence for a rapid airway assessment: look, listen, and feel before reaching for adjuncts.',
  ),
  _Theme(
    'Fluid Balance',
    'Consider how intake, output, and insensible losses combine to shift a patient\'s volume status over 24 hours.',
  ),
  _Theme(
    'Reading a Rhythm Strip',
    'Practice identifying rate, rhythm, and axis before jumping to a diagnosis.',
  ),
  _Theme(
    'Infection Control Habits',
    'Revisit hand hygiene moments and why timing matters as much as technique.',
  ),
  _Theme(
    'Medication Timing',
    'Think through how a drug\'s half-life should shape its dosing interval.',
  ),
  _Theme(
    'Vital Sign Trends',
    'A single vital sign rarely tells the story — trends over time reveal more than any one reading.',
  ),
  _Theme(
    'Documentation Discipline',
    'Clear, timely notes protect both the patient and the clinician who wrote them.',
  ),
  _Theme(
    'Escalation Triggers',
    'Know the specific thresholds that should prompt you to call for senior help, before you need them.',
  ),
  _Theme(
    'Pain Assessment',
    'Pain is what the patient says it is — practice separating your assumptions from their report.',
  ),
  _Theme(
    'Handover Habits',
    'A good handover answers: what happened, what matters now, and what to watch for next.',
  ),
];
