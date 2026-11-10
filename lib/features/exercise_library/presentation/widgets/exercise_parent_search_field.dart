import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../workouts/domain/exercise_picker_index_helpers.dart';
import '../../data/custom_exercise_item.dart';
import '../../domain/exercise_autocomplete_filter.dart';

/// Autocomplete choice for parent selection (null exercise = no parent).
class ExerciseParentChoice {
  const ExerciseParentChoice.none() : exercise = null;
  const ExerciseParentChoice.exercise(CustomExerciseItem this.exercise);

  final CustomExerciseItem? exercise;

  bool get isNone => exercise == null;
}

/// Searchable parent exercise field backed by shared picker index helpers.
class ExerciseParentSearchField extends StatefulWidget {
  const ExerciseParentSearchField({
    super.key,
    required this.options,
    required this.depthById,
    required this.parentNameById,
    required this.selectedParentId,
    required this.onChanged,
  });

  final List<CustomExerciseItem> options;
  final Map<String, int> depthById;
  final Map<String, String> parentNameById;
  final String? selectedParentId;
  final ValueChanged<String?> onChanged;

  @override
  State<ExerciseParentSearchField> createState() =>
      _ExerciseParentSearchFieldState();
}

class _ExerciseParentSearchFieldState extends State<ExerciseParentSearchField> {
  static const _minInteractive = 48.0;

  late final DebouncedExerciseAutocompleteFilter _filter;
  TextEditingController? _fieldController;

  @override
  void initState() {
    super.initState();
    _filter = DebouncedExerciseAutocompleteFilter();
  }

  @override
  void didUpdateWidget(covariant ExerciseParentSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedParentId != widget.selectedParentId ||
        !identical(oldWidget.parentNameById, widget.parentNameById) ||
        !identical(oldWidget.options, widget.options)) {
      _syncFieldTextToSelection();
    }
  }

  @override
  void dispose() {
    _filter.cancel();
    super.dispose();
  }

  String _displayName(CustomExerciseItem exercise) {
    return exercisePickerDisplayName(exercise, widget.parentNameById);
  }

  String _choiceLabel(ExerciseParentChoice choice, AppLocalizations l10n) {
    final exercise = choice.exercise;
    if (exercise == null) return l10n.exerciseLibraryParentNone;
    return _displayName(exercise);
  }

  /// Show the None row when the field is empty or the query is a prefix of the
  /// localized "None" label (avoids hardcoded locale strings / false positives).
  bool _matchesNoneQuery(String query, AppLocalizations l10n) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return true;
    final noneLabel = l10n.exerciseLibraryParentNone.toLowerCase();
    return noneLabel.startsWith(trimmed);
  }

  CustomExerciseItem? get _selectedExercise {
    final id = widget.selectedParentId;
    if (id == null) return null;
    for (final option in widget.options) {
      if (option.id == id) return option;
    }
    return null;
  }

  void _syncFieldTextToSelection() {
    final controller = _fieldController;
    if (controller == null) return;
    final selected = _selectedExercise;
    final text = selected == null ? '' : _displayName(selected);
    if (controller.text != text) {
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _clearParent() {
    _fieldController?.clear();
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final selected = _selectedExercise;

    return Autocomplete<ExerciseParentChoice>(
      initialValue: TextEditingValue(
        text: selected == null ? '' : _displayName(selected),
      ),
      optionsBuilder: (TextEditingValue value) async {
        final filtered = await _filter.optionsFor<CustomExerciseItem>(
          query: value.text,
          options: widget.options,
          displayName: _displayName,
          isActive: () => mounted,
        );
        final showNone = _matchesNoneQuery(value.text, l10n);
        return [
          if (showNone) const ExerciseParentChoice.none(),
          ...filtered.map(ExerciseParentChoice.exercise),
        ];
      },
      displayStringForOption: (choice) => _choiceLabel(choice, l10n),
      onSelected: (choice) {
        if (choice.isNone) {
          _fieldController?.clear();
        }
        widget.onChanged(choice.exercise?.id);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _fieldController = controller;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: l10n.recordSearchExerciseHint,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixIcon: selected == null
                ? null
                : IconButton(
                    tooltip: l10n.exerciseLibraryParentNone,
                    icon: const Icon(Icons.clear),
                    constraints: const BoxConstraints(
                      minWidth: _minInteractive,
                      minHeight: _minInteractive,
                    ),
                    onPressed: _clearParent,
                  ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final choice = options.elementAt(index);
                final exercise = choice.exercise;
                if (exercise == null) {
                  return SizedBox(
                    height: _minInteractive,
                    child: ListTile(
                      dense: true,
                      minTileHeight: _minInteractive,
                      title: Text(
                        l10n.exerciseLibraryParentNone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      onTap: () => onSelected(choice),
                    ),
                  );
                }

                final depth = widget.depthById[exercise.id] ?? 0;
                return Padding(
                  padding: EdgeInsets.only(left: 16.0 + (depth * 16.0)),
                  child: SizedBox(
                    height: _minInteractive,
                    child: ListTile(
                      dense: true,
                      minTileHeight: _minInteractive,
                      title: Text(
                        depth > 0 ? exercise.name : _displayName(exercise),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: depth == 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () => onSelected(choice),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
