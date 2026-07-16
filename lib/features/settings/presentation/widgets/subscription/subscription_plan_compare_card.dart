import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/billing/plan_limits.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

import '../../../../../l10n/app_localizations.dart';

class SubscriptionPlanCompareCard extends StatelessWidget {
  const SubscriptionPlanCompareCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final rows = <_CompareRowData>[
      _CompareRowData(
        feature: l10n.subscriptionCompareCustomers,
        freeLabel: l10n.subscriptionCompareCustomersFree(
          PlanLimits.maxActiveCustomers,
        ),
        proIncluded: true,
      ),
      _CompareRowData(
        feature: l10n.subscriptionCompareProgressExport,
        freeLabel: l10n.subscriptionCompareNotIncluded,
        proIncluded: true,
      ),
      _CompareRowData(
        feature: l10n.subscriptionCompareHevy,
        freeLabel: l10n.subscriptionCompareNotIncluded,
        proIncluded: true,
      ),
      _CompareRowData(
        feature: l10n.subscriptionCompareWorkoutExport,
        freeLabel: l10n.subscriptionCompareNotIncluded,
        proIncluded: true,
      ),
    ];

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        side: BorderSide(color: cs.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.subscriptionCompareTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.subscriptionCompareFeatureColumn,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.subscriptionPlanFree,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.subscriptionPlanPro,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            ...rows.map(
              (row) => _CompareRow(
                feature: row.feature,
                freeLabel: row.freeLabel,
                proIncluded: row.proIncluded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareRowData {
  const _CompareRowData({
    required this.feature,
    required this.freeLabel,
    required this.proIncluded,
  });

  final String feature;
  final String freeLabel;
  final bool proIncluded;
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.feature,
    required this.freeLabel,
    required this.proIncluded,
  });

  final String feature;
  final String freeLabel;
  final bool proIncluded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(feature, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              freeLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Icon(
              proIncluded ? Icons.check_circle : Icons.cancel_outlined,
              color: proIncluded ? cs.primary : cs.outline,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
