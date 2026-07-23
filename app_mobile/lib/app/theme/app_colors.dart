import 'package:flutter/material.dart';

/// Semantic color tokens, values taken directly from
/// `docs/MED100_DESIGN_SYSTEM.md` §1 — every contrast ratio there was
/// computed against these exact hex values, so changing a value here
/// invalidates that verification and must be re-checked against §1.2.
///
/// Deliberately two static value sets ([light]/[dark]) behind the same
/// field names, per the design system's governing rule: nothing in the
/// app may reference a literal color, only `AppColors.of(context).accentFill`
/// etc.
@immutable
class AppColors {
  const AppColors({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.surfaceElevated,
    required this.labelPrimary,
    required this.labelSecondary,
    required this.labelTertiary,
    required this.accentForeground,
    required this.accentFill,
    required this.success,
    required this.warning,
    required this.danger,
    required this.separator,
  });

  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color surfaceElevated;
  final Color labelPrimary;
  final Color labelSecondary;
  final Color labelTertiary;

  /// Links, active icons, accent text directly on the background.
  /// Theme-dependent — see `MED100_DESIGN_SYSTEM.md` §1.3.
  final Color accentForeground;

  /// Button/control fill backgrounds. Constant across both themes,
  /// deliberately *not* the same value as [accentForeground] in dark
  /// mode — see `MED100_DESIGN_SYSTEM.md` §1.3 for why a single accent
  /// value can't serve both roles.
  final Color accentFill;

  final Color success;
  final Color warning;
  final Color danger;
  final Color separator;

  static const light = AppColors(
    backgroundPrimary: Color(0xFFFFFFFF),
    backgroundSecondary: Color(0xFFF5F6F8),
    surfaceElevated: Color(0xFFFFFFFF),
    labelPrimary: Color(0xFF0F1419),
    labelSecondary: Color(0xFF5B6470),
    labelTertiary: Color(0xFF9AA3AF),
    accentForeground: Color(0xFF0A6CFF),
    accentFill: Color(0xFF0A6CFF),
    success: Color(0xFF1FAA59),
    warning: Color(0xFFB8790A),
    danger: Color(0xFFE5484D),
    separator: Color(0xFFE3E6EA),
  );

  static const dark = AppColors(
    backgroundPrimary: Color(0xFF0B0D10),
    backgroundSecondary: Color(0xFF121417),
    surfaceElevated: Color(0xFF1C1F24),
    labelPrimary: Color(0xFFF2F4F6),
    labelSecondary: Color(0xFFA7AFB9),
    labelTertiary: Color(0xFF6E7681),
    accentForeground: Color(0xFF4C93FF),
    accentFill: Color(0xFF0A6CFF),
    success: Color(0xFF34C77B),
    warning: Color(0xFFF0B94D),
    danger: Color(0xFFEB6469),
    separator: Color(0xFF2A2E35),
  );

  /// `surface/elevated`'s hairline border in Dark Mode — elevation is
  /// communicated by fill + border, never shadow, per
  /// `MED100_DESIGN_SYSTEM.md` §13.
  static const darkElevatedBorder = Color(0xFF2A2E35);

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColorsThemeExtension>()!.colors;
}

/// Wraps [AppColors] as a [ThemeExtension] so `Theme.of(context)` is the
/// single source of truth an app-wide `AppColors.of(context)` reads from,
/// instead of a global light/dark check scattered through the widget tree.
@immutable
class AppColorsThemeExtension extends ThemeExtension<AppColorsThemeExtension> {
  const AppColorsThemeExtension(this.colors);

  final AppColors colors;

  @override
  AppColorsThemeExtension copyWith({AppColors? colors}) =>
      AppColorsThemeExtension(colors ?? this.colors);

  @override
  AppColorsThemeExtension lerp(ThemeExtension<AppColorsThemeExtension>? other, double t) {
    // Colors are looked up discretely per theme, not animated between
    // Light/Dark — an instant switch matches every other native app's
    // theme-toggle behavior and avoids muddy in-between hues.
    if (other is! AppColorsThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}
