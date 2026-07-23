import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../l10n/app_localizations.dart';

/// Shown when GoRouter can't match a location — a malformed or stale
/// deep link (from a push notification, a universal link, a bookmark to
/// an old path) is an expected occurrence at scale, not a developer-only
/// edge case, so this replaces GoRouter's generic/unbranded default error
/// page with something themed and recoverable, per the Error States
/// principles in `MED100_UI_UX_SPEC.md` §19.
class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_off_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.routeNotFoundMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.goNamed(AppRoute.home),
                  child: Text(l10n.goToHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
