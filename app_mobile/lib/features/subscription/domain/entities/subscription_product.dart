import 'package:equatable/equatable.dart';

enum BillingPeriod { monthly, annual }

/// A purchasable plan, as returned by the platform store — `priceLabel`
/// is the store's own formatted, localized price string (e.g. `"$9.99"`),
/// never something this app formats itself, since currency/locale
/// formatting for real money is exactly the kind of thing the platform
/// already gets right.
class SubscriptionProduct extends Equatable {
  const SubscriptionProduct({
    required this.productId,
    required this.billingPeriod,
    required this.title,
    required this.priceLabel,
  });

  final String productId;
  final BillingPeriod billingPeriod;
  final String title;
  final String priceLabel;

  @override
  List<Object?> get props => [productId, billingPeriod, title, priceLabel];
}
