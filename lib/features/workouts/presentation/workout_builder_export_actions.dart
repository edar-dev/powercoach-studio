import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/export/export_share.dart';
import 'package:powercoach_studio/core/pdf/pdf_coach_header.dart';
import 'package:powercoach_studio/core/pdf/pdf_export_labels_l10n.dart';
import 'package:powercoach_studio/core/pdf/pdf_plan_metadata.dart';
import 'package:powercoach_studio/core/storage/local_user_profile_store.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/pdf_export_progress_dialog.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/integrations/hevy/data/hevy_settings_store.dart';
import 'package:powercoach_studio/features/integrations/hevy/presentation/hevy_export_review_sheet.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/export_excel_usecase.dart';
import 'package:powercoach_studio/features/workouts/domain/export_json_usecase.dart';
import 'package:powercoach_studio/features/workouts/domain/export_pdf_usecase.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_import_export_coordinator.dart';
import 'package:powercoach_studio/features/exercise_library/data/import_file_reader.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// PDF / JSON / Excel / Hevy export helpers for the workout builder screen.
class WorkoutBuilderExportActions {
  WorkoutBuilderExportActions({
    required this.context,
    required this.routineNameController,
    required this.customerRepo,
    this.editorCustomer,
    this.editorMode = false,
  });

  final BuildContext context;
  final TextEditingController routineNameController;
  final CustomerRepository customerRepo;
  final Customer? editorCustomer;
  final bool editorMode;

  WorkoutRoutine namedRoutine(WorkoutRoutine routine) {
    final name = routineNameController.text.trim();
    return routine.copyWith(name: name.isEmpty ? routine.name : name);
  }

  Future<Customer?> loadCustomerIfNeeded() async {
    if (editorMode && editorCustomer != null) return editorCustomer;
    final customerId =
        GoRouterState.of(context).uri.queryParameters['customerId'];
    if (customerId == null || customerId.isEmpty) return null;
    try {
      return await customerRepo.getById(customerId);
    } catch (_) {
      return null;
    }
  }

  Future<PdfCoachHeaderInfo> resolvePdfCoachHeader() async {
    final labels = AppLocalizations.of(context).toPdfExportLabels();
    final customer = await loadCustomerIfNeeded();
    final uid = Supabase.instance.client.auth.currentUser?.id ?? '';
    final profile = await LocalUserProfileStore.instance.read(uid);
    final email = Supabase.instance.client.auth.currentUser?.email;
    return buildPdfCoachHeader(
      labels: labels,
      customer: customer,
      profile: profile,
      authEmail: email,
    );
  }

  Future<void> exportPdf(
    WorkoutRoutine routine, {
    required WorkoutPdfLayout layout,
    required bool includeMobility,
  }) async {
    final l10n = AppLocalizations.of(context);
    final labels = l10n.toPdfExportLabels();
    final resolved = namedRoutine(routine);
    showPdfExportProgressDialog(context, message: labels.exportGenerating);
    try {
      final customer = await loadCustomerIfNeeded();
      final coachHeader = await resolvePdfCoachHeader();
      final planMetadata = buildPdfPlanMetadata(
        routine: resolved,
        labels: labels,
        clientName: customer?.name,
      );
      final artifact = await exportWorkoutRoutineToPdf(
        resolved,
        labels: labels,
        coachHeader: coachHeader,
        planMetadata: planMetadata,
        layout: layout,
        includeMobility: includeMobility,
      );
      if (!context.mounted) return;
      await downloadExportArtifact(artifact);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    } finally {
      if (context.mounted) hidePdfExportProgressDialog(context);
    }
  }

  Future<void> exportJson(WorkoutRoutine routine) async {
    final l10n = AppLocalizations.of(context);
    try {
      final artifact = await exportWorkoutRoutineToJson(namedRoutine(routine));
      if (!context.mounted) return;
      await downloadExportArtifact(artifact);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<WorkoutRoutine?> importJson() async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !context.mounted) {
      return null;
    }

    final file = result.files.single;
    try {
      final String content;
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        content = await readImportFileFromPath(file.path!);
      } else {
        throw const FormatException('empty file');
      }
      final importResult = parseWorkoutRoutineImport(content);
      final imported = importResult.routine;
      if (imported == null) {
        throw FormatException(importResult.failureReason?.name ?? 'invalid');
      }
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutImportJsonSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
      return imported;
    } catch (_) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutImportJsonError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
      return null;
    }
  }

  Future<void> exportExcel(WorkoutRoutine routine) async {
    final l10n = AppLocalizations.of(context);
    try {
      final artifact = await exportWorkoutRoutineToExcel(namedRoutine(routine));
      if (!context.mounted) return;
      await downloadExportArtifact(artifact);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> exportCurrentDayToHevy({
    required WorkoutRoutine routine,
    required int selectedWeekIndex,
    required int selectedDayIndex,
  }) async {
    final l10n = AppLocalizations.of(context);
    final hasKey = await HevySettingsStore.instance.hasApiKey();
    if (!hasKey) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.hevyExportNoCatalogHint)),
      );
      return;
    }
    if (routine.weeks.isEmpty) return;
    final weekIndex = selectedWeekIndex.clamp(0, routine.weeks.length - 1);
    final week = routine.weeks[weekIndex];
    if (week.days.isEmpty) return;
    final dayIndex = selectedDayIndex.clamp(0, week.days.length - 1);
    final day = week.days[dayIndex];
    final programName = routineNameController.text.trim().isEmpty
        ? routine.name
        : routineNameController.text.trim();

    if (!context.mounted) return;
    await showHevyExportReviewSheet(
      context: context,
      day: day,
      programName: programName,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      customerName: editorCustomer?.name,
    );
  }
}
