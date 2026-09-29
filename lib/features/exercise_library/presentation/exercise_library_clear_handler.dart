import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/ui/widgets/app_sheet.dart';
import '../../../core/ui/widgets/app_snackbar.dart';
import '../data/custom_exercise_repository.dart';
import '../data/pinned_exercises_store.dart';
import '../data/recent_exercises_store.dart';
import '../domain/default_exercise_catalog_seeder.dart';

/// UI orchestration for clearing the entire exercise library.
class ExerciseLibraryClearHandler {
  ExerciseLibraryClearHandler({
    required this.context,
    required this.exerciseRepo,
    PinnedExercisesStore? pinnedStore,
    RecentExercisesStore? recentStore,
    required this.onReload,
  })  : _pinnedStore = pinnedStore ?? PinnedExercisesStore.instance,
        _recentStore = recentStore ?? RecentExercisesStore.instance;

  final BuildContext context;
  final CustomExerciseRepository exerciseRepo;
  final VoidCallback onReload;
  final PinnedExercisesStore _pinnedStore;
  final RecentExercisesStore _recentStore;

  Future<void> confirmAndClear() async {
    final l10n = AppLocalizations.of(context);
    try {
      final items = await exerciseRepo.listFlat();
      if (!context.mounted) return;
      if (items.isEmpty) {
        showAppSnackBar(
          context,
          content: Text(l10n.exerciseLibraryClearAllEmpty),
        );
        return;
      }

      final confirmed = await showAppConfirmDialog(
        context: context,
        title: l10n.exerciseLibraryClearAllTitle,
        message: l10n.exerciseLibraryClearAllMessage,
        confirmLabel: l10n.exerciseLibraryClearAllConfirm,
        cancelLabel: l10n.exerciseLibraryCancel,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;

      final ids = items.map((e) => e.id).toList();
      // Suppress auto-seed before deletes so a mid-clear failure cannot re-seed.
      await DefaultExerciseCatalogSeeder.markAutoSeedSuppressed();
      final count = await exerciseRepo.deleteAll();
      await _pinnedStore.removeIds(ids);
      await _recentStore.removeIds(ids);

      if (!context.mounted) return;
      onReload();
      showAppSnackBar(
        context,
        content: Text(l10n.exerciseLibraryClearAllSuccessCount(count)),
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(e.toString()));
    }
  }
}
