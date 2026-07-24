import 'package:equatable/equatable.dart';

import 'subscription_status.dart';
import 'subscription_tier.dart';

/// Mirrors `MED100_DATABASE_DESIGN.md` §12's `subscription_cache` —
/// deliberately a read-only local mirror of server-computed
/// entitlement, not something this client computes for itself. See
/// `SubscriptionRepositoryImpl`'s doc comment for how far this
/// foundation-stage implementation is from that contract today.
class Subscription extends Equatable {
  const Subscription({
    required this.tier,
    required this.status,
    required this.source,
    required this.currentPeriodEnd,
    required this.autoRenew,
  });

  factory Subscription.free() => const Subscription(
    tier: SubscriptionTier.free,
    status: SubscriptionStatus.active,
    source: SubscriptionSource.promo,
    currentPeriodEnd: null,
    autoRenew: false,
  );

  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final SubscriptionSource source;
  final DateTime? currentPeriodEnd;
  final bool autoRenew;

  /// A device offline through its actual expiry date keeps stale
  /// premium access until the next sync — see this table's doc comment
  /// in `core/database/app_database.dart` for why that's an accepted,
  /// bounded leniency rather than a bug.
  bool get isPremium => tier == SubscriptionTier.premium && status != SubscriptionStatus.expired;

  @override
  List<Object?> get props => [tier, status, source, currentPeriodEnd, autoRenew];
}
