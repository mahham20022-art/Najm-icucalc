import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  static const auth = 'auth';
  static const home = 'home';
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

/// One route per screen named in `MED100_UI_UX_SPEC.md`. Every leaf is a
/// [PlaceholderScreen] — this router exists to prove the navigation graph
/// (including the tablet/phone adaptive shell) is wired correctly, not to
/// implement any screen's behavior.
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
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'Splash', showAppBar: false),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'Onboarding', showAppBar: false),
      ),
      GoRoute(
        path: '/auth',
        name: AppRoute.auth,
        builder: (context, state) =>
            const PlaceholderScreen(screenName: 'Authentication', showAppBar: false),
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
                path: '/bookmarks',
                name: AppRoute.bookmarks,
                builder: (context, state) => const PlaceholderScreen(screenName: 'Bookmarks'),
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
                path: '/profile',
                name: AppRoute.profile,
                builder: (context, state) => const PlaceholderScreen(screenName: 'Profile'),
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
