import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription_product.dart';
import '../../subscription_providers.dart';

/// The store's real products for this platform — empty until real App
/// Store Connect/Play Console products exist (see
/// `SubscriptionConfig`'s doc comment). The paywall screen falls back to
/// an illustrative, non-purchasable price display when this is empty,
/// rather than showing a bare error for what's an expected
/// foundation-stage state.
final subscriptionProductsProvider = FutureProvider<List<SubscriptionProduct>>((ref) {
  return ref.watch(getAvailableProductsUseCaseProvider)();
});
