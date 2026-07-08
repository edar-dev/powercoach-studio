import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/custom_exercise_item.dart';
import 'exercise_library_list_tile.dart';

class ExerciseLibraryTabView extends StatelessWidget {
  const ExerciseLibraryTabView({
    super.key,
    required this.isMobility,
    required this.loading,
    required this.error,
    required this.allItemsEmpty,
    required this.onRefresh,
    required this.buildList,
    required this.onEdit,
    required this.onDelete,
    required this.onAddVariant,
    required this.onTogglePin,
    required this.isPinned,
    this.readOnlyFolders = false,
  });

  final bool isMobility;
  final bool loading;
  final String? error;
  final bool allItemsEmpty;
  final bool readOnlyFolders;

  final Future<void> Function() onRefresh;
  final List<CustomExerciseItem> Function() buildList;

  final void Function(CustomExerciseItem item) onEdit;
  final void Function(CustomExerciseItem item) onDelete;
  final void Function(CustomExerciseItem item) onAddVariant;
  final void Function(CustomExerciseItem item) onTogglePin;
  final bool Function(CustomExerciseItem item) isPinned;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onRefresh,
                      child: Text(l10n.exerciseLibraryRetry),
                    ),
                  ],
                ),
              ),
            )
          : loading && allItemsEmpty
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                final list = buildList();
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: cs.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isMobility
                              ? l10n.exerciseLibraryEmptyMobility
                              : l10n.exerciseLibraryEmpty,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isMobility
                              ? l10n.exerciseLibraryEmptyMobilityHint
                              : l10n.exerciseLibraryEmptyHint,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ).copyWith(bottom: 112),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final it = list[index];
                    return ExerciseLibraryListTile(
                      item: it,
                      isPinned: isPinned,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      onAddVariant: onAddVariant,
                      onTogglePin: onTogglePin,
                      readOnlyFolders: readOnlyFolders,
                    );
                  },
                );
              },
            ),
    );
  }
}
