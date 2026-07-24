import '../entities/dashboard_metrics.dart';

abstract interface class AnalyticsRepository {
  Future<DashboardMetrics> fetchMetrics();
}
