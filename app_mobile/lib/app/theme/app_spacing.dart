/// Spacing tokens from `docs/MED100_DESIGN_SYSTEM.md` §3 (8pt grid, 4pt
/// for micro-gaps). Referenced as `AppSpacing.space4` etc. rather than
/// a raw number, so a future grid change is a one-file edit.
class AppSpacing {
  const AppSpacing._();

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;
  static const double space8 = 64;

  /// Corner radius tokens, `docs/MED100_DESIGN_SYSTEM.md` §14.
  static const double radiusControlSm = 8;
  static const double radiusControlMd = 12;
  static const double radiusCard = 16;
  static const double radiusSheetTop = 20;
}
