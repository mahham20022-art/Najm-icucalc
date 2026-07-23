import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Assembles Material 3 [ThemeData] from the token files in this folder.
/// This is the only place a `ColorScheme`/`ThemeData` is constructed —
/// screens and widgets read colors via `AppColors.of(context)` /
/// `Theme.of(context).textTheme`, never by building their own.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = AppTypography.textTheme(colors);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.accentFill,
      onPrimary: Colors.white,
      // Deliberately `accentFill`, not `accentForeground`: any Material 3
      // component that defaults to `secondary`+`onSecondary` as a filled
      // background (some Chip/Switch/NavigationDrawer states) would
      // otherwise pair white text against the brighter dark-mode
      // `accentForeground` value, which measures only 3.0:1 — the exact
      // low-contrast pairing `accentFill` exists to avoid
      // (`MED100_DESIGN_SYSTEM.md` §1.3). `secondary` must stay fill-safe.
      secondary: colors.accentFill,
      onSecondary: Colors.white,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.backgroundPrimary,
      onSurface: colors.labelPrimary,
      surfaceContainerHighest: colors.backgroundSecondary,
      onSurfaceVariant: colors.labelSecondary,
      outline: colors.separator,
    );

    // Dark Mode elevation is fill + hairline border, never a shadow — a
    // shadow rendered against near-black is nearly invisible
    // (`MED100_DESIGN_SYSTEM.md` §13). Light Mode keeps a soft shadow.
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      side: isDark ? BorderSide(color: AppColors.darkElevatedBorder) : BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.backgroundPrimary,
      textTheme: textTheme,
      extensions: [AppColorsThemeExtension(colors)],
      // No custom `splashFactory` override: forcing Android's InkSparkle
      // ripple on every platform (including iOS/web) would contradict the
      // iOS-native quality bar `MED100_UI_UX_SPEC.md` is held to — each
      // platform's natural default ink response is the correct choice.
      appBarTheme: AppBarThemeData(
        backgroundColor: colors.backgroundPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colors.labelPrimary,
        // Nav Bar titles use the Headline style (`titleMedium` in this
        // scale), per `MED100_DESIGN_SYSTEM.md` §10 — without this
        // override every AppBar falls back to Material 3's default
        // `titleLarge`, which doesn't match the design system anywhere
        // it's actually rendered (every pushed screen has one).
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceElevated,
        // `surfaceTintColor` defaults to `colorScheme.primary` in
        // Material 3, which would silently wash a translucent tint over
        // every elevated surface — quietly drifting the *rendered* color
        // away from the exact hex values `MED100_DESIGN_SYSTEM.md` §1.2
        // computed contrast ratios against. Suppressed everywhere an
        // elevated surface is themed below.
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.08),
        shape: cardShape,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
        elevation: isDark ? 0 : 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 8,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheetTop),
          ),
          side: isDark ? BorderSide(color: AppColors.darkElevatedBorder) : BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accentFill,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControlMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.accentForeground,
          side: BorderSide(color: colors.accentForeground, width: 1.5),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControlMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accentForeground,
          minimumSize: const Size(44, 44),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.backgroundPrimary,
        indicatorColor: colors.accentForeground.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.backgroundPrimary,
        selectedIconTheme: IconThemeData(color: colors.accentForeground),
        unselectedIconTheme: IconThemeData(color: colors.labelSecondary),
      ),
      dividerTheme: DividerThemeData(color: colors.separator, space: 1, thickness: 1),
      // Reduce Motion is honored globally via `MediaQuery.disableAnimations`
      // — see `app/app.dart` for the page-transition builder that checks it,
      // per `MED100_DESIGN_SYSTEM.md` §18.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
