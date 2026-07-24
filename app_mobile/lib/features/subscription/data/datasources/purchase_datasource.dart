import 'package:in_app_purchase/in_app_purchase.dart';

/// Thin wrapper over `in_app_purchase` — the platform-native purchase
/// flow (StoreKit on iOS, Play Billing on Android). Web/desktop simply
/// report unavailable via [isAvailable], which the repository treats as
/// "no products to show," not an error.
class PurchaseDataSource {
  PurchaseDataSource({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  Stream<List<PurchaseDetails>> get purchaseStream => _inAppPurchase.purchaseStream;

  Future<ProductDetailsResponse> queryProducts(Set<String> productIds) =>
      _inAppPurchase.queryProductDetails(productIds);

  Future<bool> buy(ProductDetails product) =>
      _inAppPurchase.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));

  Future<void> completePurchase(PurchaseDetails purchase) =>
      _inAppPurchase.completePurchase(purchase);

  Future<void> restorePurchases() => _inAppPurchase.restorePurchases();
}
