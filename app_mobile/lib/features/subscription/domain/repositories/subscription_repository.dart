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

  /// Resets RevenueCat's local identity back to a fresh anonymous user —
  /// called when Med100 itself signs the user out, so a shared device
  /// signing in as a different account afterwards doesn't inherit the
  /// previous user's RevenueCat identity/entitlement cache. Fire-and-
  /// forget from the caller's perspective: nothing actionable for the
  /// user if this fails, so it never surfaces a [Result].
  Future<void> handleSignOut();
}
