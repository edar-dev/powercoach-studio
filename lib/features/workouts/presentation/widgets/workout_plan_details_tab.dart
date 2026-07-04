import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';

class WorkoutPlanDetailsTab extends StatelessWidget {
  const WorkoutPlanDetailsTab({
    super.key,
    required this.routine,
    required this.editorMode,
    required this.initialWeekController,
    required this.phaseController,
    required this.tagsController,
    required this.notesController,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onInitialWeekChanged,
    required this.onCurrentWeekChanged,
    this.onMetadataChanged,
    this.planCompleted = false,
    this.planArchived = false,
    this.onMarkCompleted,
  });

  final WorkoutRoutine routine;
  final bool editorMode;
  final TextEditingController initialWeekController;
  final TextEditingController phaseController;
  final TextEditingController tagsController;
  final TextEditingController notesController;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final ValueChanged<String> onInitialWeekChanged;
  final ValueChanged<int> onCurrentWeekChanged;
  final VoidCallback? onMetadataChanged;
  final bool planCompleted;
  final bool planArchived;
  final VoidCallback? onMarkCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          l10n.workoutRoutineStartDate,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.calendar_today_outlined, color: cs.primary),
          title: Text(
            routine.startDate != null
                ? MaterialLocalizations.of(
                    context,
                  ).formatFullDate(routine.startDate!)
                : l10n.workoutRoutineStartDatePlaceholder,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onPickStartDate,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          ),
          tileColor: cs.surfaceContainerHighest,
        ),
        if (editorMode) ...[
          const SizedBox(height: 24),
          Text(
            l10n.workoutStartingWeek,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: initialWeekController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: l10n.workoutStartingWeekHint,
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onInitialWeekChanged,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.workoutRoutineEndDate,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.event_outlined, color: cs.primary),
            title: Text(
              routine.endDate != null
                  ? MaterialLocalizations.of(
                      context,
                    ).formatFullDate(routine.endDate!)
                  : l10n.workoutRoutineEndDatePlaceholder,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onPickEndDate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            ),
            tileColor: cs.surfaceContainerHighest,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.workoutRoutineCurrentWeek,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: ValueKey(routine.currentWeek),
            initialValue: routine.currentWeek,
            hint: Text(l10n.workoutRoutineCurrentWeekHint),
            decoration: InputDecoration(
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              for (
                var i = 1;
                i <=
                    math.max(
                      math.max(routine.weeks.length, 1),
                      routine.currentWeek ?? 1,
                    );
                i++
              )
                DropdownMenuItem<int>(
                  value: i,
                  child: Text('${l10n.workoutRoutineCurrentWeek} $i'),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onCurrentWeekChanged(value);
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.workoutPlanPhaseLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: phaseController,
            decoration: InputDecoration(
              hintText: l10n.workoutPlanPhaseHint,
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => onMetadataChanged?.call(),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.workoutPlanTagsLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: tagsController,
            decoration: InputDecoration(
              hintText: l10n.workoutPlanTagsHint,
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => onMetadataChanged?.call(),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.workoutPlanNotesLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: l10n.workoutPlanNotesHint,
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => onMetadataChanged?.call(),
          ),
          if (planCompleted || planArchived) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (planArchived)
                  Chip(
                    label: Text(l10n.workoutPlanStatusArchived),
                    avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                  ),
                if (planCompleted)
                  Chip(
                    label: Text(l10n.workoutPlanStatusCompleted),
                    avatar: const Icon(Icons.check_circle_outline, size: 18),
                  ),
              ],
            ),
          ],
          if (onMarkCompleted != null) ...[
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onMarkCompleted,
              icon: const Icon(Icons.flag_outlined),
              label: Text(l10n.workoutPlanCompleteAction),
            ),
          ],
        ],
      ],
    );
  }
}
