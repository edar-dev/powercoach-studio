import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../domain/session_execution_service.dart';
import 'workout_diary_session_card.dart';

/// Date-grouped timeline list for diary entries.
class WorkoutDiaryTimeline extends StatelessWidget {
  const WorkoutDiaryTimeline({
    super.key,
    required this.groups,
    required this.dateFormat,
    required this.customerNameOf,
    required this.onOpenEntry,
    required this.loadingMore,
  });

  final List<MapEntry<DateTime, List<SessionExecutionEntry>>> groups;
  final DateFormat dateFormat;
  final String Function(String customerId) customerNameOf;
  final ValueChanged<SessionExecutionEntry> onOpenEntry;
  final bool loadingMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];

    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      children.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 8, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: MarketingDarkColors.surface800.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: MarketingDarkColors.stitchBorderMuted.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                child: Text(
                  dateFormat.format(group.key).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Divider(
                  color: MarketingDarkColors.stitchBorder,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      );
      for (final entry in group.value) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WorkoutDiarySessionCard(
              entry: entry,
              customerName: customerNameOf(entry.customerId),
              onTap: () => onOpenEntry(entry),
            ),
          ),
        );
      }
    }

    if (loadingMore) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: CircularProgressIndicator(
              color: MarketingDarkColors.cyanBright,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
