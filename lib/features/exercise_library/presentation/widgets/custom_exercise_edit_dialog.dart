import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/custom_exercise_item.dart';

class CustomExerciseEditDialog extends StatefulWidget {
  const CustomExerciseEditDialog({
    super.key,
    required this.title,
    required this.name,
    required this.description,
    required this.parentId,
    required this.parentCandidates,
    required this.onSave,
    required this.onCancel,
  });

  final String title;
  final String name;
  final String? description;
  final String? parentId;
  final List<CustomExerciseItem> parentCandidates;
  final void Function(String name, String? description, String? parentId) onSave;
  final VoidCallback onCancel;

  @override
  State<CustomExerciseEditDialog> createState() =>
      _CustomExerciseEditDialogState();
}

class _CustomExerciseEditDialogState extends State<CustomExerciseEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descController = TextEditingController(text: widget.description ?? '');
    _selectedParentId = widget.parentId;
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
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.exerciseLibraryNameHint,
                hintText: l10n.exerciseLibraryNameHint,
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: l10n.exerciseLibraryDescriptionHint,
                hintText: l10n.exerciseLibraryDescriptionHint,
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
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
                      child: Text(e.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedParentId = value),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(l10n.exerciseLibraryCancel),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            widget.onSave(
              name,
              _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              _selectedParentId,
            );
          },
          child: Text(l10n.exerciseLibrarySave),
        ),
      ],
    );
  }
}
