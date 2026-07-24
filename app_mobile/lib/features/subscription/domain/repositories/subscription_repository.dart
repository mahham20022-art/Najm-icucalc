import '../../../../core/error/result.dart';
import '../entities/subscription.dart';
import '../entities/subscription_product.dart';

abstract interface class SubscriptionRepository {
  Stream<Subscription> watchSubscription();

  /// The store's actual products for this platform — empty if the store
  /// is unreachable or nothing is configured yet (see
  /// `SubscriptionConfig`'s doc comment).
  Future<List<SubscriptionProduct>> getAvailableProducts();

  Future<Result<void>> purchase(String productId);

  Future<Result<void>> restorePurchases();
}
