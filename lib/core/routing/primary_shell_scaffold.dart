import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/stitch_m3_theme.dart';
import '../ui/breakpoints.dart';
import '../ui/widgets/stitch_brand_mark.dart';
import 'hub_chrome.dart';
import 'primary_shell_branch.dart';
import 'primary_shell_top_chrome.dart';

/// Adaptive primary shell: [NavigationBar] on phone, extended [NavigationRail]
/// on wide (Stitch Nov 2026 drawer-style chrome).
///
/// Owns nav chrome only — hub screens supply a slim title bar on tablet+.
/// Wide layouts also show [PrimaryShellTopChrome] search above hub content.
/// Settings is shell branch 4 (rail stays; not a primary tab).
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

  void _goToday() {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      primaryShellBranchToday,
      initialLocation:
          navigationShell.currentIndex == primaryShellBranchToday,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = Breakpoints.isTabletOrWider(context);
    // Rail/bar have 4 destinations; settings is branch 4 → no tab selected.
    final selectedIndex = _onSettings ? null : navigationShell.currentIndex;

    if (wide) {
      final cs = Theme.of(context).colorScheme;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              minExtendedWidth: kPrimaryShellRailExtendedWidth,
              // Extended rail requires [NavigationRailLabelType.none].
              labelType: NavigationRailLabelType.none,
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: cs.surface,
              // NavigationRail measures leading with loose width; pin to the
              // extended rail width so the brand Row + Expanded can lay out.
              leading: SizedBox(
                width: kPrimaryShellRailExtendedWidth,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  child: StitchBrandMark(
                    size: 32,
                    showTitle: true,
                    onTap: _goToday,
                  ),
                ),
              ),
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
                  child: SizedBox(
                    width: kPrimaryShellRailExtendedWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      child: _RailSettingsButton(
                        selected: _onSettings,
                        label: l10n.settingsTitle,
                        onPressed: _openSettings,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            VerticalDivider(width: 1, color: cs.outline),
            Expanded(
              child: Column(
                children: [
                  const PrimaryShellTopChrome(),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
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
              // Stitch mobile: compact labeled 4-tab bar with circular indicator.
              height: 64,
              elevation: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: selectedIndex ?? 0,
              onDestinationSelected: _onDestinationSelected,
              destinations: [
                NavigationDestination(
                  icon: Semantics(
                    label: l10n.navTabToday,
                    selected: (selectedIndex ?? 0) == 0,
                    child: const Icon(Icons.today_outlined),
                  ),
                  selectedIcon: Semantics(
                    label: l10n.navTabToday,
                    selected: true,
                    child: const Icon(Icons.today),
                  ),
                  label: l10n.navTabToday,
                ),
                NavigationDestination(
                  icon: Semantics(
                    label: l10n.navTabCustomers,
                    selected: (selectedIndex ?? 0) == 1,
                    child: const Icon(Icons.people_outline),
                  ),
                  selectedIcon: Semantics(
                    label: l10n.navTabCustomers,
                    selected: true,
                    child: const Icon(Icons.people),
                  ),
                  label: l10n.navTabCustomers,
                ),
                NavigationDestination(
                  icon: Semantics(
                    label: l10n.navTabWorkouts,
                    selected: (selectedIndex ?? 0) == 2,
                    child: const Icon(Icons.fitness_center_outlined),
                  ),
                  selectedIcon: Semantics(
                    label: l10n.navTabWorkouts,
                    selected: true,
                    child: const Icon(Icons.fitness_center),
                  ),
                  label: l10n.navTabWorkouts,
                ),
                NavigationDestination(
                  icon: Semantics(
                    label: l10n.navTabDiary,
                    selected: (selectedIndex ?? 0) == 3,
                    child: const Icon(Icons.menu_book_outlined),
                  ),
                  selectedIcon: Semantics(
                    label: l10n.navTabDiary,
                    selected: true,
                    child: const Icon(Icons.menu_book),
                  ),
                  label: l10n.navTabDiary,
                ),
              ],
            ),
    );
  }
}

/// Labeled settings control for the extended rail (Stitch trailing gear + copy).
class _RailSettingsButton extends StatelessWidget {
  const _RailSettingsButton({
    required this.selected,
    required this.label,
    required this.onPressed,
  });

  final bool selected;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final bg = selected ? cs.primary.withValues(alpha: 0.16) : null;
    final fg = selected ? cs.primary : cs.onSurfaceVariant;

    return Tooltip(
      message: label,
      child: Material(
        color: bg ?? Colors.transparent,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.settings : Icons.settings_outlined,
                  color: fg,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: fg,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
