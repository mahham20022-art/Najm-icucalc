import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Thin wrapper over `purchases_flutter` (RevenueCat) — the platform
/// purchase flow (StoreKit on iOS, Play Billing on Android) lives behind
/// RevenueCat's SDK rather than being driven directly, so entitlement
/// state is validated server-side by RevenueCat instead of this client
/// optimistically trusting a raw platform purchase callback.
class RevenueCatDataSource {
  Future<void> configure({required String apiKey, String? appUserId}) {
    return Purchases.configure(PurchasesConfiguration(apiKey)..appUserID = appUserId);
  }

  Future<void> logIn(String appUserId) => Purchases.logIn(appUserId);

  Future<void> logOut() => Purchases.logOut();

  Future<bool> get isConfigured => Purchases.isConfigured;

  Future<Offerings> getOfferings() => Purchases.getOfferings();

  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  Future<PurchaseResult> purchasePackage(Package package) =>
      Purchases.purchase(PurchaseParams.package(package));

  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  /// Broadcasts every `CustomerInfo` update RevenueCat pushes — a
  /// purchase completing, a renewal, an entitlement expiring, a grace
  /// period starting or clearing — not just the ones this app's own
  /// `purchase()`/`restorePurchases()` calls trigger directly. Wraps the
  /// SDK's callback-based `addCustomerInfoUpdateListener` in a
  /// broadcast [Stream] so the repository can treat it the same way it
  /// treats any other reactive data source.
  ///
  /// One controller for this datasource's whole lifetime (`late final`,
  /// built lazily on first access) — a getter that instead built a new
  /// `StreamController` on every access would register a brand new
  /// native listener per access too, rather than the single one a
  /// broadcast stream's `onListen`/`onCancel` are meant to manage.
  late final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast(
        onListen: () => Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate),
        onCancel: () => Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdate),
      );

  void _onCustomerInfoUpdate(CustomerInfo info) => _customerInfoController.add(info);

  Stream<CustomerInfo> get customerInfoUpdates => _customerInfoController.stream;

  /// `true` if [error] represents the user backing out of the platform
  /// purchase sheet themselves — never surfaced as a failure banner, per
  /// the same "cancellation isn't an error" treatment used for
  /// Google/Apple sign-in.
  bool isUserCancelled(Object error) {
    if (error is! PlatformException) return false;
    return PurchasesErrorHelper.getErrorCode(error) == PurchasesErrorCode.purchaseCancelledError;
  }
}
