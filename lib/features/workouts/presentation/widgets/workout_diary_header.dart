import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';

/// Page header for the Stitch diary redesign (badge, title, record CTA).
class WorkoutDiaryHeader extends StatelessWidget {
  const WorkoutDiaryHeader({super.key, required this.onRecord});

  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isTabletOrWider(context)) {
      return _PhoneHeader(onRecord: onRecord);
    }
    return _DesktopHeader(onRecord: onRecord);
  }
}

class _PhoneHeader extends StatelessWidget {
  const _PhoneHeader({required this.onRecord});

  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.workoutDiaryPageTitle,
          style: const TextStyle(
            color: StitchMobileColors.onSurface,
            fontSize: StitchMobileColors.headlineSize,
            fontWeight: FontWeight.w700,
          ),
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
  const _DesktopHeader({required this.onRecord});

  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canPop)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: MarketingDarkColors.slate300,
              ),
            ),
          ),
        LayoutBuilder(
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
                const SizedBox(height: 8),
                Text(
                  l10n.workoutDiaryPageTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: MarketingDarkColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.workoutDiaryPageSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                ),
              ],
            );
            final actions = FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: MarketingDarkColors.cyanBright,
                foregroundColor: MarketingDarkColors.cyanOn,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              onPressed: onRecord,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.workoutDiaryRecordAction),
            );
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titleBlock,
                  const SizedBox(height: 16),
                  Align(alignment: Alignment.centerLeft, child: actions),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 16),
                actions,
              ],
            );
          },
        ),
      ],
    );
  }
}
