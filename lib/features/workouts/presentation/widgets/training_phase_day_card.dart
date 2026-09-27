import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';

/// Stitch-style day session preview card inside a phase week grid.
class TrainingPhaseDayCard extends StatelessWidget {
  const TrainingPhaseDayCard({
    super.key,
    required this.day,
    required this.dayIndex,
    required this.selected,
    required this.onEditSession,
    this.onMenuSelected,
    this.onUpdateScheduledWeekday,
    this.readOnly = false,
  });

  final Day day;
  final int dayIndex;
  final bool selected;
  final VoidCallback onEditSession;
  final void Function(String action)? onMenuSelected;
  final ValueChanged<int?>? onUpdateScheduledWeekday;
  final bool readOnly;

  static const int previewExerciseLimit = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final weekdayLabel = _weekdayChipLabel(context, l10n, day.scheduledWeekday);
    final coaching = day.coachingNote?.trim();
    final exercises = day.exercises;
    final preview = exercises.take(previewExerciseLimit).toList();
    final remaining = exercises.length - preview.length;
    final totalSets = _totalSets(exercises);

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onEditSession,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.75)
                  : cs.outlineVariant.withValues(alpha: 0.65),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      weekdayLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _displayDayName(l10n, day, dayIndex),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!readOnly &&
                      (onMenuSelected != null ||
                          onUpdateScheduledWeekday != null))
                    PopupMenuButton<String>(
                      tooltip: l10n.workoutBuilderDayMenuTooltip,
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value.startsWith('weekday:')) {
                          final raw = value.substring('weekday:'.length);
                          onUpdateScheduledWeekday?.call(
                            raw == 'null' ? null : int.parse(raw),
                          );
                          return;
                        }
                        onMenuSelected?.call(value);
                      },
                      itemBuilder: (context) => [
                        if (onMenuSelected != null) ...[
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(l10n.workoutBuilderRenameDayTitle),
                          ),
                          PopupMenuItem(
                            value: 'note',
                            child: Text(
                              l10n.workoutBuilderDayCoachingNoteTitle,
                            ),
                          ),
                        ],
                        if (onUpdateScheduledWeekday != null) ...[
                          PopupMenuItem(
                            value: 'weekday:null',
                            child: Text(
                              l10n.workoutBuilderScheduledWeekdayFlexible,
                            ),
                          ),
                          for (var d = DateTime.monday;
                              d <= DateTime.sunday;
                              d++)
                            PopupMenuItem(
                              value: 'weekday:$d',
                              child: Text(
                                _weekdayChipLabel(context, l10n, d),
                              ),
                            ),
                        ],
                        if (onMenuSelected != null)
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l10n.workoutBuilderDeleteDayMenu),
                          ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.55)),
              const SizedBox(height: 12),
              if (_hasCustomSessionTitle(day)) ...[
                Text(
                  day.name.trim(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (coaching != null && coaching.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    coaching,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
              ] else if (coaching != null && coaching.isNotEmpty) ...[
                Text(
                  coaching,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: exercises.isEmpty
                    ? Text(
                        l10n.workoutPhaseNoExercisesYet,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      )
                    : ListView(
                        padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          for (var i = 0; i < preview.length; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            _ExercisePreviewRow(
                              exercise: preview[i],
                              cs: cs,
                              theme: theme,
                            ),
                          ],
                          if (remaining > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.workoutPhaseMoreExercises(remaining),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.55)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.workoutPhaseSetsTotal(totalSets),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onEditSession,
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.workoutPhaseEditSession,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right, size: 16, color: cs.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _weekdayChipLabel(
    BuildContext context,
    AppLocalizations l10n,
    int? scheduledWeekday,
  ) {
    if (scheduledWeekday == null) {
      return l10n.workoutBuilderScheduledWeekdayFlexible;
    }
    final raw = DateFormat.E(
      Localizations.localeOf(context).toString(),
    ).format(DateTime(2024, 1, scheduledWeekday));
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  static String _displayDayName(AppLocalizations l10n, Day day, int dayIndex) {
    final trimmed = day.name.trim();
    final match = RegExp(
      r'^(GIORNO|DAY)\s+(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match != null) {
      return l10n.workoutBuilderDayNumbered(int.parse(match.group(2)!));
    }
    return l10n.workoutBuilderDayNumbered(dayIndex + 1);
  }

  static bool _hasCustomSessionTitle(Day day) {
    final trimmed = day.name.trim();
    if (trimmed.isEmpty) return false;
    final match = RegExp(
      r'^(GIORNO|DAY)\s+(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    return match == null;
  }

  static int _totalSets(List<Exercise> exercises) {
    var total = 0;
    for (final exercise in exercises) {
      for (final set in exercise.effectiveSetDetails) {
        final parsed = int.tryParse(set.sets.trim());
        if (parsed != null && parsed > 0) {
          total += parsed;
        } else if (set.displayText.trim().isNotEmpty) {
          total += 1;
        }
      }
    }
    return total;
  }
}

class _ExercisePreviewRow extends StatelessWidget {
  const _ExercisePreviewRow({
    required this.exercise,
    required this.cs,
    required this.theme,
  });

  final Exercise exercise;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final scheme = exercise.effectiveSetDetails
        .map((s) => s.displayText.trim())
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name.trim().isEmpty ? '—' : exercise.name.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (scheme.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              scheme,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.primary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dashed CTA card to add a day / create a session in the week grid.
class TrainingPhaseAddDayCard extends StatelessWidget {
  const TrainingPhaseAddDayCard({
    super.key,
    required this.weekNumber,
    required this.onAddDay,
  });

  final int weekNumber;
  final VoidCallback onAddDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onAddDay,
        borderRadius: BorderRadius.circular(14),
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: cs.outlineVariant,
            radius: 14,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainerHighest,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Icon(Icons.add, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.workoutPhaseAddDay,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.workoutPhaseCreateSessionForWeek(weekNumber),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 6.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
