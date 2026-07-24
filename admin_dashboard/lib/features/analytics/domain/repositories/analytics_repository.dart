import '../../../../core/error/result.dart';
import '../entities/dashboard_metrics.dart';

abstract interface class AnalyticsRepository {
  Future<Result<DashboardMetrics>> fetchMetrics();
}
