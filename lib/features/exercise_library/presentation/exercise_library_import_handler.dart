import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import '../../integrations/hevy/data/hevy_api_models.dart';
import '../../integrations/hevy/data/hevy_catalog_import_service.dart';
import '../../integrations/hevy/data/hevy_settings_store.dart';
import '../../integrations/hevy/domain/exercise_catalog_source.dart';
import '../data/default_exercise_catalog.dart';
import '../data/import_file_reader.dart';
import '../domain/exercise_library_import_service.dart';
import '../presentation/widgets/exercise_library_import_source_sheet.dart';

/// UI orchestration for exercise library import flows.
class ExerciseLibraryImportHandler {
  ExerciseLibraryImportHandler({
    required this.context,
    ExerciseLibraryImportService? importService,
    required this.onReload,
    required this.isMobilityTab,
  }) : _importService = importService ?? ExerciseLibraryImportService();

  final BuildContext context;
  final VoidCallback onReload;
  final bool Function() isMobilityTab;
  final ExerciseLibraryImportService _importService;

  Future<void> showImportSheet() async {
    final l10n = AppLocalizations.of(context);
    await showAppBottomSheet<void>(
      context: context,
      title: l10n.exerciseLibraryImportSourceTitle,
      bodyBuilder: (sheetContext) => ExerciseLibraryImportSourceSheet(
        onImportDefault: () {
          Navigator.of(sheetContext).pop();
          importDefaultCatalog();
        },
        onImportHevy: () {
          Navigator.of(sheetContext).pop();
          importHevyCatalog();
        },
        onImportCustomFile: () {
          Navigator.of(sheetContext).pop();
          importCustomFile();
        },
      ),
    );
  }

  Future<void> importHevyCatalog() async {
    final l10n = AppLocalizations.of(context);
    final hasKey = await HevySettingsStore.instance.hasApiKey();
    if (!hasKey) {
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(l10n.hevyExportNoCatalogHint));
      return;
    }
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final label = l10n.hevyImportInProgress;
        return AlertDialog(
          title: Text(l10n.exerciseLibraryImportSourceHevy),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(label),
            ],
          ),
        );
      },
    );
    try {
      final count = await HevyCatalogImportService().importAllFromApi(
        onProgress: (_, __, ___) {},
      );
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnackBar(
        context,
        content: Text(l10n.hevyImportSuccessCount(count)),
      );
      onReload();
    } on HevyApiException catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnackBar(context, content: Text(l10n.hevyImportFailed(e.message)));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnackBar(
        context,
        content: Text(l10n.hevyImportFailed(e.toString())),
      );
    }
  }

  Future<void> importDefaultCatalog() async {
    final l10n = AppLocalizations.of(context);
    await _importAndNotify(
      buildDefaultExerciseCatalogJson(),
      l10n: l10n,
      fallbackMobilityWhenMissing: false,
      catalogSource: ExerciseCatalogSource.powercoach,
    );
  }

  Future<void> importCustomFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;
    final file = result.files.single;
    List<Map<String, dynamic>> items;
    try {
      String content;
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (!kIsWeb && file.path != null) {
        content = await readImportFileFromPath(file.path!);
      } else {
        content = '[]';
      }
      final decoded = jsonDecode(content);
      if (decoded is! List) {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          showAppSnackBar(
            context,
            content: Text(l10n.exerciseLibraryImportInvalidFormat),
          );
        }
        return;
      }
      items = decoded
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .toList();
    } catch (_) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        showAppSnackBar(
          context,
          content: Text(l10n.exerciseLibraryImportInvalidFormat),
        );
      }
      return;
    }
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    await _importAndNotify(
      items,
      l10n: l10n,
      fallbackMobilityWhenMissing: isMobilityTab(),
    );
  }

  Future<void> _importAndNotify(
    List<Map<String, dynamic>> items, {
    required AppLocalizations l10n,
    required bool fallbackMobilityWhenMissing,
    String catalogSource = ExerciseCatalogSource.manual,
  }) async {
    try {
      final importedCount = await _importService.importItems(
        items,
        fallbackMobilityWhenMissing: fallbackMobilityWhenMissing,
        catalogSource: catalogSource,
      );
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        content: Text(l10n.exerciseLibraryImportSuccessCount(importedCount)),
      );
      onReload();
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(e.toString()));
    }
  }
}
