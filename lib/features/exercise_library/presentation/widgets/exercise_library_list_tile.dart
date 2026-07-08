import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/custom_exercise_item.dart';

class ExerciseLibraryListTile extends StatelessWidget {
  const ExerciseLibraryListTile({
    super.key,
    required this.item,
    required this.isPinned,
    required this.onEdit,
    required this.onDelete,
    required this.onAddVariant,
    required this.onTogglePin,
    this.readOnlyFolders = false,
  });

  final CustomExerciseItem item;
  final bool Function(CustomExerciseItem item) isPinned;
  final void Function(CustomExerciseItem item) onEdit;
  final void Function(CustomExerciseItem item) onDelete;
  final void Function(CustomExerciseItem item) onAddVariant;
  final void Function(CustomExerciseItem item) onTogglePin;
  final bool readOnlyFolders;

  @override
  Widget build(BuildContext context) {
    final hasChildren = item.children.isNotEmpty;
    final pinned = isPinned(item);
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          hasChildren ? Icons.folder_outlined : Icons.fitness_center_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(item.name),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing:
            readOnlyFolders && (item.isHevyFolder || item.children.isNotEmpty)
            ? null
            : PopupMenuButton<String>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pin',
                    child: Text(
                      pinned
                          ? l10n.exerciseLibraryUnpin
                          : l10n.exerciseLibraryPin,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'addVariant',
                    child: Text(l10n.exerciseLibraryAddVariant),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.exerciseLibraryEdit),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.exerciseLibraryDelete),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'pin') onTogglePin(item);
                  if (value == 'addVariant') onAddVariant(item);
                  if (value == 'edit') onEdit(item);
                  if (value == 'delete') onDelete(item);
                },
              ),
        children: item.children
            .map(
              (child) => Padding(
                padding: const EdgeInsets.only(left: 24, right: 8, bottom: 4),
                child: ExerciseLibraryListTile(
                  item: child,
                  isPinned: isPinned,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onAddVariant: onAddVariant,
                  onTogglePin: onTogglePin,
                  readOnlyFolders: readOnlyFolders,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
