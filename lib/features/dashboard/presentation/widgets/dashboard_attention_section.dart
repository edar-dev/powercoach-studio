import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/data_quality/data_quality.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/dashboard_snapshot.dart';
import 'dashboard_surface_card.dart';

/// Max DQ finding rows shown before "+N more" in Attention.
const int kDashboardAttentionFindingPreviewLimit = 3;

/// "Needs attention" section: data-health issues + local-first / backup hint.
///
/// When [actionableFindings] is non-empty, surfaces severe scanner results with
/// a deep link to [AppPaths.dataHealth]. Otherwise shows the all-clear card.
class DashboardAttentionSection extends StatelessWidget {
  const DashboardAttentionSection({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    this.actionableFindings = const [],
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final List<DataQualityFinding> actionableFindings;

  @override
  Widget build(BuildContext context) {
    if (actionableFindings.isNotEmpty) {
      return _DataHealthAttentionCard(
        theme: theme,
        colorScheme: colorScheme,
        l10n: l10n,
        findings: actionableFindings,
      );
    }
    return _AllClearAttentionCard(
      theme: theme,
      colorScheme: colorScheme,
      l10n: l10n,
    );
  }
}

class _AllClearAttentionCard extends StatelessWidget {
  const _AllClearAttentionCard({
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
              navigateTo(context, AppPaths.settings);
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

class _DataHealthAttentionCard extends StatelessWidget {
  const _DataHealthAttentionCard({
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.findings,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final List<DataQualityFinding> findings;

  @override
  Widget build(BuildContext context) {
    final hasError =
        findings.any((f) => f.severity == DataQualitySeverity.error);
    final tone = hasError ? colorScheme.error : colorScheme.tertiary;
    final previewLimit = kDashboardAttentionFindingPreviewLimit
        .clamp(0, kDashboardSectionRowLimit);
    final preview = findings.take(previewLimit).toList();
    final remaining = findings.length - preview.length;

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
                  color: tone.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(StitchM3Theme.radiusXl),
                  border: Border.all(
                    color: tone.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  hasError
                      ? Icons.error_outline
                      : Icons.warning_amber_outlined,
                  size: 20,
                  color: tone,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardDataHealthIssuesTitle(findings.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.dashboardDataHealthIssuesHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final finding in preview) ...[
            _FindingPreviewRow(
              theme: theme,
              colorScheme: colorScheme,
              l10n: l10n,
              finding: finding,
            ),
            const SizedBox(height: 6),
          ],
          if (remaining > 0) ...[
            Text(
              l10n.dashboardDataHealthMoreCount(remaining),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, AppPaths.dataHealth);
            },
            style: TextButton.styleFrom(
              foregroundColor: StitchM3Theme.accent,
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.dashboardOpenDataHealth),
          ),
        ],
      ),
    );
  }
}

class _FindingPreviewRow extends StatelessWidget {
  const _FindingPreviewRow({
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.finding,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final DataQualityFinding finding;

  String _severityLabel() {
    switch (finding.severity) {
      case DataQualitySeverity.error:
        return l10n.dataHealthSeverityError;
      case DataQualitySeverity.warning:
        return l10n.dataHealthSeverityWarning;
      case DataQualitySeverity.info:
        return l10n.dataHealthSeverityInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError = finding.severity == DataQualitySeverity.error;
    final badgeColor = isError ? colorScheme.error : colorScheme.tertiary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
          ),
          child: Text(
            _severityLabel(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            finding.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
