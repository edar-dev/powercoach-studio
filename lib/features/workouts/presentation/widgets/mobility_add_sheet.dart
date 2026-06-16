import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/app_sheet.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';

enum MobilitySource { createNew, fromMobilityLibrary, fromExerciseLibrary }

/// Shows the "Add mobility exercise" dialog: create on the fly, from mobility library, or from exercise library.
void showAddMobilityExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  void Function(String title, String subtitle, String? customExerciseId) onSave,
) {
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderAddMobilityExerciseTitle,
    fullScreen: true,
    bodyBuilder: (sheetContext) => AddMobilityExerciseDialogContent(
      theme: theme,
      cs: cs,
      onSave: onSave,
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

class AddMobilityExerciseDialogContent extends StatefulWidget {
  const AddMobilityExerciseDialogContent({
    super.key,
    required this.theme,
    required this.cs,
    required this.onSave,
    required this.onCancel,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final void Function(String title, String subtitle, String? customExerciseId)
  onSave;
  final VoidCallback onCancel;

  @override
  State<AddMobilityExerciseDialogContent> createState() =>
      AddMobilityExerciseDialogContentState();
}

class AddMobilityExerciseDialogContentState
    extends State<AddMobilityExerciseDialogContent> {
  final _customExerciseRepo = CustomExerciseRepository();
  MobilitySource _source = MobilitySource.fromMobilityLibrary;
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  bool _saveToLibrary = false;
  List<CustomExerciseItem> _mobilityOptions = [];
  List<CustomExerciseItem> _exerciseOptions = [];
  CustomExerciseItem? _selectedLibraryItem;
  bool _loadingMobility = false;
  bool _loadingExercise = false;
  bool _saving = false;
  final Map<String, int> _mobilityDepth = {};
  final Map<String, String> _mobilityParentName = {};
  final Map<String, int> _exerciseDepth = {};
  final Map<String, String> _exerciseParentName = {};

  bool get _apiConfigured => true;

  String _exerciseDisplayName(
    CustomExerciseItem e, {
    bool useMobility = false,
  }) {
    final parentName = useMobility
        ? _mobilityParentName[e.id]
        : _exerciseParentName[e.id];
    return parentName != null ? '$parentName › ${e.name}' : e.name;
  }

  @override
  void initState() {
    super.initState();
    _loadMobilityOptions();
    _loadExerciseOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _loadMobilityOptions() async {
    setState(() => _loadingMobility = true);
    try {
      final items = await _customExerciseRepo.getTree(mobility: true);
      final flat = <CustomExerciseItem>[];
      void visit(CustomExerciseItem node, int depth, String? parentName) {
        flat.add(node);
        _mobilityDepth[node.id] = depth;
        if (parentName != null) {
          _mobilityParentName[node.id] = parentName;
        }
        for (final c in node.children) {
          visit(c, depth + 1, node.name);
        }
      }

      for (final node in items) {
        visit(node, 0, null);
      }
      if (mounted) {
        setState(() {
          _mobilityOptions = flat;
          _loadingMobility = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingMobility = false);
      }
    }
  }

  Future<void> _loadExerciseOptions() async {
    setState(() => _loadingExercise = true);
    try {
      final items = await _customExerciseRepo.getTree(mobility: false);
      final flat = <CustomExerciseItem>[];
      void visit(CustomExerciseItem node, int depth, String? parentName) {
        flat.add(node);
        _exerciseDepth[node.id] = depth;
        if (parentName != null) {
          _exerciseParentName[node.id] = parentName;
        }
        for (final c in node.children) {
          visit(c, depth + 1, node.name);
        }
      }

      for (final node in items) {
        visit(node, 0, null);
      }
      if (mounted) {
        setState(() {
          _exerciseOptions = flat;
          _loadingExercise = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingExercise = false);
      }
    }
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context);
    String title;
    String subtitle;
    String? customExerciseId;

    switch (_source) {
      case MobilitySource.createNew:
        title = _titleController.text.trim();
        subtitle = _subtitleController.text.trim();
        if (title.isEmpty && subtitle.isEmpty) return;
        if (title.isEmpty) title = l10n.workoutBuilderNewExerciseDefault;
        if (_saveToLibrary && _apiConfigured) {
          setState(() => _saving = true);
          try {
            final body = {
              'name': title,
              'description': subtitle.isEmpty ? null : subtitle,
              'isMobility': true,
            };
            final res = await _customExerciseRepo.create(body);
            final id = res['id']?.toString();
            if (id != null && mounted) {
              customExerciseId = id;
              widget.onSave(title, subtitle, customExerciseId);
              Navigator.of(context).pop();
            }
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.workoutExportError),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
          if (mounted) setState(() => _saving = false);
          return;
        }
        break;
      case MobilitySource.fromMobilityLibrary:
      case MobilitySource.fromExerciseLibrary:
        if (_selectedLibraryItem == null) return;
        title = _selectedLibraryItem!.name;
        subtitle = _selectedLibraryItem!.description ?? '';
        customExerciseId = _selectedLibraryItem!.id;
        break;
    }

    widget.onSave(title, subtitle, customExerciseId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;
    final cs = widget.cs;

    final libraryOptions = _source == MobilitySource.fromMobilityLibrary
        ? _mobilityOptions
        : _exerciseOptions;
    final loadingLibrary = _source == MobilitySource.fromMobilityLibrary
        ? _loadingMobility
        : _loadingExercise;

    final isMobilityLibrary = _source == MobilitySource.fromMobilityLibrary;
    final depthMap = isMobilityLibrary ? _mobilityDepth : _exerciseDepth;
    String displayName(CustomExerciseItem e) =>
        _exerciseDisplayName(e, useMobility: isMobilityLibrary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_apiConfigured)
                SegmentedButton<MobilitySource>(
                  segments: [
                    ButtonSegment(
                      value: MobilitySource.fromMobilityLibrary,
                      label: Text(l10n.mobilityFromMobilityLibrary),
                      icon: const Icon(Icons.self_improvement, size: 18),
                    ),
                    ButtonSegment(
                      value: MobilitySource.createNew,
                      label: Text(l10n.mobilityCreateNew),
                      icon: const Icon(Icons.add, size: 18),
                    ),
                    ButtonSegment(
                      value: MobilitySource.fromExerciseLibrary,
                      label: Text(l10n.mobilityFromExerciseLibrary),
                      icon: const Icon(Icons.fitness_center, size: 18),
                    ),
                  ],
                  selected: {_source},
                  onSelectionChanged: (s) => setState(() {
                    _source = s.first;
                    _selectedLibraryItem = null;
                  }),
                ),
              if (!_apiConfigured) const SizedBox(height: 8),
              const SizedBox(height: 12),
              if (_source == MobilitySource.createNew) ...[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.mobilityTitle,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: false,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subtitleController,
                  decoration: InputDecoration(
                    labelText: l10n.mobilitySubtitle,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                if (_apiConfigured) ...[
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: _saveToLibrary,
                    onChanged: (v) =>
                        setState(() => _saveToLibrary = v ?? false),
                    title: Text(
                      l10n.mobilitySaveToLibrary,
                      style: theme.textTheme.bodyMedium,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ] else if (loadingLibrary)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (libraryOptions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l10n.recordSearchExerciseHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                Autocomplete<CustomExerciseItem>(
                  initialValue: _selectedLibraryItem != null
                      ? TextEditingValue(
                          text: displayName(_selectedLibraryItem!),
                        )
                      : const TextEditingValue(),
                  optionsBuilder: (TextEditingValue value) {
                    final query = value.text.trim().toLowerCase();
                    if (query.isEmpty) return libraryOptions;
                    return libraryOptions.where(
                      (e) => displayName(e).toLowerCase().contains(query),
                    );
                  },
                  displayStringForOption: displayName,
                  onSelected: (e) => setState(() => _selectedLibraryItem = e),
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) =>
                          TextFormField(
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
                            ),
                          ),
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
                            final depth = depthMap[e.id] ?? 0;
                            return Padding(
                              padding: EdgeInsets.only(
                                left: 16.0 + (depth * 16.0),
                              ),
                              child: ListTile(
                                dense: depth > 0,
                                title: Text(
                                  depth > 0 ? e.name : displayName(e),
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : widget.onCancel,
                child: Text(l10n.customerCancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _saving
                    ? null
                    : () {
                        if (_source == MobilitySource.fromMobilityLibrary ||
                            _source == MobilitySource.fromExerciseLibrary) {
                          if (_selectedLibraryItem == null) return;
                        }
                        _handleSave();
                      },
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.customerSave),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
