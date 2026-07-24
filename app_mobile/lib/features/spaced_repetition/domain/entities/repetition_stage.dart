/// The fixed Leitner-style ladder this feature implements: "review after
/// 7 days / 30 days / 90 days," per this feature's concrete build
/// instructions — a deliberate simplification of
/// `MED100_DATABASE_DESIGN.md`'s documented full SM-2 scheme (ease
/// factor, repetition count, 4-way grading).
enum RepetitionStage {
  /// Never successfully reviewed yet — due immediately.
  newCard,
  day7,
  day30,
  day90,

  /// Passed the day90 review — still shown in statistics, but no longer
  /// generates further due dates.
  mastered;

  /// How long after a `good` grade at this stage the card becomes due
  /// for the *next* stage — `null` for [mastered], which has no further
  /// review.
  Duration? get intervalToNext => switch (this) {
    newCard => const Duration(days: 7),
    day7 => const Duration(days: 30),
    day30 => const Duration(days: 90),
    day90 => null,
    mastered => null,
  };

  /// The stage reached after a `good` grade at this stage.
  RepetitionStage get nextOnGood => switch (this) {
    newCard => day7,
    day7 => day30,
    day30 => day90,
    day90 => mastered,
    mastered => mastered,
  };
}
