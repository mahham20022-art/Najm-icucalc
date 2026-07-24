import 'package:flutter/widgets.dart';

/// Whether the platform's Reduce Motion / disable-animations
/// accessibility setting is active. `app_theme.dart`'s page-transition
/// doc comment previously claimed this was "honored globally" when
/// nothing in the codebase actually checked it — this is the real,
/// shared check point every decorative [AnimationController] now reads
/// before playing, per `MED100_DESIGN_SYSTEM.md` §18.
bool prefersReducedMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);
