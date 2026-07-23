import 'package:flutter/widgets.dart';

/// Width breakpoints matching `MED100_UI_UX_SPEC.md` §21 (Tablet Layout).
///
/// Deliberately hand-rolled against [MediaQuery] rather than pulling in a
/// screen-size package — three breakpoints is a small, stable surface
/// that doesn't need a dependency.
enum ScreenSize { compact, medium, expanded }

class Breakpoints {
  const Breakpoints._();

  /// Below this, the app is phone-style single-column regardless of the
  /// physical device (this is also the fallback used in a narrow
  /// split-view/multi-window pane, per §21).
  static const double compactMax = 600;

  /// Between [compactMax] and this, tablet layouts apply but with
  /// tighter margins (`space-5`, per `MED100_DESIGN_SYSTEM.md` §3).
  static const double mediumMax = 1024;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactMax) return ScreenSize.compact;
    if (width < mediumMax) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  static bool isTablet(BuildContext context) => of(context) != ScreenSize.compact;
}
