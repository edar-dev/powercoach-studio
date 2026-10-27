import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../ui/breakpoints.dart';
import 'primary_shell_branch.dart';

/// Adaptive primary shell: [NavigationBar] on phone, [NavigationRail] on wide.
///
/// Owns nav chrome only — hub screens supply a slim title bar on tablet+
/// (logo/settings live on the rail). Settings is shell branch 4 (rail stays).
class PrimaryShellScaffold extends StatelessWidget {
  const PrimaryShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  bool get _onSettings =>
      navigationShell.currentIndex == primaryShellBranchSettings;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _openSettings() {
    HapticFeedback.mediumImpact();
    navigationShell.goBranch(
      primaryShellBranchSettings,
      initialLocation:
          navigationShell.currentIndex == primaryShellBranchSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = Breakpoints.isTabletOrWider(context);
    // Rail/bar have 4 destinations; settings is branch 4 → no tab selected.
    final selectedIndex = _onSettings ? null : navigationShell.currentIndex;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.today_outlined),
                  selectedIcon: const Icon(Icons.today),
                  label: Text(l10n.navTabToday),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people),
                  label: Text(l10n.navTabCustomers),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.fitness_center_outlined),
                  selectedIcon: const Icon(Icons.fitness_center),
                  label: Text(l10n.navTabWorkouts),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.menu_book_outlined),
                  selectedIcon: const Icon(Icons.menu_book),
                  label: Text(l10n.navTabDiary),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: Icon(
                        _onSettings
                            ? Icons.settings
                            : Icons.settings_outlined,
                      ),
                      tooltip: l10n.settingsTitle,
                      isSelected: _onSettings,
                      onPressed: _openSettings,
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      // Settings is not a phone tab; hide bar so secondary chrome owns escape.
      bottomNavigationBar: _onSettings
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex ?? 0,
              onDestinationSelected: _onDestinationSelected,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.today_outlined),
                  selectedIcon: const Icon(Icons.today),
                  label: l10n.navTabToday,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people),
                  label: l10n.navTabCustomers,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.fitness_center_outlined),
                  selectedIcon: const Icon(Icons.fitness_center),
                  label: l10n.navTabWorkouts,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.menu_book_outlined),
                  selectedIcon: const Icon(Icons.menu_book),
                  label: l10n.navTabDiary,
                ),
              ],
            ),
    );
  }
}
