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
    this.sessionRpe,
    this.painLevel,
    this.painLocation,
  });

  final List<ExecutedExercise> exercises;
  final String notes;
  final int? sessionRpe;
  final int? painLevel;
  final String? painLocation;
}

/// Checklist of planned exercises with optional reps/load per set and notes.
Future<SessionLogResult?> showSessionLogSheet({
  required BuildContext context,
  required List<Exercise> plannedExercises,
  List<ExecutedExercise>? initialExercises,
  String initialNotes = '',
  int? initialSessionRpe,
  int? initialPainLevel,
  String? initialPainLocation,
}) async {
  return showModalBottomSheet<SessionLogResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SessionLogSheetBody(
      plannedExercises: plannedExercises,
      initialExercises: initialExercises,
      initialNotes: initialNotes,
      initialSessionRpe: initialSessionRpe,
      initialPainLevel: initialPainLevel,
      initialPainLocation: initialPainLocation,
    ),
  );
}

class SessionLogSheetBody extends StatefulWidget {
  const SessionLogSheetBody({
    super.key,
    required this.plannedExercises,
    this.initialExercises,
    this.initialNotes = '',
    this.initialSessionRpe,
    this.initialPainLevel,
    this.initialPainLocation,
  });

  final List<Exercise> plannedExercises;
  final List<ExecutedExercise>? initialExercises;
  final String initialNotes;
  final int? initialSessionRpe;
  final int? initialPainLevel;
  final String? initialPainLocation;

  @override
  State<SessionLogSheetBody> createState() => _SessionLogSheetBodyState();
}

class _SessionLogSheetBodyState extends State<SessionLogSheetBody> {
  late List<SessionLogExerciseDraft> _drafts;
  late final Map<String, bool> _expanded;
  late final TextEditingController _notesController;
  late final TextEditingController _painLocationController;
  int? _sessionRpe;
  int? _painLevel;

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
    _sessionRpe = widget.initialSessionRpe;
    _painLevel = widget.initialPainLevel;
    _painLocationController = TextEditingController(
      text: widget.initialPainLocation ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _painLocationController.dispose();
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
              const SizedBox(height: 16),
              _SessionCheckInSection(
                l10n: l10n,
                sessionRpe: _sessionRpe,
                painLevel: _painLevel,
                painLocationController: _painLocationController,
                onSessionRpeChanged: (value) =>
                    setState(() => _sessionRpe = value),
                onPainLevelChanged: (value) =>
                    setState(() => _painLevel = value),
              ),
              const SizedBox(height: 16),
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
                  final painLocation = _painLocationController.text.trim();
                  Navigator.of(context).pop(
                    SessionLogResult(
                      exercises: sessionLogDraftsToExecuted(_drafts),
                      notes: _notesController.text.trim(),
                      sessionRpe: _sessionRpe,
                      painLevel: _painLevel,
                      painLocation: painLocation.isEmpty ? null : painLocation,
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

/// Optional post-session check-in: session RPE and pain level/location.
/// Tapping a selected chip again clears that value (fully skippable).
class _SessionCheckInSection extends StatelessWidget {
  const _SessionCheckInSection({
    required this.l10n,
    required this.sessionRpe,
    required this.painLevel,
    required this.painLocationController,
    required this.onSessionRpeChanged,
    required this.onPainLevelChanged,
  });

  final AppLocalizations l10n;
  final int? sessionRpe;
  final int? painLevel;
  final TextEditingController painLocationController;
  final ValueChanged<int?> onSessionRpeChanged;
  final ValueChanged<int?> onPainLevelChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sessionLogCheckInTitle,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.sessionLogRpeLabel, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        _ScaleChipRow(
          min: 1,
          max: 10,
          value: sessionRpe,
          onChanged: onSessionRpeChanged,
        ),
        const SizedBox(height: 12),
        Text(l10n.sessionLogPainLabel, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        _ScaleChipRow(
          min: 0,
          max: 10,
          value: painLevel,
          onChanged: onPainLevelChanged,
        ),
        if (painLevel != null && painLevel! > 0) ...[
          const SizedBox(height: 8),
          TextField(
            controller: painLocationController,
            decoration: InputDecoration(
              hintText: l10n.sessionLogPainLocationHint,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScaleChipRow extends StatelessWidget {
  const _ScaleChipRow({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  final int min;
  final int max;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = min; i <= max; i++)
          ChoiceChip(
            label: Text('$i'),
            selected: value == i,
            onSelected: (selected) => onChanged(selected ? i : null),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
      ],
    );
  }
}
