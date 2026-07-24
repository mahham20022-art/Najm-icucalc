import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../subscription_providers.dart';

/// Wraps any premium-gated screen: renders [child] once the signed-in
/// user is entitled, otherwise a compact paywall prompt — the technical
/// enforcement point for the PRD's "per-topic entitlement flag, not a
/// track lock" principle (`MED100_PRD.md` §7/§14). [isFree] is the
/// gated resource's own flag (e.g. `Topic.isFree`); this widget never
/// hardcodes which content requires Premium.
class PaywallGate extends ConsumerWidget {
  const PaywallGate({super.key, required this.isFree, required this.child});

  final bool isFree;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isFree) return child;

    final subscriptionAsync = ref.watch(subscriptionProvider);
    final isPremium = subscriptionAsync.value?.isPremium ?? false;
    if (isPremium) return child;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 40, color: AppColors.of(context).warning),
              const SizedBox(height: AppSpacing.space4),
              Text('Premium Content', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.space2),
              Text(
                'This topic is part of Med100 Premium.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.of(context).labelSecondary),
              ),
              const SizedBox(height: AppSpacing.space5),
              FilledButton(
                onPressed: () => context.goNamed(AppRoute.subscription),
                child: const Text('View Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
