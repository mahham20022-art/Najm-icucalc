/// Mirrors `MED100_DATABASE_DESIGN.md` §12's `subscriptions/{userId}.status`.
enum SubscriptionStatus { active, expired, cancelled, gracePeriod }

/// Mirrors the same document's `source` — renamed from the docs'
/// `revenuecat | stripe | promo | institutional_grant` to reflect this
/// codebase's actual implementation against each platform's native
/// store directly (`in_app_purchase`), not a RevenueCat/Stripe SDK.
enum SubscriptionSource { appStore, playStore, promo, institutionalGrant }
