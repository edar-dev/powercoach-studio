import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';

/// Page header for the Stitch diary redesign (badge, title, export + record CTAs).
///
/// Owns the single diary H1 — the shell [StitchAppBar] omits its title so the
/// heading is not duplicated as "Storico" + "Diario & Storico".
class WorkoutDiaryHeader extends StatelessWidget {
  const WorkoutDiaryHeader({
    super.key,
    required this.onRecord,
    this.onExport,
  });

  final VoidCallback onRecord;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isTabletOrWider(context)) {
      return _PhoneHeader(onRecord: onRecord, onExport: onExport);
    }
    return _DesktopHeader(onRecord: onRecord, onExport: onExport);
  }
}

class _PhoneHeader extends StatelessWidget {
  const _PhoneHeader({required this.onRecord, this.onExport});

  final VoidCallback onRecord;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                // Shorter phone H1 matching desktop diary density.
                l10n.workoutDiaryDesktopTitle,
                style: const TextStyle(
                  color: StitchMobileColors.onSurface,
                  fontSize: StitchMobileColors.headlineSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onExport != null)
              IconButton(
                tooltip: l10n.workoutDiaryExportHistory,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onExport!();
                },
                icon: const Icon(
                  Icons.ios_share_outlined,
                  color: StitchMobileColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: StitchMobileColors.tertiary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.workoutDiaryLiveSync,
              style: const TextStyle(
                color: StitchMobileColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: Material(
            color: StitchMobileColors.primaryContainer,
            borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onRecord();
              },
              borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
              child: Center(
                child: Text(
                  '+ ${l10n.workoutDiaryRecordAction}',
                  style: const TextStyle(
                    color: StitchMobileColors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({required this.onRecord, this.onExport});

  final VoidCallback onRecord;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 640;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: MarketingDarkColors.cyanBright.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: MarketingDarkColors.cyanBright.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
              child: Text(
                l10n.workoutDiaryPageBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: MarketingDarkColors.cyanBright,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.workoutDiaryDesktopTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: MarketingDarkColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.workoutDiaryPageSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            ),
          ],
        );
        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onExport != null) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: MarketingDarkColors.slate300,
                  side: BorderSide(
                    color: MarketingDarkColors.stitchBorder.withValues(
                      alpha: 0.9,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onPressed: onExport,
                icon: const Icon(Icons.download_outlined, size: 16),
                label: Text(l10n.workoutDiaryExportAction),
              ),
              const SizedBox(width: 8),
            ],
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: MarketingDarkColors.cyanBright,
                foregroundColor: MarketingDarkColors.cyanOn,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: onRecord,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.workoutDiaryRecordAction),
            ),
          ],
        );
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: actions),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}
