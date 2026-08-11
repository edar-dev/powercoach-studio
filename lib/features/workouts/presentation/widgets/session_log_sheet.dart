import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/session_execution.dart';
import 'session_log_form_body.dart';

export 'session_log_form_body.dart' show SessionLogResult;

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

class SessionLogSheetBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SessionLogFormBody(
            plannedExercises: plannedExercises,
            initialExercises: initialExercises,
            initialNotes: initialNotes,
            initialSessionRpe: initialSessionRpe,
            initialPainLevel: initialPainLevel,
            initialPainLocation: initialPainLocation,
            title: l10n.sessionLogTitle,
            saveLabel: l10n.sessionLogSave,
            expandableList: true,
            compact: true,
            onSave: (result) => Navigator.of(context).pop(result),
          ),
        ),
      ),
    );
  }
}
