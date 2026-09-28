import 'package:flutter/material.dart';

import '../../../../../core/billing/plan_limits.dart';
import '../../../../../core/theme/marketing_dark_colors.dart';
import '../../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../../core/ui/breakpoints.dart';
import '../../../../../l10n/app_localizations.dart';

/// Free vs Pro comparison table (no Studio Team column).
class SubscriptionPlanCompareCard extends StatelessWidget {
  const SubscriptionPlanCompareCard({
    super.key,
    required this.yearly,
    required this.onYearlyChanged,
  });

  final bool yearly;
  final ValueChanged<bool> onYearlyChanged;

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    return phone ? _buildPhone(context) : _buildDesktop(context);
  }

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.subscriptionCompareTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: StitchMobileColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StitchMobileColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.subscriptionPlanFree,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: StitchMobileColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.subscriptionCompareFreeSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: StitchMobileColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StitchMobileColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.subscriptionCompareProPopular,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: StitchMobileColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.subscriptionCompareProSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: StitchMobileColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final rows = <_CompareRowData>[
      _CompareRowData(
        feature: l10n.subscriptionCompareCustomers,
        freeLabel: l10n.subscriptionCompareCustomersFree(
          PlanLimits.maxActiveCustomers,
        ),
        proLabel: l10n.subscriptionCompareCustomersUnlimited,
      ),
      _CompareRowData(
        feature: l10n.subscriptionCompareProgressExport,
        freeLabel: l10n.subscriptionCompareNotIncluded,
        proIncluded: true,
      ),
      _CompareRowData(
        feature: l10n.subscriptionCompareWorkoutExport,
        freeLabel: l10n.subscriptionCompareNotIncluded,
        proIncluded: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 16,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.subscriptionCompareTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.subscriptionPageSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MarketingDarkColors.stitchCardElevated,
                borderRadius:
                    BorderRadius.circular(MarketingDarkColors.radiusXl),
                border: Border.all(color: MarketingDarkColors.stitchBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BillingChip(
                    label: l10n.subscriptionBillingMonthly,
                    selected: !yearly,
                    onTap: () => onYearlyChanged(false),
                  ),
                  const SizedBox(width: 4),
                  _BillingChip(
                    label: l10n.subscriptionBillingYearly,
                    selected: yearly,
                    badge: l10n.subscriptionSavePercent,
                    onTap: () => onYearlyChanged(true),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: MarketingDarkColors.stitchCardElevated,
            borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
            border: Border.all(color: MarketingDarkColors.stitchBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                color: MarketingDarkColors.stitchPageBg.withValues(alpha: 0.7),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        l10n.subscriptionCompareFeatureColumn.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: MarketingDarkColors.slate400,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            l10n.subscriptionPlanFree,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x33172554),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MarketingDarkColors.brandMid.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.subscriptionPlanPro,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              yearly
                                  ? l10n.subscriptionUpgradeYearly
                                  : l10n.subscriptionUpgradeMonthly,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: MarketingDarkColors.brandSoft,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    color: MarketingDarkColors.stitchBorder,
                  ),
                _CompareRow(data: rows[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BillingChip extends StatelessWidget {
  const _BillingChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? MarketingDarkColors.stitchCardElevated
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? Colors.white : MarketingDarkColors.slate400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: MarketingDarkColors.emerald.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: MarketingDarkColors.emerald.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: MarketingDarkColors.emerald,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompareRowData {
  const _CompareRowData({
    required this.feature,
    required this.freeLabel,
    this.proLabel,
    this.proIncluded = false,
  });

  final String feature;
  final String freeLabel;
  final String? proLabel;
  final bool proIncluded;
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.data});

  final _CompareRowData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              data.feature,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MarketingDarkColors.slate300,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data.freeLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: data.proLabel != null
                ? Text(
                    data.proLabel!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: MarketingDarkColors.brandSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Icon(
                    data.proIncluded
                        ? Icons.check_circle
                        : Icons.cancel_outlined,
                    color: data.proIncluded
                        ? MarketingDarkColors.brandLight
                        : MarketingDarkColors.slate500,
                    size: 22,
                  ),
          ),
        ],
      ),
    );
  }
}
