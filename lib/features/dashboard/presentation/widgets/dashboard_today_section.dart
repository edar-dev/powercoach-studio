import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/dashboard_snapshot.dart';
import 'dashboard_empty_placeholder.dart';
import 'dashboard_schedule_card.dart';

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
      return DashboardEmptyPlaceholder(
        message: l10n.dashboardNoScheduleToday,
        icon: Icons.event_available_outlined,
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
