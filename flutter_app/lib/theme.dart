import 'package:flutter/material.dart';

/// Dark ICU theme — matches the web version's palette.
class AppColors {
  static const bg = Color(0xFF07101F);
  static const panel = Color(0xFF0F1B30);
  static const panel2 = Color(0xFF122340);
  static const panel3 = Color(0xFF0B162A);
  static const border = Color(0xFF1F2F4D);
  static const border2 = Color(0xFF2B4675);
  static const text = Color(0xFFE5EDF8);
  static const muted = Color(0xFF8AA0BD);
  static const brand = Color(0xFF0EA5E9);
  static const brand2 = Color(0xFF38BDF8);
  static const accent = Color(0xFF22D3EE);
  static const ok = Color(0xFF34D399);
  static const warn = Color(0xFFFBBF24);
  static const danger = Color(0xFFEF4444);
  static const pulse = Color(0xFFF43F5E);
}

enum Verdict { info, ok, warn, bad }

extension VerdictColors on Verdict {
  Color get color {
    switch (this) {
      case Verdict.ok:   return AppColors.ok;
      case Verdict.warn: return AppColors.warn;
      case Verdict.bad:  return AppColors.danger;
      case Verdict.info: return AppColors.brand2;
    }
  }
  Color get bg {
    return color.withOpacity(0.10);
  }
  Color get border {
    return color.withOpacity(0.30);
  }
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.brand,
    onPrimary: Color(0xFF001018),
    secondary: AppColors.accent,
    onSecondary: Color(0xFF001018),
    surface: AppColors.panel,
    onSurface: AppColors.text,
    error: AppColors.danger,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'System',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xB307101F),
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.panel,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.panel3,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.brand, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: AppColors.muted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.panel,
      indicatorColor: AppColors.brand.withOpacity(0.2),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: const Color(0xFF001018),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.brand2),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
  );
}
