import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A tappable action rendered on a [PlaceholderScreen] — used to wire up
/// real navigation between placeholder pages (e.g. Login → Register)
/// without any business logic behind the tap.
class PlaceholderAction {
  const PlaceholderAction({required this.label, required this.onPressed, this.emphasized = true});

  final String label;
  final VoidCallback onPressed;

  /// First/primary action renders as a filled button; secondary actions
  /// (e.g. "Already have an account?") render as a text link — matches
  /// the Primary/Tertiary button hierarchy from `MED100_DESIGN_SYSTEM.md`
  /// §5, without pulling in the full button variant set for what is
  /// still just a placeholder.
  final bool emphasized;
}

/// Generic stand-in for every screen that has a route wired up but no
/// feature implementation yet. Exists purely so the navigation graph in
/// `app/router/app_router.dart` is real and traversable — per the task
/// this project was scaffolded under ("generate only the project
/// foundation, do not implement features"), the actual screens described
/// in `MED100_UI_UX_SPEC.md` are out of scope here. [actions] lets a
/// placeholder still participate in real navigation (tapping "Continue"
/// on Splash, "Register" on Login, etc.) while adding zero business
/// logic — every callback is just a `context.goNamed(...)` call.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.screenName,
    this.showAppBar = true,
    this.actions = const [],
  });

  final String screenName;
  final bool showAppBar;
  final List<PlaceholderAction> actions;

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
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final action in actions)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: action.emphasized
                              ? ElevatedButton(
                                  onPressed: action.onPressed,
                                  child: Text(action.label),
                                )
                              : TextButton(onPressed: action.onPressed, child: Text(action.label)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
