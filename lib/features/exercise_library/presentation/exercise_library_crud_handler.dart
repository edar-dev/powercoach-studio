import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../data/custom_exercise_item.dart';
import '../data/custom_exercise_repository.dart';
import '../domain/exercise_library_tree_helpers.dart';
import 'widgets/custom_exercise_edit_dialog.dart';

/// UI orchestration for exercise library add/edit/delete flows.
class ExerciseLibraryCrudHandler {
  ExerciseLibraryCrudHandler({
    required this.context,
    required this.exerciseRepo,
    required this.items,
    required this.onReload,
  });

  final BuildContext context;
  final CustomExerciseRepository exerciseRepo;
  final List<CustomExerciseItem> Function() items;
  final VoidCallback onReload;

  void showAddDialog({required bool isMobility}) {
    showAddDialogWithParent(null, isMobility: isMobility);
  }

  void showAddVariantDialog(CustomExerciseItem parent) {
    showAddDialogWithParent(
      parent.id,
      sortOrder: parent.children.length,
      isMobility: parent.isMobility,
    );
  }

  void showAddDialogWithParent(
    String? parentId, {
    int? sortOrder,
    required bool isMobility,
  }) {
    final l10n = AppLocalizations.of(context);
    showAppBottomSheet<void>(
      context: context,
      title: l10n.exerciseLibraryAddExercise,
      fullScreen: false,
      bodyBuilder: (sheetContext) => CustomExerciseEditDialog(
        title: l10n.exerciseLibraryAddExercise,
        name: '',
        description: null,
        isMobility: isMobility,
        parentId: parentId,
        parentCandidates: flattenExerciseTree(items()),
        onSave: (name, description, selectedParentId, isMobility) async {
          try {
            await exerciseRepo.create({
              'name': name,
              if (description != null && description.isNotEmpty)
                'description': description,
              if (selectedParentId != null && selectedParentId.isNotEmpty)
                'parentId': selectedParentId,
              if (sortOrder != null) 'sortOrder': sortOrder,
              'isMobility': isMobility,
            });
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
              onReload();
            }
          } catch (e) {
            if (sheetContext.mounted) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        onCancel: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  void showEditDialog(CustomExerciseItem item) {
    final l10n = AppLocalizations.of(context);
    final excludeIds = {item.id, ...item.flat.map((e) => e.id)};
    final parentCandidates = flattenExerciseTree(
      items(),
    ).where((e) => !excludeIds.contains(e.id)).toList();
    showAppBottomSheet<void>(
      context: context,
      title: l10n.exerciseLibraryEditExercise,
      fullScreen: false,
      bodyBuilder: (sheetContext) => CustomExerciseEditDialog(
        title: l10n.exerciseLibraryEditExercise,
        name: item.name,
        description: item.description,
        isMobility: item.isMobility,
        parentId: item.parentId,
        parentCandidates: parentCandidates,
        onSave: (name, description, parentId, isMobility) async {
          try {
            await exerciseRepo.update(item.id, {
              'name': name,
              'description': description?.isEmpty == true ? null : description,
              'parentId': parentId?.isEmpty == true ? null : parentId,
              'isMobility': isMobility,
              'expectedRowVersion': item.rowVersion,
            });
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
              onReload();
            }
          } catch (e) {
            if (sheetContext.mounted) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        onCancel: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  Future<void> confirmDelete(CustomExerciseItem item) async {
    final l10n = AppLocalizations.of(context);
    final hasChildren = item.children.isNotEmpty;
    final message = hasChildren
        ? l10n.exerciseLibraryDeleteHasChildren
        : l10n.exerciseLibraryDeleteConfirm(item.name);
    if (hasChildren) {
      await showAppBottomSheet<void>(
        context: context,
        title: l10n.exerciseLibraryDeleteTitle,
        bodyBuilder: (_) => Text(message),
        primaryActionLabel: l10n.exerciseLibraryCancel,
        onPrimaryAction: () => Navigator.of(context).pop(),
      );
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.exerciseLibraryDeleteTitle,
      message: message,
      confirmLabel: l10n.exerciseLibraryDelete,
      cancelLabel: l10n.exerciseLibraryCancel,
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await exerciseRepo.delete(item.id);
      onReload();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
