import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/session_log_draft.dart';
import 'session_log_set_row.dart';

/// Expandable exercise block with set editors in the session log sheet.
class SessionLogExerciseSection extends StatelessWidget {
  const SessionLogExerciseSection({
    super.key,
    required this.draft,
    required this.l10n,
    required this.expanded,
    required this.onExpandedChanged,
    required this.onCompletedChanged,
    required this.onSetChanged,
    required this.onAddSet,
  });

  final SessionLogExerciseDraft draft;
  final AppLocalizations l10n;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<bool> onCompletedChanged;
  final void Function(int setIndex, SessionLogSetDraft set) onSetChanged;
  final VoidCallback onAddSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Checkbox(
              value: draft.completed,
              onChanged: (value) => onCompletedChanged(value ?? false),
            ),
            title: Text(
              draft.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: IconButton(
              tooltip:
                  expanded ? l10n.sessionLogCollapseSets : l10n.sessionLogExpandSets,
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => onExpandedChanged(!expanded),
            ),
          ),
          if (expanded) ...[
            for (var i = 0; i < draft.sets.length; i++)
              SessionLogSetRow(
                key: ValueKey('${draft.exerciseId}-$i'),
                setIndex: i,
                reps: draft.sets[i].reps,
                load: draft.sets[i].load,
                completed: draft.sets[i].completed,
                l10n: l10n,
                onRepsChanged: (value) {
                  onSetChanged(
                    i,
                    SessionLogSetDraft(
                      reps: value,
                      load: draft.sets[i].load,
                      completed: draft.sets[i].completed,
                    ),
                  );
                },
                onLoadChanged: (value) {
                  onSetChanged(
                    i,
                    SessionLogSetDraft(
                      reps: draft.sets[i].reps,
                      load: value,
                      completed: draft.sets[i].completed,
                    ),
                  );
                },
                onCompletedChanged: (value) {
                  onSetChanged(
                    i,
                    SessionLogSetDraft(
                      reps: draft.sets[i].reps,
                      load: draft.sets[i].load,
                      completed: value,
                    ),
                  );
                },
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add),
                label: Text(l10n.sessionLogAddSet),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
