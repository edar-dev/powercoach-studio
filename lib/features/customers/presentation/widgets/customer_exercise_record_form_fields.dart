import 'package:flutter/material.dart';

import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/domain/exercise_autocomplete_filter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer_exercise_record.dart';
import '../customer_exercise_record_units.dart';

class CustomerExerciseRecordFormFields extends StatelessWidget {
  const CustomerExerciseRecordFormFields({
    super.key,
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.isEdit,
    required this.record,
    required this.exerciseOptions,
    required this.exerciseDepth,
    required this.exerciseFilter,
    required this.exerciseDisplayName,
    required this.selectedExerciseId,
    required this.onExerciseSelected,
    required this.valueController,
    required this.unit,
    required this.onUnitChanged,
    required this.recordedAt,
    required this.onPickDate,
    required this.noteController,
    required this.onDelete,
    required this.saving,
    required this.isMounted,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isEdit;
  final CustomerExerciseRecord? record;
  final List<CustomExerciseItem> exerciseOptions;
  final Map<String, int> exerciseDepth;
  final DebouncedExerciseAutocompleteFilter exerciseFilter;
  final String Function(CustomExerciseItem) exerciseDisplayName;
  final String? selectedExerciseId;
  final ValueChanged<String> onExerciseSelected;
  final TextEditingController valueController;
  final String unit;
  final ValueChanged<String> onUnitChanged;
  final DateTime recordedAt;
  final VoidCallback onPickDate;
  final TextEditingController noteController;
  final VoidCallback onDelete;
  final bool saving;
  final bool Function() isMounted;

  CustomExerciseItem? get _selectedExercise {
    if (selectedExerciseId == null) return null;
    try {
      return exerciseOptions.firstWhere((e) => e.id == selectedExerciseId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isEdit && record != null) ...[
          Text(
            l10n.recordSelectExercise,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              record!.displayName,
              style: theme.textTheme.bodyLarge,
            ),
            enabled: false,
          ),
          const SizedBox(height: 20),
        ] else if (exerciseOptions.isNotEmpty) ...[
          Text(
            l10n.recordSelectExercise,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Autocomplete<CustomExerciseItem>(
            initialValue: _selectedExercise != null
                ? TextEditingValue(text: exerciseDisplayName(_selectedExercise!))
                : const TextEditingValue(),
            optionsBuilder: (TextEditingValue value) {
              return exerciseFilter.optionsFor<CustomExerciseItem>(
                query: value.text,
                options: exerciseOptions,
                displayName: exerciseDisplayName,
                isActive: isMounted,
              );
            },
            displayStringForOption: exerciseDisplayName,
            onSelected: (e) => onExerciseSelected(e.id),
            fieldViewBuilder: (
              context,
              controller,
              focusNode,
              onFieldSubmitted,
            ) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: l10n.recordSearchExerciseHint,
                  border: const OutlineInputBorder(),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final e = options.elementAt(index);
                        final depth = exerciseDepth[e.id] ?? 0;
                        return Padding(
                          padding: EdgeInsets.only(left: 16.0 + (depth * 16.0)),
                          child: ListTile(
                            dense: depth > 0,
                            title: Text(
                              depth > 0 ? e.name : exerciseDisplayName(e),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: depth == 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            onTap: () => onSelected(e),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
        TextFormField(
          controller: valueController,
          decoration: InputDecoration(
            labelText: l10n.recordValue,
            border: const OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            if (double.tryParse(v.trim()) == null) return null;
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: customerExerciseRecordUnits.any((u) => u.value == unit)
              ? unit
              : 'kg',
          decoration: InputDecoration(
            labelText: l10n.recordUnit,
            border: const OutlineInputBorder(),
          ),
          items: customerExerciseRecordUnits
              .map(
                (u) => DropdownMenuItem(
                  value: u.value,
                  child: Text(
                    customerExerciseRecordUnitLabel(l10n, u.labelKey),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => onUnitChanged(v ?? 'kg'),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.recordDate, style: theme.textTheme.labelLarge),
          subtitle: Text(
            '${recordedAt.year}-${recordedAt.month.toString().padLeft(2, '0')}-${recordedAt.day.toString().padLeft(2, '0')}',
            style: theme.textTheme.bodyLarge,
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: onPickDate,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: l10n.recordNote,
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        if (isEdit && record != null) ...[
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: saving ? null : onDelete,
              icon: Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
              label: Text(
                l10n.recordDeleteButton,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
