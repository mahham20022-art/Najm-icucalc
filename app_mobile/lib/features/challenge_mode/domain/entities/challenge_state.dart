import 'package:equatable/equatable.dart';

import '../challenge_content.dart';

/// The full state of a user's 100-day journey — persisted (Drift) and
/// re-derived into everything the UI needs (progress fraction, today's
/// day, whether today is already actioned) rather than storing those as
/// separately-maintained fields that could drift out of sync.
class ChallengeState extends Equatable {
  const ChallengeState({
    required this.startedAt,
    required this.lastActionDate,
    required this.completedDays,
    required this.skippedDays,
    required this.bookmarkedDays,
  });

  factory ChallengeState.fresh() => ChallengeState(
    startedAt: DateTime.now(),
    lastActionDate: null,
    completedDays: const {},
    skippedDays: const {},
    bookmarkedDays: const {},
  );

  final DateTime startedAt;

  /// The calendar date (time-of-day stripped) a day was last marked Done
  /// or Skipped — `null` if the journey hasn't been actioned yet. This is
  /// what Daily Unlock actually gates on: at most one day can be actioned
  /// per calendar date, not "one every 24 hours" (which would drift
  /// later and later each day the user opens the app a bit later).
  final DateTime? lastActionDate;

  final Set<int> completedDays;
  final Set<int> skippedDays;
  final Set<int> bookmarkedDays;

  int get daysActioned => completedDays.length + skippedDays.length;

  /// 1-based; the journey is finished once every day has been actioned.
  int get currentDay => (daysActioned + 1).clamp(1, ChallengeContent.totalDays);

  bool get isComplete => daysActioned >= ChallengeContent.totalDays;

  /// Daily Unlock: today's day has already been actioned if
  /// [lastActionDate] is today's date — the UI shows a "come back
  /// tomorrow" state instead of Done/Skip in that case.
  bool isActionedToday({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final last = lastActionDate;
    return last != null && _dateOnly(last) == today;
  }

  double get progressFraction => daysActioned / ChallengeContent.totalDays;

  /// Consecutive days completed (not skipped) counting back from the
  /// most recent actioned day — resets to 0 the moment a day is skipped.
  int get currentStreak {
    var streak = 0;
    for (var day = daysActioned; day >= 1; day--) {
      if (completedDays.contains(day)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  ChallengeState copyWith({
    DateTime? lastActionDate,
    Set<int>? completedDays,
    Set<int>? skippedDays,
    Set<int>? bookmarkedDays,
  }) => ChallengeState(
    startedAt: startedAt,
    lastActionDate: lastActionDate ?? this.lastActionDate,
    completedDays: completedDays ?? this.completedDays,
    skippedDays: skippedDays ?? this.skippedDays,
    bookmarkedDays: bookmarkedDays ?? this.bookmarkedDays,
  );

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  List<Object?> get props => [
    startedAt,
    lastActionDate,
    completedDays,
    skippedDays,
    bookmarkedDays,
  ];
}
