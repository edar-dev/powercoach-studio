import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/session_execution.dart';

/// Result of the session log bottom sheet.
class SessionLogResult {
  const SessionLogResult({
    required this.exercises,
    required this.notes,
  });

  final List<ExecutedExercise> exercises;
  final String notes;
}

/// Quick checklist of planned exercises plus optional session notes.
Future<SessionLogResult?> showSessionLogSheet({
  required BuildContext context,
  required List<Exercise> plannedExercises,
}) async {
  return showModalBottomSheet<SessionLogResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _SessionLogSheetBody(plannedExercises: plannedExercises),
  );
}

class _SessionLogSheetBody extends StatefulWidget {
  const _SessionLogSheetBody({required this.plannedExercises});

  final List<Exercise> plannedExercises;

  @override
  State<_SessionLogSheetBody> createState() => _SessionLogSheetBodyState();
}

class _SessionLogSheetBodyState extends State<_SessionLogSheetBody> {
  late final Map<String, bool> _checked;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checked = {
      for (final e in widget.plannedExercises) e.id: true,
    };
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<ExecutedExercise> _buildExecuted() {
    return widget.plannedExercises.map((exercise) {
      final done = _checked[exercise.id] ?? false;
      final sets = exercise.setDetails ?? const [];
      return ExecutedExercise(
        exerciseId: exercise.id,
        name: exercise.name,
        customExerciseId: exercise.customExerciseId,
        completed: done,
        sets: sets
            .map(
              (s) => ExecutedSet(
                reps: s.reps,
                load: s.rpe,
                completed: done,
              ),
            )
            .toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sessionLogTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sessionLogExercisesLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.plannedExercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.plannedExercises[index];
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _checked[exercise.id] ?? false,
                    onChanged: (v) {
                      setState(() => _checked[exercise.id] = v ?? false);
                    },
                    title: Text(exercise.name),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: l10n.sessionLogNotesHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  SessionLogResult(
                    exercises: _buildExecuted(),
                    notes: _notesController.text.trim(),
                  ),
                );
              },
              child: Text(l10n.sessionLogSave),
            ),
          ],
        ),
      ),
    );
  }
}
