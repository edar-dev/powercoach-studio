import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../ui/breakpoints.dart';
import 'app_navigation.dart';
import 'app_paths.dart';

/// Adaptive primary shell: [NavigationBar] on phone, [NavigationRail] on wide.
///
/// Owns nav chrome only — hub screens supply their own [StitchAppBar].
class PrimaryShellScaffold extends StatelessWidget {
  const PrimaryShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _openSettings(BuildContext context) {
    HapticFeedback.mediumImpact();
    navigateTo(context, AppPaths.settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = Breakpoints.isTabletOrWider(context);

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
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
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: l10n.settingsTitle,
                      onPressed: () => _openSettings(context),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
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
