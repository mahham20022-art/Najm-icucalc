import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../viewmodels/auth_view_model.dart';

/// Real Splash screen: runs the one-shot session-restore check
/// (`RestoreSessionUseCase`, via [AuthViewModel.restoreSession]) and
/// routes to Home, Login, or (locked) Login-with-biometric-retry
/// accordingly — this is "continue from where you left off," not a
/// fixed timer before Onboarding.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authViewModelProvider.notifier).restoreSession());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen(authViewModelProvider, (previous, next) {
      switch (next) {
        case AuthAuthenticated():
          context.goNamed(AppRoute.home);
        case AuthUnauthenticated():
        case AuthLocked():
        case AuthError():
          // AuthLocked/AuthError still land on Login: the Login screen
          // itself reads the current AuthViewModel state to decide
          // whether to show the biometric-retry affordance or the error
          // banner, rather than duplicating that branching here.
          context.goNamed(AppRoute.login);
        case AuthInitial():
        case AuthAuthenticating():
          break;
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appName, style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(l10n.tagline, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
