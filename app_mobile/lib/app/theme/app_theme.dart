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

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.accentFill,
      onPrimary: Colors.white,
      secondary: colors.accentForeground,
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
      textTheme: AppTypography.textTheme(colors),
      extensions: [AppColorsThemeExtension(colors)],
      splashFactory: InkSparkle.splashFactory,
      cardTheme: CardThemeData(
        color: colors.surfaceElevated,
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.08),
        shape: cardShape,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceElevated,
        shape: cardShape,
        elevation: isDark ? 0 : 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceElevated,
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
