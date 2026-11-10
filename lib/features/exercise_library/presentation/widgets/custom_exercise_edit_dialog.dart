import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../workouts/domain/exercise_picker_index_helpers.dart';
import '../../data/custom_exercise_item.dart';
import 'exercise_parent_search_field.dart';

class CustomExerciseEditDialog extends StatefulWidget {
  const CustomExerciseEditDialog({
    super.key,
    required this.title,
    required this.name,
    required this.description,
    required this.isMobility,
    required this.parentId,
    required this.parentTreeRoots,
    this.excludeParentIds = const {},
    required this.onSave,
    required this.onCancel,
  });

  final String title;
  final String name;
  final String? description;
  final bool isMobility;
  final String? parentId;

  /// Tree roots for parent selection (not flattened).
  final List<CustomExerciseItem> parentTreeRoots;

  /// Ids excluded from parent candidates (edited item + descendants).
  final Set<String> excludeParentIds;

  final void Function(
    String name,
    String? description,
    String? parentId,
    bool isMobility,
  ) onSave;
  final VoidCallback onCancel;

  @override
  State<CustomExerciseEditDialog> createState() =>
      _CustomExerciseEditDialogState();
}

class _CustomExerciseEditDialogState extends State<CustomExerciseEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  String? _selectedParentId;
  late bool _isMobility;
  late ExercisePickerIndex _parentIndex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descController = TextEditingController(text: widget.description ?? '');
    _selectedParentId = widget.parentId;
    _isMobility = widget.isMobility;
    _rebuildParentIndex();
  }

  @override
  void didUpdateWidget(covariant CustomExerciseEditDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.parentTreeRoots, widget.parentTreeRoots) ||
        oldWidget.excludeParentIds != widget.excludeParentIds) {
      _rebuildParentIndex();
    }
    if (oldWidget.parentId != widget.parentId) {
      _selectedParentId = widget.parentId;
    }
  }

  void _rebuildParentIndex() {
    _parentIndex = buildParentSelectionIndex(
      widget.parentTreeRoots,
      excludeIds: widget.excludeParentIds,
    );
    final selected = _selectedParentId;
    if (selected != null &&
        !_parentIndex.flat.any((item) => item.id == selected)) {
      _selectedParentId = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showParentField = _parentIndex.flat.isNotEmpty;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.exerciseLibraryNameHint,
              hintText: l10n.exerciseLibraryNameHint,
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: false,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? l10n.exerciseLibraryNameHint
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: l10n.exerciseLibraryDescriptionHint,
              hintText: l10n.exerciseLibraryDescriptionHint,
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _isMobility,
            onChanged: (v) => setState(() => _isMobility = v),
            title: Text(
              l10n.exerciseLibraryMobilityToggle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          if (showParentField) ...[
            Text(
              l10n.exerciseLibraryParentLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            ExerciseParentSearchField(
              options: _parentIndex.flat,
              depthById: _parentIndex.depthById,
              parentNameById: _parentIndex.parentNameById,
              selectedParentId: _selectedParentId,
              onChanged: (value) => setState(() => _selectedParentId = value),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: Text(l10n.exerciseLibraryCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final name = _nameController.text.trim();
                    final desc = _descController.text.trim();
                    widget.onSave(
                      name,
                      desc.isEmpty ? null : desc,
                      _selectedParentId,
                      _isMobility,
                    );
                  },
                  child: Text(l10n.exerciseLibrarySave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
