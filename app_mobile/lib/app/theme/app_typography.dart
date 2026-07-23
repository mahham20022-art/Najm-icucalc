import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale from `docs/MED100_DESIGN_SYSTEM.md` §2 — sizes and line
/// heights are fixed; only `color` differs between themes, applied by
/// [AppTypography.textTheme].
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(AppColors colors) {
    final base = TextTheme(
      // Display — Splash tagline, milestone numbers.
      displayLarge: _style(size: 34, height: 41 / 34, weight: FontWeight.bold, tracking: -0.4),
      // Title 1 — screen-level titles.
      headlineLarge: _style(size: 28, height: 34 / 28, weight: FontWeight.bold, tracking: -0.3),
      // Title 2 — section headers, flashcard prompts.
      headlineMedium: _style(size: 22, height: 28 / 22, weight: FontWeight.bold, tracking: -0.2),
      // Title 3 — card titles.
      headlineSmall: _style(size: 20, height: 25 / 20, weight: FontWeight.w600, tracking: -0.1),
      // Headline — button labels, list row titles.
      titleMedium: _style(size: 17, height: 22 / 17, weight: FontWeight.w600, tracking: -0.1),
      // Body — topic body text, question stems.
      bodyLarge: _style(size: 17, height: 22 / 17, weight: FontWeight.normal),
      // Callout — secondary body content.
      bodyMedium: _style(size: 16, height: 21 / 16, weight: FontWeight.normal),
      // Subheadline — metadata rows.
      bodySmall: _style(size: 15, height: 20 / 15, weight: FontWeight.normal),
      // Footnote — timestamps, fine print.
      labelMedium: _style(size: 13, height: 18 / 13, weight: FontWeight.normal),
      // Caption — badges, tags.
      labelSmall: _style(size: 12, height: 16 / 12, weight: FontWeight.normal, tracking: 0.1),
    );

    return base.apply(
      bodyColor: colors.labelPrimary,
      displayColor: colors.labelPrimary,
      decorationColor: colors.labelPrimary,
    );
  }

  static TextStyle _style({
    required double size,
    required double height,
    required FontWeight weight,
    double tracking = 0,
  }) {
    return TextStyle(fontSize: size, height: height, fontWeight: weight, letterSpacing: tracking);
  }
}
