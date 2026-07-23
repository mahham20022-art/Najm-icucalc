import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/placeholder_screen.dart';
import '../../shared/widgets/route_error_screen.dart';

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

/// One route per screen requested — Splash, Onboarding, Login, Register,
/// Home, Topics, Progress, Bookmarks, Profile, Settings, Subscription —
/// plus a handful of routes already scaffolded before this pass (topic
/// detail, MCQs, Flashcards, Teaching Mode) that this change doesn't
/// remove. Every leaf is a [PlaceholderScreen]: no business logic, no
/// data, no auth — [PlaceholderAction] buttons exist purely so the graph
/// is actually tappable end-to-end (Splash → Onboarding → Login/Register
/// → Home, Profile → Settings/Subscription), not to simulate real
/// sign-in or onboarding behavior.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    // A malformed/stale deep link (push notification, universal link) is
    // an expected occurrence at scale, not a developer-only concern — see
    // `shared/widgets/route_error_screen.dart`.
    errorBuilder: (context, state) => const RouteErrorScreen(),
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash,
        builder: (context, state) => PlaceholderScreen(
          screenName: 'Splash',
          showAppBar: false,
          actions: [
            PlaceholderAction(
              label: AppLocalizations.of(context).continueLabel,
              onPressed: () => context.goNamed(AppRoute.onboarding),
            ),
          ],
        ),
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
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          return PlaceholderScreen(
            screenName: 'Login',
            showAppBar: false,
            actions: [
              PlaceholderAction(label: l10n.logIn, onPressed: () => context.goNamed(AppRoute.home)),
              PlaceholderAction(
                label: l10n.goToRegister,
                emphasized: false,
                onPressed: () => context.goNamed(AppRoute.register),
              ),
            ],
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register,
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          return PlaceholderScreen(
            screenName: 'Register',
            showAppBar: false,
            actions: [
              PlaceholderAction(
                label: l10n.register,
                onPressed: () => context.goNamed(AppRoute.home),
              ),
              PlaceholderAction(
                label: l10n.goToLogin,
                emphasized: false,
                onPressed: () => context.goNamed(AppRoute.login),
              ),
            ],
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home,
                builder: (context, state) =>
                    const PlaceholderScreen(screenName: 'Home', showAppBar: false),
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
                    builder: (context, state) => const PlaceholderScreen(screenName: 'Statistics'),
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
                builder: (context, state) => const PlaceholderScreen(screenName: 'Bookmarks'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile,
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return PlaceholderScreen(
                    screenName: 'Profile',
                    actions: [
                      PlaceholderAction(
                        label: l10n.openSettings,
                        emphasized: false,
                        onPressed: () => context.goNamed(AppRoute.settings),
                      ),
                      PlaceholderAction(
                        label: l10n.openSubscription,
                        emphasized: false,
                        onPressed: () => context.goNamed(AppRoute.subscription),
                      ),
                    ],
                  );
                },
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
