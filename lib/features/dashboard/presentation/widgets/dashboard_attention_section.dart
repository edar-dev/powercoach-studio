import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import 'dashboard_empty_placeholder.dart';
import 'dashboard_surface_card.dart';

/// "Needs attention" section for the coach dashboard.
class DashboardAttentionSection extends StatelessWidget {
  const DashboardAttentionSection({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardEmptyPlaceholder(
          message: l10n.dashboardNoPending,
          icon: Icons.cloud_done_outlined,
        ),
        const SizedBox(height: 8),
        DashboardSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboardBackupHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/settings');
                },
                child: Text(l10n.dashboardOpenBackupSettings),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
