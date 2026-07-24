import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/admin_role.dart';
import '../../features/auth/presentation/screens/admin_login_screen.dart';
import '../../features/auth/presentation/screens/not_authorized_screen.dart';
import '../../features/auth/presentation/viewmodels/admin_auth_view_model.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/widgets/placeholder_screen.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/analytics',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(adminAuthViewModelProvider);
      final location = state.matchedLocation;

      // Still resolving a persisted session — don't redirect yet, or a
      // signed-in admin would flash through Login on every cold start.
      if (authState is AdminAuthInitial) return null;

      final isLoginRoute = location == '/login';
      final isNotAuthorizedRoute = location == '/not-authorized';

      if (authState is! AdminAuthAuthenticated) {
        return isLoginRoute ? null : '/login';
      }

      if (!authState.user.role.canAccessDashboard) {
        return isNotAuthorizedRoute ? null : '/not-authorized';
      }

      if (isLoginRoute || isNotAuthorizedRoute) return '/analytics';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/not-authorized',
        name: AppRoute.notAuthorized,
        builder: (context, state) => const NotAuthorizedScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/users',
                name: AppRoute.users,
                builder: (context, state) => const UsersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/topics',
                name: AppRoute.topics,
                builder: (context, state) => const PlaceholderScreen(title: 'Topics'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learning-paths',
                name: AppRoute.learningPaths,
                builder: (context, state) => const PlaceholderScreen(title: 'Learning Paths'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications-mgmt',
                name: AppRoute.notificationsMgmt,
                builder: (context, state) => const PlaceholderScreen(title: 'Notifications'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/subscriptions-mgmt',
                name: AppRoute.subscriptionsMgmt,
                builder: (context, state) => const PlaceholderScreen(title: 'Subscriptions'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                name: AppRoute.analytics,
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/revenue',
                name: AppRoute.revenue,
                builder: (context, state) => const PlaceholderScreen(title: 'Revenue'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/medical-content',
                name: AppRoute.medicalContent,
                builder: (context, state) => const PlaceholderScreen(title: 'Medical Content'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/push-notifications',
                name: AppRoute.pushNotifications,
                builder: (context, state) => const PlaceholderScreen(title: 'Push Notifications'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Bridges Riverpod's `adminAuthViewModelProvider` into a [Listenable]
/// go_router can watch — same pattern as `app_mobile`'s
/// `_AuthRefreshNotifier`.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(adminAuthViewModelProvider, (previous, next) => notifyListeners());
  }
}
