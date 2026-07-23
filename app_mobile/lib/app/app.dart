import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget. Deliberately thin — theme assembly lives in `app/theme`,
/// routing in `app/router`, and provider wiring in `app/bootstrap`; this
/// file only composes them, per Clean Architecture's dependency-direction
/// rule (`MED100_ARCHITECTURE.md` §3).
class Med100App extends ConsumerWidget {
  const Med100App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Med100',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Follows the OS setting by default; an explicit override is a
      // Settings-screen concern (MED100_UI_UX_SPEC.md §11) layered on top
      // of this once that feature exists — not hardcoded here.
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // No `locale:` override — Flutter resolves the device locale against
      // `supportedLocales` and derives text direction (LTR for English,
      // RTL for Arabic) from it automatically; RTL is a consequence of
      // locale support, not a separate setting to wire up.
    );
  }
}
