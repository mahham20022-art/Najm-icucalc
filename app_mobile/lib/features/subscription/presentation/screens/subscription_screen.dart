import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_product.dart';
import '../../subscription_providers.dart';
import '../viewmodels/subscription_action_view_model.dart';
import '../viewmodels/subscription_products_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: subscriptionAsync.when(
        data: (subscription) => subscription.isPremium
            ? _PremiumStatusView(subscription: subscription)
            : const _PaywallView(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _PaywallView(),
      ),
    );
  }
}

class _PremiumStatusView extends StatelessWidget {
  const _PremiumStatusView({required this.subscription});
  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final periodEnd = subscription.currentPeriodEnd;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 48, color: colors.warning),
            const SizedBox(height: AppSpacing.space4),
            Text('You\'re on Premium', style: textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.space2),
            if (subscription.isLifetime)
              Text(
                'Lifetime access',
                style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
              )
            else if (periodEnd != null)
              Text(
                subscription.autoRenew
                    ? 'Renews ${DateFormat.yMMMd().format(periodEnd)}'
                    : 'Expires ${DateFormat.yMMMd().format(periodEnd)}',
                style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
              ),
            if (subscription.isInGracePeriod) ...[
              const SizedBox(height: AppSpacing.space4),
              _GracePeriodBanner(),
            ],
            const SizedBox(height: AppSpacing.space5),
            Text(
              'All specialty tracks, Exam Mode, full adaptive review, and advanced '
              'analytics are unlocked.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Surfaces RevenueCat's grace period distinctly from a plain "Premium"
/// state — access continues while the store retries a failed charge,
/// but the user needs to know *why* so they can fix their payment
/// method before it actually lapses.
class _GracePeriodBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusControlSm),
        border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.warning, size: 20),
          const SizedBox(width: AppSpacing.space2),
          Flexible(
            child: Text(
              "There's a problem with your payment method — update it to keep Premium.",
              style: textTheme.bodySmall?.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaywallView extends ConsumerStatefulWidget {
  const _PaywallView();

  @override
  ConsumerState<_PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends ConsumerState<_PaywallView> {
  BillingPeriod _selected = BillingPeriod.annual;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final productsAsync = ref.watch(subscriptionProductsProvider);
    final actionState = ref.watch(subscriptionActionViewModelProvider);
    final processing = actionState is SubscriptionActionProcessing;

    ref.listen(subscriptionActionViewModelProvider, (previous, next) {
      if (next is SubscriptionActionFailed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.failure.message)));
        ref.read(subscriptionActionViewModelProvider.notifier).dismissError();
      }
    });

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space5),
      children: [
        Icon(Icons.workspace_premium_outlined, size: 44, color: colors.accentFill),
        const SizedBox(height: AppSpacing.space4),
        Text('Med100 Premium', style: textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.space2),
        Text(
          'Unlock every specialty track, Exam Mode, full adaptive spaced '
          'repetition, and advanced analytics.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
        ),
        const SizedBox(height: AppSpacing.space5),
        _FeatureRow(text: 'All specialty tracks'),
        _FeatureRow(text: 'Exam Mode'),
        _FeatureRow(text: 'Full adaptive spaced repetition'),
        _FeatureRow(text: 'Advanced analytics'),
        _FeatureRow(text: 'Offline full library'),
        const SizedBox(height: AppSpacing.space5),
        productsAsync.when(
          data: (products) => _PlanPicker(
            products: products,
            selected: _selected,
            onSelect: (period) => setState(() => _selected = period),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _PlanPicker(
            products: const [],
            selected: _selected,
            onSelect: (period) => setState(() => _selected = period),
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        Builder(
          builder: (context) {
            final selectedProduct = (productsAsync.value ?? const [])
                .where((p) => p.billingPeriod == _selected)
                .firstOrNull;
            return FilledButton(
              // No purchase attempt is ever made against a guessed
              // product id — if the store hasn't returned a real
              // product yet (foundation-stage: no RevenueCat project/
              // App Store Connect/Play Console products configured),
              // the button simply stays disabled rather than pretending
              // to work.
              onPressed: processing || selectedProduct == null
                  ? null
                  : () => ref
                        .read(subscriptionActionViewModelProvider.notifier)
                        .purchase(selectedProduct.productId),
              child: processing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_selected == BillingPeriod.lifetime ? 'Buy Lifetime Access' : 'Subscribe'),
            );
          },
        ),
        if ((productsAsync.value ?? const []).isEmpty) ...[
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Subscriptions aren\'t available yet on this build.',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(color: colors.labelTertiary),
          ),
        ],
        const SizedBox(height: AppSpacing.space3),
        Center(
          child: TextButton(
            onPressed: processing
                ? null
                : () => ref.read(subscriptionActionViewModelProvider.notifier).restore(),
            child: const Text('Restore Purchases'),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: colors.success),
          const SizedBox(width: AppSpacing.space3),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _PlanPicker extends StatelessWidget {
  const _PlanPicker({required this.products, required this.selected, required this.onSelect});

  final List<SubscriptionProduct> products;
  final BillingPeriod selected;
  final ValueChanged<BillingPeriod> onSelect;

  SubscriptionProduct? _productFor(BillingPeriod period) =>
      products.where((p) => p.billingPeriod == period).firstOrNull;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PlanCard(
                label: 'Monthly',
                priceLabel: _productFor(BillingPeriod.monthly)?.priceLabel ?? '~\$9.99/mo',
                selected: selected == BillingPeriod.monthly,
                onTap: () => onSelect(BillingPeriod.monthly),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _PlanCard(
                label: 'Yearly',
                priceLabel: _productFor(BillingPeriod.annual)?.priceLabel ?? '~\$89.99/yr',
                selected: selected == BillingPeriod.annual,
                badge: 'Best Value',
                onTap: () => onSelect(BillingPeriod.annual),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        _PlanCard(
          label: 'Lifetime',
          priceLabel: _productFor(BillingPeriod.lifetime)?.priceLabel ?? '~\$199.99 once',
          selected: selected == BillingPeriod.lifetime,
          badge: 'Pay Once',
          fullWidth: true,
          onTap: () => onSelect(BillingPeriod.lifetime),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
    this.badge,
    this.fullWidth = false,
  });

  final String label;
  final String priceLabel;
  final bool selected;
  final String? badge;
  final bool fullWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 2),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusControlSm),
            ),
            child: Text(
              badge!,
              style: textTheme.labelSmall?.copyWith(
                color: colors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.space2),
        Text(label, style: textTheme.titleMedium),
        Text(priceLabel, style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary)),
      ],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: selected ? colors.accentFill : colors.separator,
            width: selected ? 2 : 1,
          ),
        ),
        child: content,
      ),
    );
  }
}
