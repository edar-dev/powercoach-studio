import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/session_execution.dart';
import '../../domain/session_log_draft.dart';
import 'session_log_exercise_section.dart';

/// Result of the session log bottom sheet.
class SessionLogResult {
  const SessionLogResult({
    required this.exercises,
    required this.notes,
  });

  final List<ExecutedExercise> exercises;
  final String notes;
}

/// Checklist of planned exercises with optional reps/load per set and notes.
Future<SessionLogResult?> showSessionLogSheet({
  required BuildContext context,
  required List<Exercise> plannedExercises,
  List<ExecutedExercise>? initialExercises,
  String initialNotes = '',
}) async {
  return showModalBottomSheet<SessionLogResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SessionLogSheetBody(
      plannedExercises: plannedExercises,
      initialExercises: initialExercises,
      initialNotes: initialNotes,
    ),
  );
}

class SessionLogSheetBody extends StatefulWidget {
  const SessionLogSheetBody({
    super.key,
    required this.plannedExercises,
    this.initialExercises,
    this.initialNotes = '',
  });

  final List<Exercise> plannedExercises;
  final List<ExecutedExercise>? initialExercises;
  final String initialNotes;

  @override
  State<SessionLogSheetBody> createState() => _SessionLogSheetBodyState();
}

class _SessionLogSheetBodyState extends State<SessionLogSheetBody> {
  late List<SessionLogExerciseDraft> _drafts;
  late final Map<String, bool> _expanded;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _drafts = buildSessionLogDrafts(
      plannedExercises: widget.plannedExercises,
      initialExercises: widget.initialExercises,
    );
    _expanded = {
      for (final draft in _drafts) draft.exerciseId: _drafts.length <= 3,
    };
    _notesController = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateDraft(int index, SessionLogExerciseDraft draft) {
    setState(() => _drafts[index] = draft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
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
              Expanded(
                child: ListView.builder(
                  itemCount: _drafts.length,
                  itemBuilder: (context, index) {
                    final draft = _drafts[index];
                    return SessionLogExerciseSection(
                      draft: draft,
                      l10n: l10n,
                      expanded: _expanded[draft.exerciseId] ?? false,
                      onExpandedChanged: (value) {
                        setState(() => _expanded[draft.exerciseId] = value);
                      },
                      onCompletedChanged: (value) {
                        _updateDraft(
                          index,
                          SessionLogExerciseDraft(
                            exerciseId: draft.exerciseId,
                            name: draft.name,
                            customExerciseId: draft.customExerciseId,
                            completed: value,
                            sets: draft.sets,
                          ),
                        );
                      },
                      onSetChanged: (setIndex, setDraft) {
                        final sets = List<SessionLogSetDraft>.from(draft.sets);
                        sets[setIndex] = setDraft;
                        _updateDraft(
                          index,
                          SessionLogExerciseDraft(
                            exerciseId: draft.exerciseId,
                            name: draft.name,
                            customExerciseId: draft.customExerciseId,
                            completed: draft.completed,
                            sets: sets,
                          ),
                        );
                      },
                      onAddSet: () {
                        final sets = List<SessionLogSetDraft>.from(draft.sets)
                          ..add(SessionLogSetDraft());
                        _updateDraft(
                          index,
                          SessionLogExerciseDraft(
                            exerciseId: draft.exerciseId,
                            name: draft.name,
                            customExerciseId: draft.customExerciseId,
                            completed: draft.completed,
                            sets: sets,
                          ),
                        );
                        setState(() => _expanded[draft.exerciseId] = true);
                      },
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
                      exercises: sessionLogDraftsToExecuted(_drafts),
                      notes: _notesController.text.trim(),
                    ),
                  );
                },
                child: Text(l10n.sessionLogSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
