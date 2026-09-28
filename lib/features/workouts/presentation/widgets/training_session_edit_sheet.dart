import 'dart:async';

import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/breakpoints.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/library_exercise_name_enrichment.dart';
import '../../domain/workout_exercise_mutations.dart';
import '../workout_builder_session_controller.dart';
import 'exercise_library_pick_panel.dart';
import 'workout_day_exercise_list.dart';

/// Stitch dark tokens for the session edit modal (screen 08fb2bda…).
abstract final class _SessionEditColors {
  static const Color backdrop = Color(0xFF090D16);
  static const Color card = Color(0xFF111827);
  static const Color border = Color(0xFF28354D);
  static const Color header = Color(0xE6111827); // slate-900/90-ish
  static const Color metrics = Color(0xFF131B2C);
  static const Color footer = Color(0xFF0F1624);
  static const Color metricBlue = Color(0xFF60A5FA);
  static const Color metricIndigo = Color(0xFF818CF8);
  static const Color metricEmerald = Color(0xFF34D399);
  static const Color metricAmber = Color(0xFFFBBF24);
}

/// Opens the Stitch-aligned full-screen "Modifica sessione" surface.
///
/// Uses a root [fullscreenDialog] route (not a bottom sheet) so it cannot
/// collapse into an inline section under the Allenamento grid.
///
/// Tracks the day by stable [Day.id] so deletes/reorders while open either
/// keep pointing at the same day or auto-dismiss.
Future<void> showTrainingSessionEditSheet({
  required BuildContext context,
  required ThemeData theme,
  required ColorScheme cs,
  required WorkoutBuilderSessionController session,
  required int globalWeekIndex,
  required int dayIndex,
  required void Function(int weekIndex, int dayIndex) onRenameDay,
  required void Function(int weekIndex, int dayIndex) onDeleteDay,
  void Function(int weekIndex, int dayIndex)? onCloneDayToTarget,
  required void Function(int, int, Exercise) onDuplicateExercise,
  required void Function(int, int, String) onRemoveExercise,
  required void Function(int, int, String, {required bool up}) onMoveExercise,
  required void Function(int, int, String, {required bool up})
  onMoveExerciseWithinSuperset,
  required void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise,
  required void Function(int, int, String) onAddSetToExercise,
  required void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet,
  required void Function(int, int, String, int) onRemoveExerciseSet,
  required void Function(
    int,
    int,
    String,
    String)
  onAssignToSuperset,
  required void Function(int, int, String) onRemoveFromSuperset,
  required void Function(int, int, String) onAddExerciseToSuperset,
  bool readOnly = false,
  bool editorMode = false,
  String? planId,
  String? customerName,
  VoidCallback? onLogSession,
  String? phaseName,
  String? weekLabel,
}) {
  final l10n = AppLocalizations.of(context);
  final initialDay = _dayOrNull(session.routine, globalWeekIndex, dayIndex);
  if (initialDay == null) return Future.value();
  final dayId = initialDay.id;

  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (routeContext) {
        return ListenableBuilder(
          listenable: session,
          builder: (context, _) {
            final located = _locateDayById(session.routine, dayId);
            if (located == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (routeContext.mounted) {
                  Navigator.of(routeContext).maybePop();
                }
              });
              return Scaffold(
                backgroundColor: _SessionEditColors.backdrop,
                body: Center(
                  child: Text(
                    l10n.workoutBuilderNoDaysInWeek,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }
            return TrainingSessionEditBody(
              theme: theme,
              cs: cs,
              session: session,
              day: located.day,
              globalWeekIndex: located.weekIndex,
              dayIndex: located.dayIndex,
              onRenameDay: () =>
                  onRenameDay(located.weekIndex, located.dayIndex),
              onDeleteDay: () {
                Navigator.of(routeContext).maybePop();
                onDeleteDay(located.weekIndex, located.dayIndex);
              },
              onCloneDayToTarget: onCloneDayToTarget,
              onDuplicateExercise: onDuplicateExercise,
              onRemoveExercise: onRemoveExercise,
              onMoveExercise: onMoveExercise,
              onMoveExerciseWithinSuperset: onMoveExerciseWithinSuperset,
              onUpdateExercise: onUpdateExercise,
              onAddSetToExercise: onAddSetToExercise,
              onUpdateExerciseSet: onUpdateExerciseSet,
              onRemoveExerciseSet: onRemoveExerciseSet,
              onAssignToSuperset: onAssignToSuperset,
              onRemoveFromSuperset: onRemoveFromSuperset,
              onAddExerciseToSuperset: onAddExerciseToSuperset,
              readOnly: readOnly,
              editorMode: editorMode,
              planId: planId,
              customerName: customerName,
              onLogSession: onLogSession,
              phaseName: phaseName,
              weekLabel: weekLabel,
              onClose: () => Navigator.of(routeContext).maybePop(),
            );
          },
        );
      },
    ),
  );
}

Day? _dayOrNull(WorkoutRoutine routine, int weekIndex, int dayIndex) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  return week.days[dayIndex];
}

({int weekIndex, int dayIndex, Day day})? _locateDayById(
  WorkoutRoutine routine,
  String dayId,
) {
  for (var wi = 0; wi < routine.weeks.length; wi++) {
    final days = routine.weeks[wi].days;
    for (var di = 0; di < days.length; di++) {
      if (days[di].id == dayId) {
        return (weekIndex: wi, dayIndex: di, day: days[di]);
      }
    }
  }
  return null;
}

/// Session metrics derived from [Day.exercises] / [Exercise.effectiveSetDetails].
///
/// **Serie totali:** sum of `int.tryParse(set.sets) ?? 1` per set-detail row
/// (each row is one prescription block; [ExerciseSet.sets] is the block size).
/// **Volume stimato:** sum of setCount × reps × loadKg when both reps and a
/// numeric kg load are parseable from [ExerciseSet.reps] / [ExerciseSet.rpe]
/// (or [ExerciseSet.line]); otherwise unavailable ("—").
/// **Recupero medio:** always unavailable (no rest field on the model yet).
class SessionDayMetrics {
  const SessionDayMetrics({
    required this.exerciseCount,
    required this.totalSets,
    required this.estimatedVolumeKg,
  });

  final int exerciseCount;
  final int totalSets;

  /// Null when no load×reps pairs could be parsed.
  final double? estimatedVolumeKg;

  factory SessionDayMetrics.fromDay(Day day) {
    var totalSets = 0;
    var volume = 0.0;
    var volumeSamples = 0;
    for (final ex in day.exercises) {
      for (final set in ex.effectiveSetDetails) {
        final setCount = int.tryParse(set.sets.trim()) ?? 1;
        totalSets += setCount;
        final reps = _parsePositiveNumber(set.reps);
        final load = _parseLoadKg(set.rpe) ?? _parseLoadKg(set.line);
        if (reps != null && load != null) {
          volume += setCount * reps * load;
          volumeSamples++;
        }
      }
    }
    return SessionDayMetrics(
      exerciseCount: day.exercises.length,
      totalSets: totalSets,
      estimatedVolumeKg: volumeSamples > 0 ? volume : null,
    );
  }
}

double? _parsePositiveNumber(String raw) {
  final match = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(raw.trim());
  if (match == null) return null;
  final n = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  if (n == null || n <= 0) return null;
  return n;
}

/// Extracts kg from strings like "60 kg", "75kg", "1.800 kg".
double? _parseLoadKg(String raw) {
  final t = raw.trim().toLowerCase();
  if (t.isEmpty || t.contains('@')) return null;
  final match = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(?:kg|kgs)?',
    caseSensitive: false,
  ).firstMatch(t);
  if (match == null) return null;
  // Prefer explicit kg; bare numbers in rpe field are treated as load when
  // they look like weights (no leading @).
  if (!t.contains('kg') && RegExp(r'^@').hasMatch(raw.trim())) return null;
  final n = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  if (n == null || n <= 0) return null;
  return n;
}

String formatSessionVolumeKg(double kg) {
  final rounded = kg.round();
  final s = rounded.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    if (i > 0 && fromEnd % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

class TrainingSessionEditBody extends StatefulWidget {
  const TrainingSessionEditBody({
    super.key,
    required this.theme,
    required this.cs,
    required this.session,
    required this.day,
    required this.globalWeekIndex,
    required this.dayIndex,
    required this.onRenameDay,
    required this.onDeleteDay,
    this.onCloneDayToTarget,
    required this.onDuplicateExercise,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onMoveExerciseWithinSuperset,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    required this.onAssignToSuperset,
    required this.onRemoveFromSuperset,
    required this.onAddExerciseToSuperset,
    this.readOnly = false,
    this.editorMode = false,
    this.planId,
    this.customerName,
    this.onLogSession,
    this.phaseName,
    this.weekLabel,
    this.onClose,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final WorkoutBuilderSessionController session;
  final Day day;
  final int globalWeekIndex;
  final int dayIndex;
  final VoidCallback onRenameDay;
  final VoidCallback onDeleteDay;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final void Function(int, int, Exercise) onDuplicateExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(int, int, String, {required bool up})
  onMoveExerciseWithinSuperset;
  final void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(
    int,
    int,
    String,
    String)
  onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final bool readOnly;
  final bool editorMode;
  final String? planId;
  final String? customerName;
  final VoidCallback? onLogSession;
  final String? phaseName;
  final String? weekLabel;
  final VoidCallback? onClose;

  @override
  State<TrainingSessionEditBody> createState() =>
      _TrainingSessionEditBodyState();
}

class _TrainingSessionEditBodyState extends State<TrainingSessionEditBody> {
  var _didEnrichNames = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_enrichBareVariantNames());
    });
  }

  Future<void> _enrichBareVariantNames() async {
    if (_didEnrichNames || widget.readOnly || !mounted) return;
    _didEnrichNames = true;
    try {
      final roots = await CustomExerciseRepository().getTree();
      if (!mounted) return;
      final updates = libraryExerciseNamesToEnrich(
        day: widget.day,
        libraryRoots: roots,
      );
      for (final entry in updates.entries) {
        widget.onUpdateExercise(
          widget.globalWeekIndex,
          widget.dayIndex,
          entry.key,
          name: entry.value,
        );
      }
    } catch (_) {
      // Best-effort backfill; picker path already stores full display names.
    }
  }

  void _openLibraryPicker(BuildContext context) {
    showExerciseLibraryPickPanel(
      context: context,
      theme: widget.theme,
      cs: widget.cs,
      onPicked: (item, displayName) {
        final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
        widget.session.addExerciseToDay(
          weekIndex: widget.globalWeekIndex,
          dayIndex: widget.dayIndex,
          exercise: buildExerciseFromPrescription(
            id: exId,
            name: displayName,
            note: '',
            setDetails: defaultExerciseSetDetails(),
            customExerciseId: item.id,
          ),
        );
      },
    );
  }

  void _createSuperset() {
    if (widget.readOnly || widget.day.exercises.isEmpty) return;
    final target = widget.day.exercises.firstWhere(
      (e) => e.supersetGroupId == null || e.supersetGroupId!.isEmpty,
      orElse: () => widget.day.exercises.first,
    );
    final groupId = 'ss_${DateTime.now().millisecondsSinceEpoch}';
    widget.onAssignToSuperset(
      widget.globalWeekIndex,
      widget.dayIndex,
      target.id,
      groupId,
    );
  }

  void _openHistory(BuildContext context) {
    if (widget.planId == null || widget.planId!.isEmpty) return;
    navigateTo(
      context,
      workoutDiaryPath(
        planId: widget.planId,
        sessionKey: WorkoutRoutine.sessionKey(
          widget.globalWeekIndex,
          widget.dayIndex,
        ),
      ),
    );
  }

  void _openAthletePreview(BuildContext context) {
    if (widget.planId == null || widget.planId!.isEmpty) return;
    // Same destination as history for now: athlete-facing diary for this day.
    navigateTo(
      context,
      workoutDiaryPath(
        planId: widget.planId,
        sessionKey: WorkoutRoutine.sessionKey(
          widget.globalWeekIndex,
          widget.dayIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.cs;
    final session = widget.session;
    final day = widget.day;
    final globalWeekIndex = widget.globalWeekIndex;
    final dayIndex = widget.dayIndex;
    final readOnly = widget.readOnly;
    final editorMode = widget.editorMode;
    final planId = widget.planId;
    final customerName = widget.customerName;
    final onLogSession = widget.onLogSession;
    final onClose = widget.onClose;
    final onRenameDay = widget.onRenameDay;
    final onDeleteDay = widget.onDeleteDay;
    final onCloneDayToTarget = widget.onCloneDayToTarget;
    final onDuplicateExercise = widget.onDuplicateExercise;
    final onRemoveExercise = widget.onRemoveExercise;
    final onMoveExercise = widget.onMoveExercise;
    final onMoveExerciseWithinSuperset = widget.onMoveExerciseWithinSuperset;
    final onUpdateExercise = widget.onUpdateExercise;
    final onAddSetToExercise = widget.onAddSetToExercise;
    final onUpdateExerciseSet = widget.onUpdateExerciseSet;
    final onRemoveExerciseSet = widget.onRemoveExerciseSet;
    final onAssignToSuperset = widget.onAssignToSuperset;
    final onRemoveFromSuperset = widget.onRemoveFromSuperset;
    final onAddExerciseToSuperset = widget.onAddExerciseToSuperset;

    final l10n = AppLocalizations.of(context);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final maxWidth = isDesktop
        ? AppBreakpoints.sessionSheetMaxWidth
        : double.infinity;
    final dayName = day.name.trim().isEmpty
        ? l10n.workoutBuilderDayNumbered(dayIndex + 1)
        : day.name.trim();
    final phase = (widget.phaseName ?? '').trim();
    final week = (widget.weekLabel ?? '').trim();
    final subtitle = [
      if (phase.isNotEmpty) phase,
      if (week.isNotEmpty) week,
    ].join(' · ');
    final metrics = SessionDayMetrics.fromDay(day);
    final showPreview =
        editorMode && (planId ?? '').isNotEmpty && !readOnly;

    return ColoredBox(
      color: _SessionEditColors.backdrop,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 16 : 0,
                vertical: isDesktop ? 16 : 0,
              ),
              child: Material(
                color: _SessionEditColors.card,
                elevation: isDesktop ? 8 : 0,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 16 : 0),
                  side: isDesktop
                      ? const BorderSide(color: _SessionEditColors.border)
                      : BorderSide.none,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SessionEditHeader(
                      theme: theme,
                      cs: cs,
                      l10n: l10n,
                      dayName: dayName,
                      subtitle: subtitle,
                      readOnly: readOnly,
                      editorMode: editorMode,
                      customerName: customerName,
                      showHistory: editorMode && (planId ?? '').isNotEmpty,
                      showClone: onCloneDayToTarget != null && !readOnly,
                      onClose:
                          onClose ?? () => Navigator.of(context).maybePop(),
                      onRename: readOnly ? null : onRenameDay,
                      onLogSession: readOnly || onLogSession == null
                          ? null
                          : onLogSession,
                      onClone: readOnly || onCloneDayToTarget == null
                          ? null
                          : () => onCloneDayToTarget(
                                globalWeekIndex,
                                dayIndex,
                              ),
                      onHistory: () => _openHistory(context),
                      onDelete: readOnly ? null : onDeleteDay,
                      onCancel:
                          onClose ?? () => Navigator.of(context).maybePop(),
                      onSave:
                          onClose ?? () => Navigator.of(context).maybePop(),
                    ),
                    _SessionMetricsBar(
                      theme: theme,
                      l10n: l10n,
                      metrics: metrics,
                    ),
                    Expanded(
                      child: WorkoutDayExerciseList(
                        theme: theme,
                        colorScheme: cs,
                        session: session,
                        weekIndex: globalWeekIndex,
                        dayIndex: dayIndex,
                        day: day,
                        sessionEditStyle: true,
                        athleteName: customerName,
                        readOnly: readOnly,
                        onAddExercise: readOnly
                            ? null
                            : (w, d) => _openLibraryPicker(context),
                        onCreateSuperset:
                            readOnly ? null : _createSuperset,
                        onDuplicateExercise: onDuplicateExercise,
                        onRemoveExercise: onRemoveExercise,
                        onMoveExercise: onMoveExercise,
                        onMoveExerciseWithinSuperset:
                            onMoveExerciseWithinSuperset,
                        onUpdateExercise: onUpdateExercise,
                        onAddSetToExercise: onAddSetToExercise,
                        onUpdateExerciseSet: onUpdateExerciseSet,
                        onRemoveExerciseSet: onRemoveExerciseSet,
                        onAssignToSuperset: onAssignToSuperset,
                        onRemoveFromSuperset: onRemoveFromSuperset,
                        onAddExerciseToSuperset: onAddExerciseToSuperset,
                                ),
                    ),
                    _SessionEditFooter(
                      theme: theme,
                      l10n: l10n,
                      showAthletePreview: showPreview,
                      onAthletePreview: () => _openAthletePreview(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionEditHeader extends StatelessWidget {
  const _SessionEditHeader({
    required this.theme,
    required this.cs,
    required this.l10n,
    required this.dayName,
    required this.subtitle,
    required this.readOnly,
    required this.editorMode,
    this.customerName,
    required this.showHistory,
    required this.showClone,
    required this.onClose,
    this.onRename,
    this.onLogSession,
    this.onClone,
    required this.onHistory,
    this.onDelete,
    required this.onCancel,
    required this.onSave,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final String dayName;
  final String subtitle;
  final bool readOnly;
  final bool editorMode;
  final String? customerName;
  final bool showHistory;
  final bool showClone;
  final VoidCallback onClose;
  final VoidCallback? onRename;
  final VoidCallback? onLogSession;
  final VoidCallback? onClone;
  final VoidCallback onHistory;
  final VoidCallback? onDelete;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final assigned = (customerName ?? '').trim();
    return Material(
      color: _SessionEditColors.header,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _SessionEditColors.border),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 22),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: StitchM3Theme.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: StitchM3Theme.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 20,
                    color: StitchM3Theme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n.workoutSessionEditTitleWithDay(dayName),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onRename != null)
                            IconButton(
                              tooltip: l10n.workoutBuilderRenameDayTitle,
                              onPressed: onRename,
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                        ],
                      ),
                      if (editorMode && assigned.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: StitchM3Theme.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: StitchM3Theme.accent.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: StitchM3Theme.accent,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  l10n.workoutSessionAssignedPlanPill(assigned),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (showClone || showHistory || onDelete != null || onLogSession != null)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _SessionEditColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showClone)
                                TextButton.icon(
                                  onPressed: onClone,
                                  icon: const Icon(Icons.copy_outlined, size: 16),
                                  label: Text(l10n.workoutSessionDuplicateShort),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    foregroundColor: cs.onSurface,
                                  ),
                                ),
                              if (showHistory)
                                TextButton.icon(
                                  onPressed: onHistory,
                                  icon: const Icon(Icons.history, size: 16),
                                  label: Text(l10n.workoutSessionHistoryShort),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    foregroundColor: cs.onSurface,
                                  ),
                                ),
                              if (onLogSession != null)
                                TextButton.icon(
                                  onPressed: onLogSession,
                                  icon: const Icon(
                                    Icons.edit_note_outlined,
                                    size: 16,
                                  ),
                                  label: Text(l10n.workoutBuilderLogSession),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    foregroundColor: cs.onSurface,
                                  ),
                                ),
                              if (onDelete != null)
                                IconButton(
                                  tooltip: l10n.workoutBuilderDeleteDayMenu,
                                  onPressed: onDelete,
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: cs.error,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ),
                      if (!readOnly) ...[
                        TextButton(
                          onPressed: onCancel,
                          child: Text(l10n.workoutEditorCancel),
                        ),
                        FilledButton.icon(
                          onPressed: onSave,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(l10n.workoutSessionSaveChanges),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionMetricsBar extends StatelessWidget {
  const _SessionMetricsBar({
    required this.theme,
    required this.l10n,
    required this.metrics,
  });

  final ThemeData theme;
  final AppLocalizations l10n;
  final SessionDayMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final volumeText = metrics.estimatedVolumeKg == null
        ? l10n.workoutSessionMetricUnavailable
        : l10n.workoutSessionVolumeKg(
            formatSessionVolumeKg(metrics.estimatedVolumeKg!),
          );
    return Container(
      color: _SessionEditColors.metrics,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tiles = [
            _MetricTile(
              theme: theme,
              icon: Icons.grid_view_rounded,
              iconColor: _SessionEditColors.metricBlue,
              label: l10n.workoutSessionMetricExercises,
              value: '${metrics.exerciseCount}',
            ),
            _MetricTile(
              theme: theme,
              icon: Icons.autorenew,
              iconColor: _SessionEditColors.metricIndigo,
              label: l10n.workoutSessionMetricTotalSets,
              value: l10n.workoutSessionMetricSetsCount(metrics.totalSets),
            ),
            _MetricTile(
              theme: theme,
              icon: Icons.fitness_center,
              iconColor: _SessionEditColors.metricEmerald,
              label: l10n.workoutSessionMetricEstimatedVolume,
              value: volumeText,
            ),
            _MetricTile(
              theme: theme,
              icon: Icons.timer_outlined,
              iconColor: _SessionEditColors.metricAmber,
              label: l10n.workoutSessionMetricAvgRest,
              value: l10n.workoutSessionMetricUnavailable,
            ),
          ];
          if (constraints.maxWidth < 640) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final tile in tiles)
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: tile,
                  ),
              ],
            );
          }
          return Row(
            children: [
              for (final tile in tiles) Expanded(child: tile),
            ],
          );
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final ThemeData theme;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionEditFooter extends StatelessWidget {
  const _SessionEditFooter({
    required this.theme,
    required this.l10n,
    required this.showAthletePreview,
    required this.onAthletePreview,
  });

  final ThemeData theme;
  final AppLocalizations l10n;
  final bool showAthletePreview;
  final VoidCallback onAthletePreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: _SessionEditColors.footer,
        border: Border(top: BorderSide(color: _SessionEditColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF34D399),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.workoutSessionAutosaveActive,
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          if (showAthletePreview)
            TextButton(
              onPressed: onAthletePreview,
              child: Text(l10n.workoutSessionAthletePreview),
            ),
        ],
      ),
    );
  }
}
