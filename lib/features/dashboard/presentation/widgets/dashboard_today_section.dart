import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/dashboard_snapshot.dart';
import 'dashboard_schedule_card.dart';
import 'dashboard_surface_card.dart';

/// "Today" section rows for the coach dashboard.
class DashboardTodaySection extends StatelessWidget {
  const DashboardTodaySection({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.snapshot,
    required this.loading,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final DashboardSnapshot snapshot;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading && snapshot.todayItems.isEmpty && !snapshot.hasError) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final items = snapshot.todayItems.take(kDashboardSectionRowLimit).toList();
    if (items.isEmpty) {
      // Primary CTA must use white-on-accent: FilledButton.tonalIcon inherits
      // [filledButtonTheme] accent background, so accent foreground made the
      // label invisible (blue on blue).
      final emptyActionsStyle = ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(44, 40)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          ),
        ),
      );
      return DashboardSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.06),
                    borderRadius:
                        BorderRadius.circular(StitchM3Theme.radiusXl),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.event_available_outlined,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardNoScheduleToday,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.dashboardTodayEmptyHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  navigateTo(context, '/dashboard/calendar');
                },
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: Text(l10n.dashboardOpenAgenda),
                style: emptyActionsStyle.copyWith(
                  backgroundColor:
                      const WidgetStatePropertyAll(StitchM3Theme.accent),
                  foregroundColor:
                      const WidgetStatePropertyAll(Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final localeName = l10n.localeName;
    return Column(
      children: items.map((item) {
        final dateLabel = DateFormat(
          'dd MMM',
          localeName,
        ).format(item.date).toUpperCase();
        final weekdayLabel = DateFormat(
          'EEE',
          localeName,
        ).format(item.date).toUpperCase();
        final programLabel = item.programName.trim().isEmpty
            ? l10n.dashboardUntitledWorkout
            : item.programName;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DashboardScheduleCard(
            theme: theme,
            colorScheme: colorScheme,
            time: dateLabel,
            period: weekdayLabel,
            clientName: item.clientName,
            programName: programLabel,
            onTap: () {
              HapticFeedback.mediumImpact();
              navigateTo(
                context,
                scheduleSessionDetailPath(
                  customerId: item.customerId,
                  planId: item.planId,
                  weekIndex: item.weekIndex,
                  dayIndex: item.dayIndex,
                  date: item.date,
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
