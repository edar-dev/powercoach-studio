import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/custom_exercise_item.dart';

class CustomExerciseEditDialog extends StatefulWidget {
  const CustomExerciseEditDialog({
    super.key,
    required this.title,
    required this.name,
    required this.description,
    required this.isMobility,
    required this.parentId,
    required this.parentCandidates,
    required this.onSave,
    required this.onCancel,
  });

  final String title;
  final String name;
  final String? description;
  final bool isMobility;
  final String? parentId;
  final List<CustomExerciseItem> parentCandidates;
  final void Function(String name, String? description, String? parentId, bool isMobility) onSave;
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
  late final Map<String, CustomExerciseItem> _itemsById;
  late final Map<String, int> _depthById;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descController = TextEditingController(text: widget.description ?? '');
    _selectedParentId = widget.parentId;
    _isMobility = widget.isMobility;

    _itemsById = {
      for (final it in widget.parentCandidates) it.id: it,
    };
    _depthById = {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  int _computeDepth(String id) {
    if (_depthById.containsKey(id)) return _depthById[id]!;
    final visited = <String>{};
    int depth = 0;
    var current = _itemsById[id];

    while (current != null && current.parentId != null) {
      if (!visited.add(current.id)) break;
      final parentId = current.parentId;
      final parent = _itemsById[parentId];
      if (parent == null) break;
      depth++;
      current = parent;
    }

    _depthById[id] = depth;
    return depth;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            autofocus: true,
            validator: (value) => (value == null || value.trim().isEmpty) ? l10n.exerciseLibraryNameHint : null,
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
          if (widget.parentCandidates.isNotEmpty) ...[
            Text(
              l10n.exerciseLibraryParentLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _selectedParentId,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.exerciseLibraryParentNone,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.exerciseLibraryParentNone),
                ),
                ...widget.parentCandidates.map(
                  (e) => DropdownMenuItem<String?>(
                    value: e.id,
                    child: Builder(
                      builder: (context) {
                        final depth = _computeDepth(e.id);
                        final indent = List<String>.filled(depth, '  ').join();
                        return Text('$indent${e.name}');
                      },
                    ),
                  ),
                ),
              ],
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
