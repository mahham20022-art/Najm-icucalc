import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/breakpoints.dart';
import '../../l10n/app_localizations.dart';

/// The five tab-bar-rooted destinations, per the explicit navigation
/// list this app was asked to implement (Home, Topics, Progress,
/// Bookmarks, Profile). This is one more than the four-tab cap
/// `MED100_UI_UX_SPEC.md` §4 recommends per HIG guidance — a deliberate,
/// explicitly-requested deviation, not an oversight. Settings and
/// Subscription still live inside Profile rather than claiming their own
/// tab slots.
///
/// Renders as a bottom [NavigationBar] on phone widths and a left-edge
/// [NavigationRail] on tablet/regular widths (`MED100_UI_UX_SPEC.md`
/// §21), driven by [Breakpoints] rather than device type — the same
/// breakpoint also governs the fallback in a narrow split-view pane.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      (icon: Icons.home_outlined, selectedIcon: Icons.home, label: l10n.navHome),
      (icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: l10n.navTopics),
      (icon: Icons.trending_up_outlined, selectedIcon: Icons.trending_up, label: l10n.navProgress),
      (icon: Icons.bookmark_outline, selectedIcon: Icons.bookmark, label: l10n.navBookmarks),
      (icon: Icons.person_outline, selectedIcon: Icons.person, label: l10n.navProfile),
    ];

    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
