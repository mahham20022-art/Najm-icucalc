import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/firestore_analytics_datasource.dart';
import 'data/repositories/firestore_analytics_repository_impl.dart';
import 'domain/entities/dashboard_metrics.dart';
import 'domain/repositories/analytics_repository.dart';
import 'domain/usecases/fetch_dashboard_metrics_usecase.dart';

final firestoreAnalyticsDataSourceProvider = Provider<FirestoreAnalyticsDataSource>((ref) {
  return FirestoreAnalyticsDataSource();
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return FirestoreAnalyticsRepositoryImpl(ref.watch(firestoreAnalyticsDataSourceProvider));
});

final fetchDashboardMetricsUseCaseProvider = Provider<FetchDashboardMetricsUseCase>((ref) {
  return FetchDashboardMetricsUseCase(ref.watch(analyticsRepositoryProvider));
});

final dashboardMetricsProvider = FutureProvider.autoDispose<DashboardMetrics>((ref) async {
  final result = await ref.watch(fetchDashboardMetricsUseCaseProvider)();
  return result.when(success: (metrics) => metrics, failure: (failure) => throw failure);
});
