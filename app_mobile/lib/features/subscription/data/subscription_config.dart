/// Static configuration for Subscription & Monetization, now backed by
/// RevenueCat.
///
/// **Not real yet — read before shipping.** [revenueCatApiKey] is a
/// placeholder exactly like `firebase_options.dart`'s placeholder
/// project and `AiEngineConfig`'s API keys: it lets this module's
/// purchase flow, entitlement caching, and paywall UI all be built and
/// exercised now, but `Purchases.configure` will simply fail to reach a
/// real RevenueCat project until this is replaced with a real public
/// SDK key from the RevenueCat dashboard, which itself must have Monthly/
/// Yearly/Lifetime products configured against App Store Connect and the
/// Google Play Console. Per `MED100_DATABASE_DESIGN.md` §12, the *real*
/// entitlement write path is a server-side billing webhook (RevenueCat's
/// own, in this design) — this client only ever mirrors RevenueCat's
/// client-side `CustomerInfo` locally (see `SubscriptionRepositoryImpl`'s
/// doc comment) until that backend integration exists.
abstract final class SubscriptionConfig {
  static const revenueCatApiKey = 'REPLACE_WITH_REVENUECAT_PUBLIC_SDK_KEY';

  /// The entitlement identifier configured in the RevenueCat dashboard
  /// that all three paid plans below unlock — a single entitlement
  /// rather than one per plan, since Monthly/Yearly/Lifetime all grant
  /// the exact same Premium access, just via different purchase types.
  static const entitlementId = 'premium';

  /// RevenueCat's predefined package identifiers — set by choosing the
  /// corresponding package type (Monthly/Annual/Lifetime) when attaching
  /// a product to an Offering in the dashboard, not something this app
  /// invents. `Offering.monthly`/`.annual`/`.lifetime` are the typed
  /// accessors this feature reads instead of string-matching these
  /// directly, but they're documented here for reference.
  static const monthlyPackageId = r'$rc_monthly';
  static const annualPackageId = r'$rc_annual';
  static const lifetimePackageId = r'$rc_lifetime';
}
