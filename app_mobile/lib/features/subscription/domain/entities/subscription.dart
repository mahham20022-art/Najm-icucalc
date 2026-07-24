import 'package:equatable/equatable.dart';

import 'subscription_product.dart';
import 'subscription_status.dart';
import 'subscription_tier.dart';

/// Mirrors `MED100_DATABASE_DESIGN.md` §12's `subscription_cache` —
/// deliberately a read-only local mirror of server-computed
/// entitlement, not something this client computes for itself. See
/// `SubscriptionRepositoryImpl`'s doc comment for how this foundation-stage
/// implementation (RevenueCat's client SDK, no server-side webhook yet)
/// stands in for that contract today.
class Subscription extends Equatable {
  const Subscription({
    required this.tier,
    required this.status,
    required this.source,
    required this.currentPeriodEnd,
    required this.autoRenew,
    required this.activePlan,
  });

  factory Subscription.free() => const Subscription(
    tier: SubscriptionTier.free,
    status: SubscriptionStatus.active,
    source: SubscriptionSource.promo,
    currentPeriodEnd: null,
    autoRenew: false,
    activePlan: null,
  );

  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final SubscriptionSource source;
  final DateTime? currentPeriodEnd;
  final bool autoRenew;

  /// `null` for the free tier; `BillingPeriod.lifetime` never has a
  /// [currentPeriodEnd] — that's the signal the UI uses to show
  /// "Lifetime access" rather than an expiry/renewal date.
  final BillingPeriod? activePlan;

  /// A device offline through its actual expiry date keeps stale
  /// premium access until the next sync — see this table's doc comment
  /// in `core/database/app_database.dart` for why that's an accepted,
  /// bounded leniency rather than a bug.
  ///
  /// [SubscriptionStatus.gracePeriod] counts as premium deliberately —
  /// that's the entire point of a grace period: access continues while
  /// the store retries a failed charge.
  bool get isPremium => tier == SubscriptionTier.premium && status != SubscriptionStatus.expired;

  bool get isLifetime => activePlan == BillingPeriod.lifetime;

  bool get isInGracePeriod => status == SubscriptionStatus.gracePeriod;

  @override
  List<Object?> get props => [tier, status, source, currentPeriodEnd, autoRenew, activePlan];
}
