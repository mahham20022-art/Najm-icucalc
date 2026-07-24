import '../../../../core/error/result.dart';
import '../entities/dashboard_metrics.dart';
import '../repositories/analytics_repository.dart';

class FetchDashboardMetricsUseCase {
  const FetchDashboardMetricsUseCase(this._repository);
  final AnalyticsRepository _repository;

  Future<Result<DashboardMetrics>> call() => _repository.fetchMetrics();
}
