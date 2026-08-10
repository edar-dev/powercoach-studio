import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
import 'training_planner_sheets.dart';

/// Compact sticky navigation for week, day, and scheduled weekday.
class TrainingSessionToolbar extends StatelessWidget {
  const TrainingSessionToolbar({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.weeks,
    required this.weekIndex,
    required this.dayIndex,
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onEditWeek,
    required this.onAddDay,
    required this.onEditDay,
    required this.onDeleteDay,
    required this.onUpdateScheduledWeekday,
    this.onCloneDayToTarget,
    this.onEditDayCoachingNote,
  });

  /// Sentinel for PopupMenu (null values are treated as cancel by Flutter).
  static const int _flexibleWeekdayMenuValue = 0;

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final List<Week> weeks;
  final int weekIndex;
  final int dayIndex;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int weekIndex) onEditWeek;
  final void Function(int) onAddDay;
  final void Function(int weekIndex, int dayIndex) onEditDay;
  final void Function(int, int) onDeleteDay;
  final void Function(int weekIndex, int dayIndex, int? weekday)
      onUpdateScheduledWeekday;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final void Function(int weekIndex, int dayIndex)? onEditDayCoachingNote;

  String _weekdayShort(BuildContext context, int isoWeekday) {
    final date = DateTime(2024, 1, isoWeekday);
    return DateFormat.E(Localizations.localeOf(context).toString()).format(date);
  }

  /// Normalize legacy ALL-CAPS week/day labels to current l10n casing.
  String _displaySectionName(String raw) {
    final trimmed = raw.trim();
    final week = RegExp(
      r'^(SETTIMANA|WEEK)\s+(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (week != null) {
      return l10n.workoutBuilderWeekNumbered(int.parse(week.group(2)!));
    }
    final day = RegExp(
      r'^(GIORNO|DAY)\s+(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (day != null) {
      return l10n.workoutBuilderDayNumbered(int.parse(day.group(2)!));
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final week = weeks[weekIndex];
    final days = week.days;
    final day = days.isEmpty ? null : days[dayIndex.clamp(0, days.length - 1)];
    final scheduledWeekday = day?.scheduledWeekday;
    final weekdayChipLabel = scheduledWeekday == null
        ? l10n.workoutBuilderScheduledWeekdayFlexible
        : _weekdayShort(context, scheduledWeekday);
    final weekdayTooltip = scheduledWeekday == null
        ? l10n.workoutBuilderScheduledWeekdayFlexibleHint
        : DateFormat.EEEE(
            Localizations.localeOf(context).toString(),
          ).format(DateTime(2024, 1, scheduledWeekday));

    return Material(
      color: colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            _WeekMenuButton(
              theme: theme,
              colorScheme: colorScheme,
              l10n: l10n,
              weeks: weeks,
              weekIndex: weekIndex,
              displayWeekName: _displaySectionName,
              onSelectWeek: onSelectWeek,
              onNewWeek: onNewWeek,
              onCloneWeek: onCloneWeek,
              onDeleteWeek: onDeleteWeek,
              onEditWeek: onEditWeek,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < days.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      _DayChip(
                        label: _displaySectionName(days[i].name),
                        selected: i == dayIndex,
                        onTap: () => onSelectDay(i),
                      ),
                    ],
                    const SizedBox(width: 6),
                    _DayChip(
                      label: '+ ${l10n.workoutBuilderAddDayChip}',
                      selected: false,
                      onTap: () => onAddDay(weekIndex),
                      outlined: true,
                    ),
                  ],
                ),
              ),
            ),
            if (day != null)
              PopupMenuButton<int>(
                tooltip: weekdayTooltip,
                onSelected: (value) => onUpdateScheduledWeekday(
                  weekIndex,
                  dayIndex,
                  value == _flexibleWeekdayMenuValue ? null : value,
                ),
                itemBuilder: (ctx) => [
                  PopupMenuItem<int>(
                    value: _flexibleWeekdayMenuValue,
                    child: Text(l10n.workoutBuilderScheduledWeekdayFlexible),
                  ),
                  for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                    PopupMenuItem<int>(
                      value: d,
                      child: Text(_weekdayShort(ctx, d)),
                    ),
                ],
                child: _SessionChip(
                  label: weekdayChipLabel,
                  outlined: true,
                  trailing: Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (days.isNotEmpty)
              IconButton(
                tooltip: l10n.workoutBuilderDayMenuTooltip,
                icon: Icon(
                  Icons.more_horiz,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => showTrainingPlannerMenuSheet(
                  context,
                  actions: [
                    (
                      icon: Icons.edit_outlined,
                      label: l10n.workoutBuilderRenameDayTitle,
                      onTap: () => onEditDay(weekIndex, dayIndex),
                      destructive: false,
                    ),
                    if (onEditDayCoachingNote != null)
                      (
                        icon: Icons.sticky_note_2_outlined,
                        label: l10n.workoutBuilderDayCoachingNoteTitle,
                        onTap: () =>
                            onEditDayCoachingNote!(weekIndex, dayIndex),
                        destructive: false,
                      ),
                    if (onCloneDayToTarget != null)
                      (
                        icon: Icons.copy_outlined,
                        label: l10n.workoutBuilderCloneDayToTarget,
                        onTap: () =>
                            onCloneDayToTarget!(weekIndex, dayIndex),
                        destructive: false,
                      ),
                    if (days.length > 1)
                      (
                        icon: Icons.delete_outline,
                        label: l10n.workoutBuilderDeleteDayMenu,
                        onTap: () => onDeleteDay(weekIndex, dayIndex),
                        destructive: true,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekMenuButton extends StatelessWidget {
  const _WeekMenuButton({
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.weeks,
    required this.weekIndex,
    required this.displayWeekName,
    required this.onSelectWeek,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onEditWeek,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final List<Week> weeks;
  final int weekIndex;
  final String Function(String raw) displayWeekName;
  final void Function(int) onSelectWeek;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int weekIndex) onEditWeek;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: l10n.workoutBuilderWeekMenuTooltip,
      onSelected: (value) {
        if (value == 'new') {
          onNewWeek();
        } else if (value == 'rename') {
          onEditWeek(weekIndex);
        } else if (value == 'clone') {
          onCloneWeek(weekIndex);
        } else if (value == 'delete') {
          onDeleteWeek(weekIndex);
        } else if (value.startsWith('week:')) {
          onSelectWeek(int.parse(value.substring(5)));
        }
      },
      itemBuilder: (ctx) => [
        for (var i = 0; i < weeks.length; i++)
          CheckedPopupMenuItem<String>(
            value: 'week:$i',
            checked: i == weekIndex,
            child: Text(displayWeekName(weeks[i].name)),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'new',
          child: Text(l10n.workoutBuilderNewWeek),
        ),
        PopupMenuItem(
          value: 'rename',
          child: Text(l10n.workoutBuilderRenameWeekMenu),
        ),
        PopupMenuItem(
          value: 'clone',
          child: Text(l10n.workoutBuilderDuplicateWeek),
        ),
        if (weeks.length > 1)
          PopupMenuItem(
            value: 'delete',
            child: Text(
              l10n.workoutBuilderDeleteWeekMenu,
              style: const TextStyle(color: StitchM3Theme.danger),
            ),
          ),
      ],
      child: _SessionChip(
        label: displayWeekName(weeks[weekIndex].name),
        outlined: true,
        accent: true,
        trailing: Icon(
          Icons.arrow_drop_down,
          color: StitchM3Theme.accent,
          size: 20,
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: _SessionChip(
          label: label,
          selected: selected,
          outlined: outlined,
        ),
      ),
    );
  }
}

/// Shared pill chrome for week / day / weekday controls.
class _SessionChip extends StatelessWidget {
  const _SessionChip({
    required this.label,
    this.selected = false,
    this.outlined = false,
    this.accent = false,
    this.trailing,
  });

  final String label;
  final bool selected;
  final bool outlined;
  final bool accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final Color foreground;
    if (selected) {
      foreground = Colors.white;
    } else if (accent) {
      foreground = StitchM3Theme.accent;
    } else if (outlined) {
      foreground = cs.onSurfaceVariant;
    } else {
      foreground = cs.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? StitchM3Theme.accent
            : outlined
                ? Colors.transparent
                : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: outlined
            ? Border.all(
                color: accent
                    ? StitchM3Theme.accent.withValues(alpha: 0.55)
                    : cs.outline.withValues(alpha: 0.7),
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 2),
            trailing!,
          ],
        ],
      ),
    );
  }
}
