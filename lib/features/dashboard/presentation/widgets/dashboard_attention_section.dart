import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'dashboard_surface_card.dart';

/// "Needs attention" empty / local-first hint for the coach dashboard.
///
/// Single card (no stacked empty + backup cards) so spacing matches other
/// dashboard empties and the backup CTA stays one tap away.
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
    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: StitchM3Theme.success.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(StitchM3Theme.radiusXl),
                  border: Border.all(
                    color: StitchM3Theme.success.withValues(alpha: 0.22),
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: StitchM3Theme.success,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardNoPending,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.dashboardAttentionLocalHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.dashboardBackupHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/settings');
            },
            style: TextButton.styleFrom(
              foregroundColor: StitchM3Theme.accent,
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.dashboardOpenBackupSettings),
          ),
        ],
      ),
    );
  }
}
