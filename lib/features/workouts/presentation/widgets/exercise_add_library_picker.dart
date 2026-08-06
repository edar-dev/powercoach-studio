import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/domain/exercise_autocomplete_filter.dart';
import '../../domain/exercise_picker_index_helpers.dart';

class ExerciseAddLibraryPicker extends StatelessWidget {
  const ExerciseAddLibraryPicker({
    super.key,
    required this.exerciseOptions,
    required this.recentExercises,
    required this.pinnedExerciseIds,
    required this.depthById,
    required this.parentNameById,
    required this.selectedExercise,
    required this.exerciseFilter,
    required this.isMounted,
    required this.onExerciseSelected,
    this.onSearchTextChanged,
    this.selectionErrorText,
    this.customerRecordPanel,
  });

  final List<CustomExerciseItem> exerciseOptions;
  final List<CustomExerciseItem> recentExercises;
  final Set<String> pinnedExerciseIds;
  final Map<String, int> depthById;
  final Map<String, String> parentNameById;
  final CustomExerciseItem? selectedExercise;
  final DebouncedExerciseAutocompleteFilter exerciseFilter;
  final bool Function() isMounted;
  final ValueChanged<CustomExerciseItem> onExerciseSelected;
  final ValueChanged<String>? onSearchTextChanged;
  final String? selectionErrorText;
  final Widget? customerRecordPanel;

  String _displayName(CustomExerciseItem exercise) {
    return exercisePickerDisplayName(exercise, parentNameById);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (recentExercises.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: recentExercises
                .map(
                  (e) => ActionChip(
                    label: Text(e.name),
                    avatar: pinnedExerciseIds.contains(e.id)
                        ? const Icon(Icons.push_pin, size: 14)
                        : null,
                    onPressed: () => onExerciseSelected(e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        Autocomplete<CustomExerciseItem>(
          initialValue: selectedExercise != null
              ? TextEditingValue(text: _displayName(selectedExercise!))
              : const TextEditingValue(),
          optionsBuilder: (TextEditingValue value) {
            return exerciseFilter.optionsFor<CustomExerciseItem>(
              query: value.text,
              options: exerciseOptions,
              displayName: _displayName,
              isActive: isMounted,
            );
          },
          displayStringForOption: _displayName,
          onSelected: onExerciseSelected,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onSearchTextChanged,
              decoration: InputDecoration(
                hintText: l10n.recordSearchExerciseHint,
                errorText: selectionErrorText,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final e = options.elementAt(index);
                    final depth = depthById[e.id] ?? 0;
                    return Padding(
                      padding: EdgeInsets.only(left: 16.0 + (depth * 16.0)),
                      child: ListTile(
                        dense: depth > 0,
                        title: Text(
                          depth > 0 ? e.name : _displayName(e),
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
          ),
        ),
        if (customerRecordPanel != null) ...[
          const SizedBox(height: 10),
          customerRecordPanel!,
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
