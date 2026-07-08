import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import '../data/custom_exercise_repository.dart';
import '../domain/exercise_library_tree_helpers.dart';

/// Export orchestration for the exercise library screen.
class ExerciseLibraryExportHandler {
  ExerciseLibraryExportHandler({
    required this.context,
    required this.exerciseRepo,
  });

  final BuildContext context;
  final CustomExerciseRepository exerciseRepo;

  Future<void> export({required bool isMobility}) async {
    try {
      final roots = await exerciseRepo.getTree(mobility: isMobility);
      final data = flattenExerciseTree(roots)
          .map(
            (e) => <String, dynamic>{
              'id': e.id,
              'name': e.name,
              'description': e.description,
              'parentId': e.parentId,
              'sortOrder': e.sortOrder,
              'isMobility': e.isMobility,
            },
          )
          .toList();
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      if (data.isEmpty) {
        showAppSnackBar(
          context,
          content: Text(l10n.exerciseLibraryExportEmpty),
        );
        return;
      }
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final name =
          'custom-exercises-${isMobility ? 'mobility' : 'standard'}-${DateTime.now().toIso8601String().split('T').first}.json';
      await Share.share(
        json,
        subject: name,
        sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
      );
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, content: Text(e.toString()));
      }
    }
  }
}
