import 'package:equatable/equatable.dart';

/// Aggregate stats over a user's whole flashcard-schedule set, shown on
/// the Review Queue screen's statistics section.
class SpacedRepetitionStatistics extends Equatable {
  const SpacedRepetitionStatistics({
    required this.totalScheduled,
    required this.dueToday,
    required this.masteredCount,
    required this.totalReviews,
    required this.totalLapses,
  });

  final int totalScheduled;
  final int dueToday;
  final int masteredCount;
  final int totalReviews;
  final int totalLapses;

  /// Fraction of reviews graded `good` rather than `again` — `null` when
  /// there's no review history yet to divide by.
  double? get retentionRate =>
      totalReviews == 0 ? null : (totalReviews - totalLapses) / totalReviews;

  @override
  List<Object?> get props => [totalScheduled, dueToday, masteredCount, totalReviews, totalLapses];
}
