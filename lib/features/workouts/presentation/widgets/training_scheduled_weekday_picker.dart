import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/day_scheduled_weekday.dart';

/// ISO weekday filter chips for a training day.
class TrainingScheduledWeekdayPicker extends StatelessWidget {
  const TrainingScheduledWeekdayPicker({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.day,
    required this.dayIndex,
    required this.weekIndex,
    required this.onUpdateScheduledWeekday,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final Day day;
  final int dayIndex;
  final int weekIndex;
  final void Function(int weekIndex, int dayIndex, int weekday)
      onUpdateScheduledWeekday;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.workoutBuilderCalendarWeekdayLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Tooltip(
              message: l10n.workoutBuilderCalendarWeekdayHint,
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final entry in kItalianWeekdayShortLabels.entries)
              Tooltip(
                message: kItalianWeekdayFullLabels[entry.key] ?? entry.value,
                child: FilterChip(
                  label: Text(entry.value),
                  selected:
                      effectiveScheduledWeekday(day: day, dayIndex: dayIndex) ==
                      entry.key,
                  onSelected: (_) => onUpdateScheduledWeekday(
                    weekIndex,
                    dayIndex,
                    entry.key,
                  ),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color:
                        effectiveScheduledWeekday(
                                  day: day,
                                  dayIndex: dayIndex,
                                ) ==
                                entry.key
                            ? Colors.white
                            : colorScheme.onSurface,
                  ),
                  selectedColor: StitchM3Theme.accent,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide(
                    color:
                        effectiveScheduledWeekday(
                                  day: day,
                                  dayIndex: dayIndex,
                                ) ==
                                entry.key
                            ? StitchM3Theme.accent
                            : colorScheme.outline.withValues(alpha: 0.35),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
