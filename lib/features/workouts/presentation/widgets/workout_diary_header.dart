import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Page header for the Stitch diary redesign (badge, title, record CTA).
class WorkoutDiaryHeader extends StatelessWidget {
  const WorkoutDiaryHeader({super.key, required this.onRecord});

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
