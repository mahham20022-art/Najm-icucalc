import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth_onboarding/presentation/screens/login_screen.dart';
import '../../features/auth_onboarding/presentation/screens/profile_screen.dart';
import '../../features/auth_onboarding/presentation/screens/register_screen.dart';
import '../../features/auth_onboarding/presentation/screens/splash_screen.dart';
import '../../features/auth_onboarding/presentation/viewmodels/auth_view_model.dart';
import '../../features/challenge_mode/presentation/screens/challenge_bookmarks_screen.dart';
import '../../features/challenge_mode/presentation/screens/challenge_home_screen.dart';
import '../../features/challenge_mode/presentation/screens/challenge_statistics_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/placeholder_screen.dart';
import '../../shared/widgets/route_error_screen.dart';
import '../notifications/reminder_lifecycle_gate.dart';

/// Route names as constants — screens navigate by name
/// (`context.goNamed(AppRoute.home)`), never by hand-built path strings,
/// so a path change is a one-line edit here rather than a find-and-replace
/// across the app.
abstract final class AppRoute {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const register = 'register';
  static const home = 'home';
  static const topics = 'topics';
  static const bookmarks = 'bookmarks';
  static const progress = 'progress';
  static const profile = 'profile';
  static const topic = 'topic'; // Today's Topic / Learning Screen (MED100_UI_UX_SPEC.md §5-6)
  static const statistics = 'statistics';
  static const settings = 'settings';
  static const teachingMode = 'teaching-mode';
  static const subscription = 'subscription';
  static const mcqs = 'mcqs';
  static const flashcards = 'flashcards';
}

/// Locations reachable without a fully authenticated session — Splash
/// (it decides where everyone else goes), Onboarding, Login, Register.
const _publicLocations = {'/splash', '/onboarding', '/login', '/register'};

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    // Gates every shell route (Home, Topics, Progress, Bookmarks,
    // Profile and anything nested under them) behind a fully
    // authenticated session — `AuthLocked` (biometric gate not yet
    // passed) does *not* count, same as fully signed out. Splash is
    // exempt: it's the one place that runs the check and decides where
    // to send everyone else, so redirecting away from it before it's
    // had a chance to run would create a redirect loop.
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location == '/splash') return null;

      final authState = ref.read(authViewModelProvider);
      final isAuthenticated = authState is AuthAuthenticated;
      final isPublicLocation = _publicLocations.contains(location);

      if (!isAuthenticated && !isPublicLocation) return '/login';
      if (isAuthenticated && isPublicLocation) return '/home';
      return null;
    },
    // A malformed/stale deep link (push notification, universal link) is
    // an expected occurrence at scale, not a developer-only concern — see
    // `shared/widgets/route_error_screen.dart`.
    errorBuilder: (context, state) => const RouteErrorScreen(),
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding,
        builder: (context, state) => PlaceholderScreen(
          screenName: 'Onboarding',
          showAppBar: false,
          actions: [
            PlaceholderAction(
              label: AppLocalizations.of(context).continueLabel,
              onPressed: () => context.goNamed(AppRoute.login),
            ),
          ],
        ),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ReminderLifecycleGate(child: AppShell(navigationShell: navigationShell)),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home,
                builder: (context, state) => const ChallengeHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/topics',
                name: AppRoute.topics,
                builder: (context, state) => const PlaceholderScreen(screenName: 'Topics'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                name: AppRoute.progress,
                builder: (context, state) => const PlaceholderScreen(screenName: 'Progress'),
                routes: [
                  GoRoute(
                    path: 'statistics',
                    name: AppRoute.statistics,
                    builder: (context, state) => const ChallengeStatisticsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookmarks',
                name: AppRoute.bookmarks,
                builder: (context, state) => const ChallengeBookmarksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: AppRoute.settings,
                    builder: (context, state) => const PlaceholderScreen(screenName: 'Settings'),
                  ),
                  GoRoute(
                    path: 'subscription',
                    name: AppRoute.subscription,
                    builder: (context, state) =>
                        const PlaceholderScreen(screenName: 'Subscription'),
                  ),
                  GoRoute(
                    path: 'teaching-mode',
                    name: AppRoute.teachingMode,
                    builder: (context, state) =>
                        const PlaceholderScreen(screenName: 'Teaching Mode', showAppBar: false),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Today's Topic and the generic Learning Screen share one component
      // family (MED100_UI_UX_SPEC.md §6) and so share one route, keyed by
      // topic id; a null id represents "today's" topic.
      GoRoute(
        path: '/topic/:topicId',
        name: AppRoute.topic,
        builder: (context, state) => PlaceholderScreen(
          screenName: "Today's Topic / Learning Screen (${state.pathParameters['topicId']})",
        ),
      ),
      GoRoute(
        path: '/topic/:topicId/mcqs',
        name: AppRoute.mcqs,
        builder: (context, state) => const PlaceholderScreen(screenName: 'MCQs'),
      ),
      GoRoute(
        path: '/flashcards',
        name: AppRoute.flashcards,
        builder: (context, state) => const PlaceholderScreen(screenName: 'Flashcards'),
      ),
    ],
  );
});

/// Bridges Riverpod's `authViewModelProvider` into a [Listenable]
/// go_router can watch — `GoRouter.refreshListenable` is how the
/// `redirect` callback above gets re-evaluated the moment auth state
/// changes, rather than only on the next explicit navigation.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authViewModelProvider, (previous, next) => notifyListeners());
  }
}
