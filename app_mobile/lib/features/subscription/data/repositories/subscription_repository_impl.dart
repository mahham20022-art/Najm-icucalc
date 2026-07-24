// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// (`revenueCat`) distinct from their private backing fields
// (`_revenueCat`) for a readable call site — an initializing formal
// would force the parameter name itself to be private.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/session/current_user.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_product.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/revenue_cat_datasource.dart';
import '../datasources/subscription_local_datasource.dart';
import '../subscription_config.dart';

/// **Foundation-stage gap, read before shipping.** Per
/// `MED100_DATABASE_DESIGN.md` §12, `subscription_cache`'s write owner is
/// "exclusively the billing webhook Cloud Function" — a server validates
/// the store receipt and is the only writer of real entitlement.
/// RevenueCat itself *does* do real, server-side receipt validation
/// (that's the whole point of using it instead of talking to
/// StoreKit/Play Billing directly) — the remaining gap is narrower than
/// before: this client trusts RevenueCat's `CustomerInfo` directly
/// rather than this app's own backend re-validating a RevenueCat webhook
/// and writing `subscriptions/{userId}` itself. That backend integration
/// (RevenueCat dashboard → webhook → Cloud Function → Firestore) is
/// still real, separate work; until it exists, this cache mirrors
/// RevenueCat's client SDK, not this app's own server.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required RevenueCatDataSource revenueCat,
    required SubscriptionLocalDataSource localDataSource,
    required CurrentUser currentUser,
  }) : _revenueCat = revenueCat,
       _localDataSource = localDataSource,
       _currentUser = currentUser {
    _customerInfoSubscription = _revenueCat.customerInfoUpdates.listen(_applyCustomerInfo);
    _configured = _initialize();
  }

  final RevenueCatDataSource _revenueCat;
  final SubscriptionLocalDataSource _localDataSource;
  final CurrentUser _currentUser;
  late final StreamSubscription<CustomerInfo> _customerInfoSubscription;

  /// Awaited at the top of every method that calls into RevenueCat
  /// (other than [_applyCustomerInfo], which only ever runs *after* a
  /// real `CustomerInfo` event has arrived from native code — which
  /// itself can't happen until configuration has already succeeded).
  /// Without this, a call landing before `configure()` resolves (e.g.
  /// the paywall screen mounting immediately after app start) would hit
  /// RevenueCat's "not configured" error instead of just waiting the
  /// short real setup time out. [_initialize] never throws, so this is
  /// always safe to await.
  late final Future<void> _configured;

  String get _userId => _currentUser.userId ?? guestScopeId;

  Future<void> _initialize() async {
    try {
      await _revenueCat.configure(
        apiKey: SubscriptionConfig.revenueCatApiKey,
        appUserId: _currentUser.userId,
      );
    } catch (error, stackTrace) {
      // Foundation-stage placeholder API key — same non-fatal treatment
      // as every other placeholder credential in this codebase (see
      // `bootstrap.dart`'s Firebase initialization): the paywall and
      // entitlement cache still build and render, just with nothing
      // purchasable until a real RevenueCat project replaces this key.
      debugPrint(
        'RevenueCat configuration skipped/failed (expected until a real '
        'SDK key replaces the placeholder in SubscriptionConfig): $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Stream<Subscription> watchSubscription() => _localDataSource.watch(_userId);

  @override
  Future<List<SubscriptionProduct>> getAvailableProducts() async {
    await _configured;
    try {
      final offering = (await _revenueCat.getOfferings()).current;
      if (offering == null) return const [];
      return [
        for (final entry in _planSlots(offering))
          if (entry.package != null) _toProduct(entry.package!, entry.plan),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Result<void>> purchase(String productId) async {
    await _configured;
    final Offering? offering;
    try {
      offering = (await _revenueCat.getOfferings()).current;
    } catch (_) {
      return const Result.failure(PurchaseFailure('Purchases are not available right now.'));
    }

    final package = _packageWithIdentifier(offering, productId);
    if (package == null) return const Result.failure(PurchaseFailure());

    try {
      final result = await _revenueCat.purchasePackage(package);
      await _applyCustomerInfo(result.customerInfo);
      return const Result.success(null);
    } catch (error) {
      if (_revenueCat.isUserCancelled(error)) {
        return const Result.failure(PurchaseCancelledFailure());
      }
      return const Result.failure(PurchaseFailure());
    }
  }

  @override
  Future<Result<void>> restorePurchases() async {
    await _configured;
    try {
      final customerInfo = await _revenueCat.restorePurchases();
      await _applyCustomerInfo(customerInfo);
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(RestoreFailure());
    }
  }

  @override
  Future<void> handleSignOut() async {
    await _configured;
    try {
      await _revenueCat.logOut();
    } catch (_) {
      // Nothing actionable for the user — worst case, the next sign-in
      // re-identifies via `configure`'s `appUserId` anyway (see
      // `_initialize`), just without this device's RevenueCat identity
      // having been reset in between.
    }
  }

  Future<void> _applyCustomerInfo(CustomerInfo info) async {
    final entitlement = info.entitlements.active[SubscriptionConfig.entitlementId];
    if (entitlement == null) {
      await _localDataSource.save(_userId, Subscription.free());
      return;
    }

    Offering? offering;
    try {
      offering = (await _revenueCat.getOfferings()).current;
    } catch (_) {
      offering = null;
    }
    final plan = _identifyPlan(offering, entitlement.productIdentifier);

    await _localDataSource.save(
      _userId,
      Subscription(
        tier: SubscriptionTier.premium,
        status: _statusFor(entitlement, plan),
        source: _sourceFor(entitlement.store),
        currentPeriodEnd: entitlement.expirationDate == null
            ? null
            : DateTime.parse(entitlement.expirationDate!),
        autoRenew: entitlement.willRenew,
        activePlan: plan,
      ),
    );
  }

  /// The three plan "slots" this feature supports, paired with
  /// RevenueCat's own typed accessors for each — reused by
  /// [getAvailableProducts] (iterating what's purchasable) and by
  /// [_packageWithIdentifier]/[_identifyPlan] (looking one back up).
  List<({Package? package, BillingPeriod plan})> _planSlots(Offering offering) => [
    (package: offering.monthly, plan: BillingPeriod.monthly),
    (package: offering.annual, plan: BillingPeriod.annual),
    (package: offering.lifetime, plan: BillingPeriod.lifetime),
  ];

  Package? _packageWithIdentifier(Offering? offering, String productId) {
    if (offering == null) return null;
    for (final entry in _planSlots(offering)) {
      if (entry.package?.identifier == productId) return entry.package;
    }
    return null;
  }

  /// [entitlement.productIdentifier] is the underlying *store* product
  /// id (e.g. `med100_premium_monthly`), not the package identifier
  /// (`$rc_monthly`) [purchase]/[getAvailableProducts] deal in — this
  /// cross-references via `Package.storeProduct.identifier` to recover
  /// which of the three plans is actually active.
  BillingPeriod? _identifyPlan(Offering? offering, String storeProductIdentifier) {
    if (offering == null) return null;
    for (final entry in _planSlots(offering)) {
      if (entry.package?.storeProduct.identifier == storeProductIdentifier) return entry.plan;
    }
    return null;
  }

  /// A Lifetime purchase never renews by definition — `willRenew` is
  /// always `false` for it, which would otherwise be misread as
  /// [SubscriptionStatus.cancelled] below, the same trap `willRenew`
  /// sets for any one-time, non-recurring package type.
  SubscriptionStatus _statusFor(EntitlementInfo entitlement, BillingPeriod? plan) {
    if (entitlement.billingIssueDetectedAt != null && entitlement.isActive) {
      return SubscriptionStatus.gracePeriod;
    }
    if (!entitlement.isActive) return SubscriptionStatus.expired;
    if (plan != BillingPeriod.lifetime && !entitlement.willRenew) {
      return SubscriptionStatus.cancelled;
    }
    return SubscriptionStatus.active;
  }

  SubscriptionSource _sourceFor(Store store) => switch (store) {
    Store.appStore || Store.macAppStore => SubscriptionSource.appStore,
    Store.playStore || Store.amazon || Store.galaxy => SubscriptionSource.playStore,
    Store.promotional => SubscriptionSource.promo,
    _ => SubscriptionSource.other,
  };

  SubscriptionProduct _toProduct(Package package, BillingPeriod plan) => SubscriptionProduct(
    productId: package.identifier,
    billingPeriod: plan,
    title: package.storeProduct.title,
    priceLabel: package.storeProduct.priceString,
  );

  /// Not part of [SubscriptionRepository] — called once from
  /// `subscription_providers.dart`'s `ref.onDispose` so the shared
  /// `CustomerInfo` listener doesn't outlive the repository.
  void dispose() {
    _customerInfoSubscription.cancel();
  }
}
