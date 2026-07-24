// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// (`purchaseDataSource`) distinct from their private backing fields
// (`_purchaseDataSource`) for a readable call site — an initializing
// formal would force the parameter name itself to be private.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/session/current_user.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_product.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/purchase_datasource.dart';
import '../datasources/subscription_local_datasource.dart';
import '../subscription_config.dart';

/// **Foundation-stage gap, read before shipping.** Per
/// `MED100_DATABASE_DESIGN.md` §12, `subscription_cache`'s write owner is
/// "exclusively the billing webhook Cloud Function" — a server validates
/// the store receipt and is the only writer of real entitlement. This
/// implementation has no such backend to call, so [_applyEntitlement]
/// optimistically grants premium locally the moment the *platform*
/// reports a purchase, without any server-side receipt verification.
/// That's fine for exercising the purchase flow and paywall UI now, but
/// it means a jailbroken/rooted device could forge entitlement — the
/// same class of gap as `AiEngineConfig`'s client-embedded API keys, and
/// it needs the same fix: a Cloud Function that verifies the receipt
/// (via App Store Server API / Google Play Developer API) and writes
/// the real `subscriptions/{userId}` document, with this cache becoming
/// a genuine read-only mirror of that instead of the source of truth.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required PurchaseDataSource purchaseDataSource,
    required SubscriptionLocalDataSource localDataSource,
    required CurrentUser currentUser,
  }) : _purchaseDataSource = purchaseDataSource,
       _localDataSource = localDataSource,
       _currentUser = currentUser {
    _purchaseSubscription = _purchaseDataSource.purchaseStream.listen(_onPurchaseUpdates);
  }

  final PurchaseDataSource _purchaseDataSource;
  final SubscriptionLocalDataSource _localDataSource;
  final CurrentUser _currentUser;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  /// Keyed by product id — lets a pending [purchase] call resolve once
  /// the matching event arrives on the shared platform purchase stream,
  /// since `buyNonConsumable` itself only reports whether the purchase
  /// *sheet* was launched, not whether the purchase succeeded.
  final Map<String, Completer<Result<void>>> _pendingPurchases = {};

  String get _userId => _currentUser.userId ?? guestScopeId;

  @override
  Stream<Subscription> watchSubscription() => _localDataSource.watch(_userId);

  @override
  Future<List<SubscriptionProduct>> getAvailableProducts() async {
    if (!await _purchaseDataSource.isAvailable()) return const [];
    final response = await _purchaseDataSource.queryProducts(SubscriptionConfig.productIds);
    return response.productDetails.map(_toProduct).toList();
  }

  @override
  Future<Result<void>> purchase(String productId) async {
    if (!await _purchaseDataSource.isAvailable()) {
      return const Result.failure(PurchaseFailure('Purchases are not available on this device.'));
    }

    final response = await _purchaseDataSource.queryProducts({productId});
    if (response.productDetails.isEmpty) {
      return const Result.failure(PurchaseFailure());
    }

    final completer = Completer<Result<void>>();
    _pendingPurchases[productId] = completer;

    final started = await _purchaseDataSource.buy(response.productDetails.first);
    if (!started) {
      _pendingPurchases.remove(productId);
      return const Result.failure(PurchaseFailure());
    }

    return completer.future;
  }

  @override
  Future<Result<void>> restorePurchases() async {
    if (!await _purchaseDataSource.isAvailable()) {
      return const Result.failure(RestoreFailure());
    }
    try {
      // Any restored purchase lands through the same shared stream
      // `_onPurchaseUpdates` already listens to — this call only
      // confirms the restore request was issued, not that anything was
      // found, since the platform APIs don't report that distinction.
      await _purchaseDataSource.restorePurchases();
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(RestoreFailure());
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          _pendingPurchases
              .remove(purchase.productID)
              ?.complete(const Result.failure(PurchaseFailure()));
        case PurchaseStatus.canceled:
          _pendingPurchases
              .remove(purchase.productID)
              ?.complete(const Result.failure(PurchaseCancelledFailure()));
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _applyEntitlement(purchase.productID);
          _pendingPurchases.remove(purchase.productID)?.complete(const Result.success(null));
      }
      if (purchase.pendingCompletePurchase) {
        await _purchaseDataSource.completePurchase(purchase);
      }
    }
  }

  Future<void> _applyEntitlement(String productId) async {
    final periodLength = productId == SubscriptionConfig.annualProductId
        ? const Duration(days: 365)
        : const Duration(days: 30);
    final subscription = Subscription(
      tier: SubscriptionTier.premium,
      status: SubscriptionStatus.active,
      source: defaultTargetPlatform == TargetPlatform.iOS
          ? SubscriptionSource.appStore
          : SubscriptionSource.playStore,
      currentPeriodEnd: DateTime.now().add(periodLength),
      autoRenew: true,
    );
    await _localDataSource.save(_userId, subscription);
  }

  SubscriptionProduct _toProduct(ProductDetails details) {
    final isAnnual = details.id == SubscriptionConfig.annualProductId;
    return SubscriptionProduct(
      productId: details.id,
      billingPeriod: isAnnual ? BillingPeriod.annual : BillingPeriod.monthly,
      title: details.title,
      priceLabel: details.price,
    );
  }

  /// Not part of [SubscriptionRepository] — called once from
  /// `subscription_providers.dart`'s `ref.onDispose` so the shared
  /// purchase-stream listener doesn't outlive the repository.
  void dispose() {
    _purchaseSubscription.cancel();
  }
}
