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
    this.readOnly = false,
    this.onMarkCompleted,
    this.onIncludesMobilityTabChanged,
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
  final bool readOnly;
  final VoidCallback? onMarkCompleted;
  final ValueChanged<bool>? onIncludesMobilityTabChanged;

  Widget _sectionTitle(ThemeData theme, ColorScheme cs, String text) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
    );
  }

  Widget _fieldLabel(ThemeData theme, ColorScheme cs, String text) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.72),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _fieldDecoration(ColorScheme cs, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: cs.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.6)),
      ),
    );
  }

  Widget _sectionDivider(ColorScheme cs) {
    return Divider(
      height: 32,
      color: cs.outlineVariant.withValues(alpha: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final showOptions = onIncludesMobilityTabChanged != null ||
        planCompleted ||
        planArchived ||
        onMarkCompleted != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (showOptions) ...[
          _sectionTitle(theme, cs, l10n.workoutBuilderDetailsOptionsSection),
          if (onIncludesMobilityTabChanged != null) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.workoutBuilderIncludeMobilityTab),
              subtitle: Text(
                l10n.workoutBuilderIncludeMobilityTabHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                ),
              ),
              value: routine.includesMobilityTab,
              onChanged: readOnly ? null : onIncludesMobilityTabChanged,
            ),
          ],
          if (planCompleted || planArchived) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (planArchived)
                  Chip(
                    label: Text(l10n.workoutPlanStatusArchived),
                    avatar:
                        const Icon(Icons.inventory_2_outlined, size: 18),
                  ),
                if (planCompleted)
                  Chip(
                    label: Text(l10n.workoutPlanStatusCompleted),
                    avatar:
                        const Icon(Icons.check_circle_outline, size: 18),
                  ),
              ],
            ),
          ],
          if (onMarkCompleted != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onMarkCompleted,
              icon: const Icon(Icons.flag_outlined),
              label: Text(l10n.workoutPlanCompleteAction),
            ),
          ],
          _sectionDivider(cs),
        ],
        _sectionTitle(theme, cs, l10n.workoutBuilderDetailsDatesSection),
        const SizedBox(height: 12),
        _fieldLabel(theme, cs, l10n.workoutRoutineStartDate),
        const SizedBox(height: 8),
        Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading:
                Icon(Icons.calendar_today_outlined, color: cs.primary),
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
            onTap: readOnly ? null : onPickStartDate,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(StitchM3Theme.radiusLg),
            ),
          ),
        ),
        if (editorMode) ...[
          const SizedBox(height: 16),
          _fieldLabel(theme, cs, l10n.workoutStartingWeek),
          const SizedBox(height: 8),
          TextField(
            controller: initialWeekController,
            readOnly: readOnly,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _fieldDecoration(
              cs,
              hint: l10n.workoutStartingWeekHint,
            ),
            onChanged: onInitialWeekChanged,
          ),
          const SizedBox(height: 16),
          _fieldLabel(theme, cs, l10n.workoutRoutineEndDate),
          const SizedBox(height: 8),
          Material(
            color: cs.surface,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
              onTap: readOnly ? null : onPickEndDate,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(StitchM3Theme.radiusLg),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel(theme, cs, l10n.workoutRoutineCurrentWeek),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: ValueKey(routine.currentWeek),
            initialValue: routine.currentWeek,
            isExpanded: true,
            hint: Text(
              l10n.workoutRoutineCurrentWeekHint,
              overflow: TextOverflow.ellipsis,
            ),
            decoration: _fieldDecoration(cs),
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
                  child: Text(
                    '${l10n.workoutRoutineCurrentWeek} $i',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onCurrentWeekChanged(value);
              }
            },
          ),
        ],
        if (editorMode) ...[
          _sectionDivider(cs),
          _sectionTitle(theme, cs, l10n.workoutBuilderDetailsMetadataSection),
          const SizedBox(height: 12),
          _fieldLabel(theme, cs, l10n.workoutPlanPhaseLabel),
          const SizedBox(height: 8),
          TextField(
            controller: phaseController,
            readOnly: readOnly,
            decoration: _fieldDecoration(
              cs,
              hint: l10n.workoutPlanPhaseHint,
            ),
            onChanged: (_) => onMetadataChanged?.call(),
          ),
          const SizedBox(height: 16),
          _fieldLabel(theme, cs, l10n.workoutPlanTagsLabel),
          const SizedBox(height: 8),
          TextField(
            controller: tagsController,
            readOnly: readOnly,
            decoration: _fieldDecoration(
              cs,
              hint: l10n.workoutPlanTagsHint,
            ),
            onChanged: (_) => onMetadataChanged?.call(),
          ),
          const SizedBox(height: 16),
          _fieldLabel(theme, cs, l10n.workoutPlanNotesLabel),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            readOnly: readOnly,
            minLines: 3,
            maxLines: 5,
            decoration: _fieldDecoration(
              cs,
              hint: l10n.workoutPlanNotesHint,
            ),
            onChanged: (_) => onMetadataChanged?.call(),
          ),
        ],
      ],
    );
  }
}
