import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'dashboard_surface_card.dart';

/// Quick management shortcuts under the coach dashboard audit sections.
class DashboardShortcutsSection extends StatelessWidget {
  const DashboardShortcutsSection({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ShortcutItem(
        icon: Icons.fitness_center_outlined,
        iconTint: StitchM3Theme.accent,
        title: l10n.exerciseLibraryTitle,
        subtitle: l10n.dashboardShortcutLibrarySubtitle,
        path: '/exercise-library',
      ),
      _ShortcutItem(
        icon: Icons.construction_outlined,
        iconTint: colorScheme.secondary,
        title: l10n.dashboardWorkoutBuilder,
        subtitle: l10n.dashboardWorkoutBuilderDraft,
        path: '/workouts/builder',
      ),
      _ShortcutItem(
        icon: Icons.person_add_alt_1_outlined,
        iconTint: StitchM3Theme.success,
        title: l10n.dashboardShortcutNewAthlete,
        subtitle: l10n.dashboardShortcutNewAthleteSubtitle,
        path: '/customers/new',
      ),
      _ShortcutItem(
        icon: Icons.settings_outlined,
        iconTint: colorScheme.onSurfaceVariant,
        title: l10n.settingsTitle,
        subtitle: l10n.dashboardShortcutSettingsSubtitle,
        path: '/settings',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.dashboardShortcutsTitle,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            if (wide) {
              return Row(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: _ShortcutTile(item: items[i], theme: theme, colorScheme: colorScheme)),
                  ],
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _ShortcutTile(item: items[0], theme: theme, colorScheme: colorScheme)),
                    const SizedBox(width: 12),
                    Expanded(child: _ShortcutTile(item: items[1], theme: theme, colorScheme: colorScheme)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _ShortcutTile(item: items[2], theme: theme, colorScheme: colorScheme)),
                    const SizedBox(width: 12),
                    Expanded(child: _ShortcutTile(item: items[3], theme: theme, colorScheme: colorScheme)),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ShortcutItem {
  const _ShortcutItem({
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.subtitle,
    required this.path,
  });

  final IconData icon;
  final Color iconTint;
  final String title;
  final String subtitle;
  final String path;
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.item,
    required this.theme,
    required this.colorScheme,
  });

  final _ShortcutItem item;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        onTap: () {
          HapticFeedback.mediumImpact();
          navigateTo(context, item.path);
        },
        child: DashboardSurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.iconTint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                ),
                child: Icon(item.icon, size: 16, color: item.iconTint),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
