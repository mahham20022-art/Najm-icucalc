import 'package:equatable/equatable.dart';

/// Real counts from Firestore aggregation (`.count()`) queries — no
/// Cloud Function or BigQuery export needed for these, unlike the
/// architecture doc's eventual "all heavy analytics isolated in
/// BigQuery" plan for richer reporting. This is the honest ceiling of
/// what a client-side dashboard can compute today: simple counts, not
/// trends/cohorts/funnels.
class DashboardMetrics extends Equatable {
  const DashboardMetrics({
    required this.totalUsers,
    required this.suspendedUsers,
    required this.premiumUsers,
    required this.totalTopics,
    required this.totalLearningPaths,
  });

  final int totalUsers;
  final int suspendedUsers;
  final int premiumUsers;
  final int totalTopics;
  final int totalLearningPaths;

  int get freeUsers => (totalUsers - premiumUsers).clamp(0, totalUsers);

  double? get premiumConversionRate => totalUsers == 0 ? null : premiumUsers / totalUsers;

  @override
  List<Object?> get props => [
    totalUsers,
    suspendedUsers,
    premiumUsers,
    totalTopics,
    totalLearningPaths,
  ];
}
