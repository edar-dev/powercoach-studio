import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/dashboard_snapshot.dart';
import 'dashboard_empty_placeholder.dart';

/// "Plans to refresh" section for the coach dashboard.
class DashboardStalePlansSection extends StatelessWidget {
  const DashboardStalePlansSection({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.snapshot,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.stalePlans.isEmpty) {
      return DashboardEmptyPlaceholder(
        message: l10n.dashboardNoStalePlans(kStalePlanDays),
        icon: Icons.history_toggle_off_outlined,
      );
    }
    final localeName = l10n.localeName;
    return Column(
      children: snapshot.stalePlans.map((item) {
        final updated = DateFormat.yMMMd(localeName).format(item.updatedAt);
        final programLabel = item.programName.trim().isEmpty
            ? l10n.dashboardUntitledWorkout
            : item.programName;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              onTap: () {
                HapticFeedback.mediumImpact();
                navigateTo(context, '/customers/${item.customerId}/workouts');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_calendar_outlined, color: colorScheme.secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.clientName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            programLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            updated,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
