import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Generic stand-in for every screen that has a route wired up but no
/// feature implementation yet. Exists purely so the navigation graph in
/// `app/router/app_router.dart` is real and traversable — per the task
/// this project was scaffolded under ("generate only the project
/// foundation, do not implement features"), the actual screens described
/// in `MED100_UI_UX_SPEC.md` are out of scope here.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.screenName, this.showAppBar = true});

  final String screenName;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).screenNotImplemented(screenName),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    if (!showAppBar) return body;

    return Scaffold(
      appBar: AppBar(title: Text(screenName)),
      body: body,
    );
  }
}
