import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/density_block.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../workout_builder_session_controller.dart';
import 'workout_dashed_button.dart';
import 'workout_training_helpers.dart';

/// Opens the dedicated density-group management bottom sheet for the workout builder.
Future<void> showWorkoutBuilderSupersetEditorSheet({
  required BuildContext context,
  required WorkoutBuilderSessionController session,
  required int weekIndex,
  required int dayIndex,
  required String supersetGroupId,
  required ThemeData theme,
  required ColorScheme colorScheme,
  required void Function(int weekIndex, int dayIndex, String supersetGroupId)
  onAddExerciseToSuperset,
  required void Function(int weekIndex, int dayIndex, String exerciseId)
  onRemoveExercise,
  required void Function(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    required bool up,
  })
  onMoveExerciseWithinSuperset,
  required void Function(int weekIndex, int dayIndex, String exerciseId)
  onRemoveFromSuperset,
  required void Function(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
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
  void Function(int weekIndex, int dayIndex, String groupId, DensityBlockConfig config)?
  onSetDensityBlock,
}) {
  final day = _dayOrNull(session.routine, weekIndex, dayIndex);
  final density =
      day == null ? null : resolveDensityBlock(day, supersetGroupId);
  final l10n = AppLocalizations.of(context);
  final title = switch (density?.type) {
    DensityBlockType.circuit => l10n.builderCircuitPanelTitle,
    DensityBlockType.emom => l10n.builderEmomPanelTitle,
    _ => l10n.builderSupersetPanelTitle,
  };
  return showAppBottomSheet<void>(
    context: context,
    title: title,
    fullScreen: true,
    bodyBuilder: (sheetContext) => ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final exercises = getSupersetExercises(
          routine: session.routine,
          weekIndex: weekIndex,
          dayIndex: dayIndex,
          supersetGroupId: supersetGroupId,
        );
        final liveDay = _dayOrNull(session.routine, weekIndex, dayIndex);
        final liveDensity = liveDay == null
            ? null
            : resolveDensityBlock(liveDay, supersetGroupId);
        return _WorkoutBuilderSupersetEditorBody(
          theme: theme,
          colorScheme: colorScheme,
          exercises: exercises,
          densityConfig: liveDensity,
          onAddExercise: () =>
              onAddExerciseToSuperset(weekIndex, dayIndex, supersetGroupId),
          onRemoveExercise: (exerciseId) =>
              onRemoveExercise(weekIndex, dayIndex, exerciseId),
          onMoveUp: (exerciseId) => onMoveExerciseWithinSuperset(
            weekIndex,
            dayIndex,
            exerciseId,
            up: true,
          ),
          onMoveDown: (exerciseId) => onMoveExerciseWithinSuperset(
            weekIndex,
            dayIndex,
            exerciseId,
            up: false,
          ),
          onRemoveFromSuperset: (exerciseId) =>
              onRemoveFromSuperset(weekIndex, dayIndex, exerciseId),
          onEditExercise: (
            exerciseId,
            name,
            sets,
            reps,
            rpe,
            note, {
            setDetails,
            shortName,
            prescriptionScope,
          }) =>
              onUpdateExercise(
                weekIndex,
                dayIndex,
                exerciseId,
                name: name,
                sets: sets,
                reps: reps,
                rpe: rpe,
                note: note,
                setDetails: setDetails,
                shortName: shortName,
                prescriptionScope: prescriptionScope,
              ),
          onSaveDensity: onSetDensityBlock == null
              ? null
              : (config) => onSetDensityBlock(
                    weekIndex,
                    dayIndex,
                    supersetGroupId,
                    config,
                  ),
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

class _WorkoutBuilderSupersetEditorBody extends StatelessWidget {
  const _WorkoutBuilderSupersetEditorBody({
    required this.theme,
    required this.colorScheme,
    required this.exercises,
    required this.densityConfig,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemoveFromSuperset,
    required this.onEditExercise,
    this.onSaveDensity,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<Exercise> exercises;
  final DensityBlockConfig? densityConfig;
  final VoidCallback onAddExercise;
  final void Function(String exerciseId) onRemoveExercise;
  final void Function(String exerciseId) onMoveUp;
  final void Function(String exerciseId) onMoveDown;
  final void Function(String exerciseId) onRemoveFromSuperset;
  final void Function(
    String exerciseId,
    String name,
    String sets,
    String reps,
    String rpe,
    String note, {
    List<ExerciseSet>? setDetails,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
  })
  onEditExercise;
  final void Function(DensityBlockConfig config)? onSaveDensity;

  void _openEditDialog(BuildContext context, Exercise exercise) {
    showEditExerciseDialog(
      context,
      theme,
      colorScheme,
      exercise.name,
      exercise.sets,
      exercise.reps,
      exercise.rpe,
      exercise.note,
      (name, sets, reps, rpe, note) => onEditExercise(
        exercise.id,
        name,
        sets,
        reps,
        rpe,
        note,
      ),
      initialShortName: exercise.shortName,
      initialScope: exercise.prescriptionScope,
      initialSetDetails: exercise.effectiveSetDetails,
      onSaveWithSets:
          (
            name,
            note,
            setDetails, {
            shortName = '',
            prescriptionScope = ExercisePrescriptionScope.perWeek,
          }) => onEditExercise(
            exercise.id,
            name,
            exercise.sets,
            exercise.reps,
            exercise.rpe,
            note,
            setDetails: setDetails,
            shortName: shortName,
            prescriptionScope: prescriptionScope,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (exercises.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onSaveDensity != null) ...[
            _DensityBlockEditor(
              theme: theme,
              colorScheme: colorScheme,
              initial: densityConfig ??
                  const DensityBlockConfig(type: DensityBlockType.superset),
              onSave: onSaveDensity!,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            l10n.builderSupersetEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          WorkoutDashedButton(
            icon: Icons.add,
            label: l10n.builderSupersetAddExercise,
            onPressed: onAddExercise,
          ),
        ],
      );
    }

    final lead = exercises.first;
    final prescription = supersetPrescriptionSummary(lead);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onSaveDensity != null) ...[
          _DensityBlockEditor(
            theme: theme,
            colorScheme: colorScheme,
            initial: densityConfig ??
                const DensityBlockConfig(type: DensityBlockType.superset),
            onSave: onSaveDensity!,
          ),
          const SizedBox(height: 16),
        ],
        if (prescription.isNotEmpty) ...[
          Text(
            l10n.builderSupersetPrescriptionLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: StitchM3Theme.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...List.generate(exercises.length, (index) {
          final exercise = exercises[index];
          final canMoveUp =
              index > 0 &&
              exercises[index - 1].supersetGroupId == exercise.supersetGroupId;
          final canMoveDown =
              index < exercises.length - 1 &&
              exercises[index + 1].supersetGroupId == exercise.supersetGroupId;
          return Padding(
            padding: EdgeInsets.only(bottom: index == exercises.length - 1 ? 0 : 8),
            child: Material(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              child: InkWell(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                onTap: () => _openEditDialog(context, exercise),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}.',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (exercise.note.trim().isNotEmpty)
                              Text(
                                exercise.note.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.workoutBuilderMoveUp,
                        onPressed: canMoveUp ? () => onMoveUp(exercise.id) : null,
                        icon: const Icon(Icons.arrow_upward, size: 20),
                      ),
                      IconButton(
                        tooltip: l10n.workoutBuilderMoveDown,
                        onPressed:
                            canMoveDown ? () => onMoveDown(exercise.id) : null,
                        icon: const Icon(Icons.arrow_downward, size: 20),
                      ),
                      PopupMenuButton<_SupersetRowAction>(
                        tooltip: l10n.workoutBuilderMoreActions,
                        onSelected: (action) {
                          switch (action) {
                            case _SupersetRowAction.unlink:
                              onRemoveFromSuperset(exercise.id);
                            case _SupersetRowAction.delete:
                              onRemoveExercise(exercise.id);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: _SupersetRowAction.unlink,
                            child: Text(l10n.workoutBuilderRemoveFromSuperset),
                          ),
                          PopupMenuItem(
                            value: _SupersetRowAction.delete,
                            child: Text(l10n.workoutBuilderDeleteExercise),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        WorkoutDashedButton(
          icon: Icons.add,
          label: l10n.builderSupersetAddExercise,
          onPressed: onAddExercise,
        ),
      ],
    );
  }
}

class _DensityBlockEditor extends StatefulWidget {
  const _DensityBlockEditor({
    required this.theme,
    required this.colorScheme,
    required this.initial,
    required this.onSave,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final DensityBlockConfig initial;
  final void Function(DensityBlockConfig config) onSave;

  @override
  State<_DensityBlockEditor> createState() => _DensityBlockEditorState();
}

class _DensityBlockEditorState extends State<_DensityBlockEditor> {
  late DensityBlockType _type;
  late final TextEditingController _rounds;
  late final TextEditingController _rest;
  late final TextEditingController _interval;
  late final TextEditingController _duration;

  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _rounds = TextEditingController(text: _numText(widget.initial.rounds));
    _rest = TextEditingController(text: _numText(widget.initial.restSeconds));
    _interval =
        TextEditingController(text: _numText(widget.initial.intervalSeconds));
    _duration =
        TextEditingController(text: _numText(widget.initial.durationMinutes));
  }

  @override
  void didUpdateWidget(covariant _DensityBlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _type = widget.initial.type;
      _rounds.text = _numText(widget.initial.rounds);
      _rest.text = _numText(widget.initial.restSeconds);
      _interval.text = _numText(widget.initial.intervalSeconds);
      _duration.text = _numText(widget.initial.durationMinutes);
    }
  }

  @override
  void dispose() {
    _rounds.dispose();
    _rest.dispose();
    _interval.dispose();
    _duration.dispose();
    super.dispose();
  }

  String _numText(int? value) => value?.toString() ?? '';

  int? _parseOptionalInt(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  void _save() {
    final config = switch (_type) {
      DensityBlockType.superset => const DensityBlockConfig(
          type: DensityBlockType.superset,
        ),
      DensityBlockType.circuit => DensityBlockConfig(
          type: DensityBlockType.circuit,
          rounds: _parseOptionalInt(_rounds.text),
          restSeconds: _parseOptionalInt(_rest.text),
        ),
      DensityBlockType.emom => DensityBlockConfig(
          type: DensityBlockType.emom,
          intervalSeconds: _parseOptionalInt(_interval.text),
          durationMinutes: _parseOptionalInt(_duration.text),
        ),
    };
    widget.onSave(config);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.densityBlockTypeLabel,
          style: widget.theme.textTheme.labelSmall?.copyWith(
            color: widget.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<DensityBlockType>(
          segments: [
            ButtonSegment(
              value: DensityBlockType.superset,
              label: Text(l10n.densityBlockTypeSuperset),
            ),
            ButtonSegment(
              value: DensityBlockType.circuit,
              label: Text(l10n.densityBlockTypeCircuit),
            ),
            ButtonSegment(
              value: DensityBlockType.emom,
              label: Text(l10n.densityBlockTypeEmom),
            ),
          ],
          selected: {_type},
          onSelectionChanged: (values) {
            setState(() => _type = values.first);
          },
        ),
        const SizedBox(height: 12),
        if (_type == DensityBlockType.circuit) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rounds,
                  decoration: InputDecoration(
                    labelText: l10n.densityRoundsLabel,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _rest,
                  decoration: InputDecoration(
                    labelText: l10n.densityRestSecondsLabel,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
        if (_type == DensityBlockType.emom) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _interval,
                  decoration: InputDecoration(
                    labelText: l10n.densityIntervalSecondsLabel,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _duration,
                  decoration: InputDecoration(
                    labelText: l10n.densityDurationMinutesLabel,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonal(
            onPressed: _save,
            child: Text(l10n.densityBlockSave),
          ),
        ),
      ],
    );
  }
}

enum _SupersetRowAction { unlink, delete }
