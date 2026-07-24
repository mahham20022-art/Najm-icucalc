import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_product.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/entities/subscription_tier.dart';

/// Owns all Drift access for `SubscriptionCache`.
class SubscriptionLocalDataSource {
  SubscriptionLocalDataSource(this._db);
  final AppDatabase _db;

  Stream<Subscription> watch(String userId) {
    final query = _db.select(_db.subscriptionCache)..where((t) => t.userId.equals(userId));
    return query.watchSingleOrNull().map((row) => _toEntity(row) ?? Subscription.free());
  }

  Future<void> save(String userId, Subscription subscription) async {
    await _db
        .into(_db.subscriptionCache)
        .insertOnConflictUpdate(
          SubscriptionCacheCompanion(
            userId: Value(userId),
            tier: Value(subscription.tier.name),
            status: Value(subscription.status.name),
            currentPeriodEnd: Value(subscription.currentPeriodEnd),
            autoRenew: Value(subscription.autoRenew),
            source: Value(subscription.source.name),
            activePlan: Value(subscription.activePlan?.name),
            lastSyncedAt: Value(DateTime.now()),
          ),
        );
  }

  Subscription? _toEntity(SubscriptionCacheData? row) {
    if (row == null) return null;
    return Subscription(
      tier: SubscriptionTier.values.byName(row.tier),
      status: SubscriptionStatus.values.byName(row.status),
      source: SubscriptionSource.values.byName(row.source),
      currentPeriodEnd: row.currentPeriodEnd,
      autoRenew: row.autoRenew,
      activePlan: row.activePlan == null ? null : BillingPeriod.values.byName(row.activePlan!),
    );
  }
}
