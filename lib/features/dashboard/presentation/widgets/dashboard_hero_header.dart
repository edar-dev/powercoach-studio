import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Greeting + date + primary actions for the slim-hub dashboard hero.
///
/// Pure presentation: the screen supplies [displayName] and [dateLabel].
class DashboardHeroHeader extends StatelessWidget {
  const DashboardHeroHeader({
    super.key,
    required this.displayName,
    required this.dateLabel,
    this.onNewCustomer,
    this.onOpenCalendar,
    this.onOpenDiary,
  });

  final String displayName;
  final String dateLabel;
  final VoidCallback? onNewCustomer;
  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenDiary;

  void _goNewCustomer(BuildContext context) {
    HapticFeedback.mediumImpact();
    if (onNewCustomer != null) {
      onNewCustomer!();
      return;
    }
    navigateTo(context, AppPaths.customersNew);
  }

  void _goCalendar(BuildContext context) {
    HapticFeedback.mediumImpact();
    if (onOpenCalendar != null) {
      onOpenCalendar!();
      return;
    }
    navigateTo(context, AppPaths.calendar);
  }

  void _goDiary(BuildContext context) {
    HapticFeedback.mediumImpact();
    if (onOpenDiary != null) {
      onOpenDiary!();
      return;
    }
    navigateTo(context, AppPaths.workoutDiary);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.dashboardGreeting(displayName),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ],
    );

    final actions = [
      FilledButton.icon(
        onPressed: () => _goNewCustomer(context),
        icon: const Icon(Icons.add, size: 18),
        label: Text(l10n.customersNewCustomer),
        style: FilledButton.styleFrom(
          backgroundColor: StitchM3Theme.accent,
          foregroundColor: Colors.white,
          visualDensity: VisualDensity.comfortable,
        ),
      ),
      OutlinedButton(
        onPressed: () => _goCalendar(context),
        child: Text(l10n.dashboardOpenCalendar),
      ),
      OutlinedButton(
        onPressed: () => _goDiary(context),
        child: Text(l10n.dashboardOpenDiary),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: actions,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleBlock,
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        );
      },
    );
  }
}
