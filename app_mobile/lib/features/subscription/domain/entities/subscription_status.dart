/// Mirrors `MED100_DATABASE_DESIGN.md` §12's `subscriptions/{userId}.status`.
///
/// [gracePeriod] is RevenueCat's billing-issue-retry window
/// (`EntitlementInfo.billingIssueDetectedAt` non-null while `isActive` is
/// still true) — the user keeps Premium access while the store retries a
/// failed charge, per Apple/Google's own grace-period mechanics, so this
/// is deliberately distinct from [expired] and [cancelled].
enum SubscriptionStatus { active, expired, cancelled, gracePeriod }

/// Mirrors `MED100_DATABASE_DESIGN.md` §12's `subscriptions/{userId}.source`
/// — mapped from RevenueCat's own `Store` enum
/// (`EntitlementInfo.store`/`CustomerInfo`), rather than this codebase
/// inventing its own store vocabulary.
enum SubscriptionSource {
  appStore,
  playStore,
  promo,

  /// A manually-granted entitlement (e.g. an institutional/school
  /// partnership) rather than a real store purchase.
  institutionalGrant,

  /// Any RevenueCat `Store` value that doesn't map cleanly to one of the
  /// above (Stripe, RC Billing, Paddle, Amazon, Galaxy, an external
  /// store, RevenueCat's test store, or an unrecognized future value) —
  /// a catch-all rather than silently mislabeling it as one of the
  /// specific buckets above.
  other,
}
