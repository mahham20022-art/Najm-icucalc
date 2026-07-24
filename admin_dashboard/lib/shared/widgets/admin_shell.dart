import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/viewmodels/admin_auth_view_model.dart';

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// One entry per `StatefulShellRoute` branch, in branch order — indices
/// here are exactly `navigationShell.currentIndex`/`goBranch(index)`.
/// The literal task list ("Manage / Users / Topics / Learning Paths /
/// Notifications / Subscriptions / Analytics / Revenue / Medical
/// Content / Push Notifications") reads as "Manage" grouping the first
/// five destinations, with the remaining four as their own groups —
/// that grouping is rendered as static headers below, interspersed
/// between items, without needing its own entry in this index-aligned
/// list.
const _navItems = [
  _NavItem(icon: Icons.people_outline, label: 'Users'),
  _NavItem(icon: Icons.menu_book_outlined, label: 'Topics'),
  _NavItem(icon: Icons.alt_route_outlined, label: 'Learning Paths'),
  _NavItem(icon: Icons.notifications_outlined, label: 'Notifications'),
  _NavItem(icon: Icons.workspace_premium_outlined, label: 'Subscriptions'),
  _NavItem(icon: Icons.analytics_outlined, label: 'Analytics'),
  _NavItem(icon: Icons.payments_outlined, label: 'Revenue'),
  _NavItem(icon: Icons.medical_information_outlined, label: 'Medical Content'),
  _NavItem(icon: Icons.campaign_outlined, label: 'Push Notifications'),
];

/// Index (into `_navItems`/branches) that a group header precedes.
const _groupHeaders = {0: 'Manage', 5: 'Insights', 7: 'Content & Engagement'};

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(adminAuthViewModelProvider);
    final email = authState is AdminAuthAuthenticated ? authState.user.email : null;

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: Material(
              elevation: 1,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined),
                        const SizedBox(width: 8),
                        Text('Med100 Admin', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        for (var i = 0; i < _navItems.length; i++) ...[
                          if (_groupHeaders.containsKey(i))
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                              child: Text(
                                _groupHeaders[i]!.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ListTile(
                            leading: Icon(_navItems[i].icon),
                            title: Text(_navItems[i].label),
                            selected: navigationShell.currentIndex == i,
                            onTap: () => navigationShell.goBranch(
                              i,
                              initialLocation: i == navigationShell.currentIndex,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (email != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              email,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sign out',
                            icon: const Icon(Icons.logout, size: 20),
                            onPressed: () =>
                                ref.read(adminAuthViewModelProvider.notifier).signOut(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
