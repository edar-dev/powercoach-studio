import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/collapsed_prescription_summary.dart';
import '../../domain/exercise_summary_sync.dart';
import 'session_preview_card.dart';

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

  static const int previewExerciseLimit = SessionPreviewCard.previewLimit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final weekdayLabel = _weekdayChipLabel(context, l10n, day.scheduledWeekday);
    final exercises = day.exercises;
    final preview = exercises.take(previewExerciseLimit).toList();
    final remaining = exercises.length - preview.length;
    final totalSets = _totalSets(exercises);
    final showMenu = !readOnly &&
        (onMenuSelected != null || onUpdateScheduledWeekday != null);

    return SessionPreviewCard(
      title: _displayDayName(l10n, day, dayIndex),
      selected: selected,
      expandPreview: true,
      onOpen: onEditSession,
      leadingChip: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
      bodyTitle: _hasCustomSessionTitle(day) ? day.name.trim() : null,
      previewRows: [
        for (final exercise in preview)
          SessionPreviewRowData(
            title: exercise.name,
            detail: collapsedPrescriptionSummary(exercise.effectiveSetDetails),
          ),
      ],
      remainingCount: remaining,
      footerMetricLabel: l10n.workoutPhaseSetsTotal(totalSets),
      showMenu: showMenu,
      onMenuSelected: showMenu
          ? (value) {
              if (value.startsWith('weekday:')) {
                final raw = value.substring('weekday:'.length);
                onUpdateScheduledWeekday?.call(
                  raw == 'null' ? null : int.parse(raw),
                );
                return;
              }
              onMenuSelected?.call(value);
            }
          : null,
      menuItems: showMenu
          ? (context) => [
                if (onMenuSelected != null) ...[
                  PopupMenuItem(
                    value: 'rename',
                    child: Text(l10n.workoutBuilderRenameDayTitle),
                  ),
                ],
                if (onUpdateScheduledWeekday != null) ...[
                  PopupMenuItem(
                    value: 'weekday:null',
                    child: Text(
                      l10n.workoutBuilderScheduledWeekdayFlexible,
                    ),
                  ),
                  for (var d = DateTime.monday; d <= DateTime.sunday; d++)
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
              ]
          : null,
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

  static int _totalSets(List<Exercise> exercises) =>
      ExerciseSummarySync.totalSetsFromExercises(exercises);
}

/// Dashed CTA card to add a day / create a session in the week grid.
///
/// [title] / [subtitle] override the default training copy so mobility can
/// reuse the same dashed chrome with section labels.
class TrainingPhaseAddDayCard extends StatelessWidget {
  const TrainingPhaseAddDayCard({
    super.key,
    this.weekNumber,
    required this.onAddDay,
    this.title,
    this.subtitle,
  });

  final int? weekNumber;
  final VoidCallback onAddDay;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final resolvedTitle = title ?? l10n.workoutPhaseAddDay;
    final resolvedSubtitle = subtitle ??
        (weekNumber == null
            ? null
            : l10n.workoutPhaseCreateSessionForWeek(weekNumber!));

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
                  resolvedTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (resolvedSubtitle != null &&
                    resolvedSubtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    resolvedSubtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
