/// Static configuration for Subscription & Monetization.
///
/// **Not real yet — read before shipping.** These product ids are
/// placeholders exactly like `firebase_options.dart`'s placeholder
/// project and `AiEngineConfig`'s API keys: they let this module's
/// purchase flow, entitlement caching, and paywall UI all be built and
/// exercised now, but `InAppPurchase.queryProductDetails` will return
/// them as "not found" until real subscription products with these
/// exact ids are created in App Store Connect and the Google Play
/// Console. Per `MED100_DATABASE_DESIGN.md` §12, the *real* entitlement
/// write path is a server-side billing webhook validating the store
/// receipt — this client only ever optimistically mirrors that locally
/// (see `SubscriptionRepositoryImpl`'s doc comment) until that backend
/// exists.
abstract final class SubscriptionConfig {
  static const monthlyProductId = 'med100_premium_monthly';
  static const annualProductId = 'med100_premium_annual';

  static const productIds = {monthlyProductId, annualProductId};
}
