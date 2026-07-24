import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../analytics_providers.dart';
import '../../domain/entities/dashboard_metrics.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardMetricsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: metricsAsync.when(
        data: (metrics) => _AnalyticsBody(metrics: metrics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load metrics: $error')),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.metrics});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                label: 'Total Users',
                value: '${metrics.totalUsers}',
                icon: Icons.people_outline,
              ),
              _StatCard(
                label: 'Premium Users',
                value: '${metrics.premiumUsers}',
                icon: Icons.workspace_premium_outlined,
              ),
              _StatCard(
                label: 'Conversion Rate',
                value: metrics.premiumConversionRate == null
                    ? '—'
                    : '${(metrics.premiumConversionRate! * 100).toStringAsFixed(1)}%',
                icon: Icons.trending_up,
              ),
              _StatCard(
                label: 'Suspended Accounts',
                value: '${metrics.suspendedUsers}',
                icon: Icons.block_outlined,
              ),
              _StatCard(
                label: 'Topics',
                value: '${metrics.totalTopics}',
                icon: Icons.menu_book_outlined,
              ),
              _StatCard(
                label: 'Learning Paths',
                value: '${metrics.totalLearningPaths}',
                icon: Icons.alt_route_outlined,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Free vs. Premium', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: metrics.totalUsers == 0
                ? const Center(child: Text('No users yet.'))
                : Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: metrics.freeUsers.toDouble(),
                                color: Theme.of(context).colorScheme.outline,
                                title: '${metrics.freeUsers}',
                                radius: 60,
                              ),
                              PieChartSectionData(
                                value: metrics.premiumUsers.toDouble(),
                                color: Theme.of(context).colorScheme.primary,
                                title: '${metrics.premiumUsers}',
                                radius: 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendRow(color: Theme.of(context).colorScheme.outline, label: 'Free'),
                          const SizedBox(height: 8),
                          _LegendRow(
                            color: Theme.of(context).colorScheme.primary,
                            label: 'Premium',
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
