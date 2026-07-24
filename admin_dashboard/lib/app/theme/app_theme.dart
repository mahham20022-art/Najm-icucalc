import 'package:flutter/material.dart';

/// A single, plain Material theme — this is an internal staff tool, not
/// a branded consumer surface, so it deliberately skips `app_mobile`'s
/// full design-system treatment (custom `AppColors`/`AppSpacing`,
/// light/dark parity tuning) in favor of Flutter's own Material 3
/// defaults seeded from Med100's brand color.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    colorSchemeSeed: const Color(0xFF0A6CFF),
    useMaterial3: true,
    brightness: Brightness.light,
  );

  static ThemeData get dark => ThemeData(
    colorSchemeSeed: const Color(0xFF0A6CFF),
    useMaterial3: true,
    brightness: Brightness.dark,
  );
}
