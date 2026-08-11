import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/session_execution.dart';
import '../../domain/session_log_draft.dart';
import 'session_check_in_section.dart';
import 'session_log_exercise_section.dart';

/// Result of a session log edit (from the modal sheet or the gym-mode runner).
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

/// Shared session-log editor: checklist of planned exercises with optional
/// reps/load per set, an optional RPE/pain check-in, and free-text notes.
///
/// Used both inside [session_log_sheet]'s modal chrome (bounded height,
/// [expandableList] = true) and directly inside a full-page scroll view for
/// gym mode ([expandableList] = false, [compact] = false for larger rows).
class SessionLogFormBody extends StatefulWidget {
  const SessionLogFormBody({
    super.key,
    required this.plannedExercises,
    this.initialExercises,
    this.initialNotes = '',
    this.initialSessionRpe,
    this.initialPainLevel,
    this.initialPainLocation,
    required this.onSave,
    required this.saveLabel,
    this.title,
    this.expandableList = false,
    this.compact = false,
  });

  final List<Exercise> plannedExercises;
  final List<ExecutedExercise>? initialExercises;
  final String initialNotes;
  final int? initialSessionRpe;
  final int? initialPainLevel;
  final String? initialPainLocation;
  final ValueChanged<SessionLogResult> onSave;
  final String saveLabel;
  final String? title;

  /// When true, the exercise list is wrapped in `Expanded` + `ListView`
  /// (requires a bounded-height ancestor, e.g. the sheet's `ConstrainedBox`).
  /// When false, the list renders as a plain column for use inside an outer
  /// scroll view (full-page gym runner).
  final bool expandableList;

  /// When false, set rows/checkboxes use larger (48dp+) touch targets.
  final bool compact;

  @override
  State<SessionLogFormBody> createState() => SessionLogFormBodyState();
}

class SessionLogFormBodyState extends State<SessionLogFormBody> {
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

  void _handleSave() {
    final painLocation = _painLocationController.text.trim();
    widget.onSave(
      SessionLogResult(
        exercises: sessionLogDraftsToExecuted(_drafts),
        notes: _notesController.text.trim(),
        sessionRpe: _sessionRpe,
        painLevel: _painLevel,
        painLocation: painLocation.isEmpty ? null : painLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget buildSection(int index) {
      final draft = _drafts[index];
      return SessionLogExerciseSection(
        draft: draft,
        l10n: l10n,
        compact: widget.compact,
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
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: widget.expandableList ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          l10n.sessionLogExercisesLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.expandableList)
          Expanded(
            child: ListView.builder(
              itemCount: _drafts.length,
              itemBuilder: (context, index) => buildSection(index),
            ),
          )
        else
          for (var i = 0; i < _drafts.length; i++) buildSection(i),
        const SizedBox(height: 16),
        SessionCheckInSection(
          l10n: l10n,
          sessionRpe: _sessionRpe,
          painLevel: _painLevel,
          painLocationController: _painLocationController,
          onSessionRpeChanged: (value) => setState(() => _sessionRpe = value),
          onPainLevelChanged: (value) => setState(() => _painLevel = value),
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
          onPressed: _handleSave,
          style: widget.compact
              ? null
              : FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}
