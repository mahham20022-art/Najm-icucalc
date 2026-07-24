import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/firestore_analytics_datasource.dart';

class FirestoreAnalyticsRepositoryImpl implements AnalyticsRepository {
  const FirestoreAnalyticsRepositoryImpl(this._dataSource);
  final FirestoreAnalyticsDataSource _dataSource;

  @override
  Future<Result<DashboardMetrics>> fetchMetrics() async {
    try {
      // Five independent aggregation queries — run concurrently rather
      // than sequentially, since none depends on another's result.
      final results = await Future.wait([
        _dataSource.totalUsers(),
        _dataSource.suspendedUsers(),
        _dataSource.premiumUsers(),
        _dataSource.totalTopics(),
        _dataSource.totalLearningPaths(),
      ]);

      return Result.success(
        DashboardMetrics(
          totalUsers: results[0],
          suspendedUsers: results[1],
          premiumUsers: results[2],
          totalTopics: results[3],
          totalLearningPaths: results[4],
        ),
      );
    } catch (_) {
      return const Result.failure(ServerFailure('Could not load dashboard metrics.'));
    }
  }
}
