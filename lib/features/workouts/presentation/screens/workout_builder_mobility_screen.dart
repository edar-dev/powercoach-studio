import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/export/export_share.dart';
import '../../../../core/pdf/pdf_coach_header.dart';
import '../../../../core/pdf/pdf_export_labels_l10n.dart';
import '../../../../core/storage/local_user_profile_store.dart';
import '../../../../widgets/pdf_export_progress_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';
import '../../data/workout_routine_storage.dart';
import '../../data/workout_plan_repository.dart';
import 'package:file_picker/file_picker.dart';

import '../../../exercise_library/data/import_file_reader.dart';
import '../../domain/day_scheduled_weekday.dart';
import '../../domain/export_excel_usecase.dart';
import '../../domain/export_json_usecase.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/export_pdf_usecase.dart';
import '../../domain/workout_exercise_mutations.dart';
import '../../domain/workout_routine_mutations.dart';
import '../../../../core/pdf/pdf_plan_metadata.dart';
import '../../domain/workout_plan_list_helpers.dart';
import '../../domain/workout_routine_json_codec.dart';
import '../workout_editor_controller.dart';
import '../widgets/workout_builder_bottom_nav.dart';
import '../widgets/workout_editor_app_bar.dart';
import '../widgets/workout_editor_save_status_indicator.dart';
import '../widgets/workout_export_sheet.dart';
import '../widgets/exercise_add_sheet.dart';
import '../widgets/workout_mobility_tab.dart';
import '../widgets/workout_training_helpers.dart';
import '../widgets/workout_lazy_tab.dart';
import '../widgets/workout_training_tab.dart';
import '../widgets/mobility_add_sheet.dart';
import '../widgets/workout_plan_details_tab.dart';
import '../../../integrations/hevy/data/hevy_settings_store.dart';
import '../../../integrations/hevy/presentation/hevy_export_review_sheet.dart';
import '../../../customers/data/models/customer.dart' show Customer;

/// Workout Builder variant: Enhanced Mobility (694ace9b), Multi-set (9ffa631f), Super Set (e63b1ef6), Intuitive Super Set (7ce630e5).
enum WorkoutBuilderVariant { mobility, multiset, superset, intuitiveSuperset }

enum _WorkoutEditorExitAction { save, discard, cancel }

/// Workout Builder – Enhanced Mobility Controls (Stitch 694ace9b83514965989f12ac2a3d54fa).
/// When [editorMode] is true and [customerId] is set, loads/saves via API (workout plan for customer).
class WorkoutBuilderMobilityScreen extends StatefulWidget {
  const WorkoutBuilderMobilityScreen({
    super.key,
    this.variant = WorkoutBuilderVariant.mobility,
    this.customerId,
    this.planId,
    this.editorMode = false,
  });

  final WorkoutBuilderVariant variant;
  final String? customerId;
  final String? planId;
  final bool editorMode;

  @override
  State<WorkoutBuilderMobilityScreen> createState() =>
      _WorkoutBuilderMobilityScreenState();
}

class _WorkoutBuilderMobilityScreenState
    extends State<WorkoutBuilderMobilityScreen>
    with SingleTickerProviderStateMixin {
  final _routineNameController = TextEditingController();
  final _initialWeekController = TextEditingController(text: '1');
  final _phaseController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();
  final _customerRepo = CustomerRepository();
  final _planRepo = WorkoutPlanRepository();
  late final WorkoutEditorController _editorController;
  Customer? _editorCustomer;
  WorkoutRoutine _routine = WorkoutRoutine.empty();
  bool _loading = true;
  bool _saving = false;
  bool _planCompleted = false;
  bool _planArchived = false;
  int _initialWeekNumber = 1;
  int _selectedMobilitySectionIndex = 0;
  int _selectedWeekIndex = 0;
  int _selectedDayIndex = 0;
  int? _pendingSelectedWeekIndex;
  int? _pendingSelectedDayIndex;
  bool _didReadDeepLinkSelection = false;
  late final TabController _sectionTabController;

  bool get _showsMobilityTab =>
      widget.variant == WorkoutBuilderVariant.mobility;

  bool get _isDirty =>
      widget.editorMode ? _editorController.isDirty : false;

  @override
  void initState() {
    super.initState();
    _editorController = WorkoutEditorController(planRepo: _planRepo);
    _sectionTabController = TabController(
      length: _showsMobilityTab ? 3 : 2,
      vsync: this,
    );
    _routineNameController.addListener(_onMetadataEdited);
    _initialWeekController.addListener(_onMetadataEdited);
    _phaseController.addListener(_onMetadataEdited);
    _tagsController.addListener(_onMetadataEdited);
    _notesController.addListener(_onMetadataEdited);
    _loadRoutine();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadDeepLinkSelection) {
      return;
    }
    _didReadDeepLinkSelection = true;
    _readDeepLinkSelection();
  }

  void _readDeepLinkSelection() {
    final query = GoRouterState.of(context).uri.queryParameters;
    _pendingSelectedWeekIndex = int.tryParse(query['week'] ?? '');
    _pendingSelectedDayIndex = int.tryParse(query['day'] ?? '');
  }

  WorkoutEditorSession _editorSession() {
    final parsedInitialWeek = int.tryParse(_initialWeekController.text.trim());
    final resolvedInitialWeek =
        (parsedInitialWeek != null && parsedInitialWeek >= 1)
        ? parsedInitialWeek
        : _initialWeekNumber;
    return WorkoutEditorSession(
      routine: _routine,
      planName: _routineNameController.text,
      initialWeekNumber: resolvedInitialWeek,
      phase: _phaseController.text,
      tags: _tagsController.text,
      notes: _notesController.text,
    );
  }

  void _scheduleEditorContentChanged() {
    if (!widget.editorMode || _loading) {
      return;
    }
    _editorController.scheduleContentChanged(
      session: _editorSession(),
      editorMode: widget.editorMode,
      loading: _loading,
      onAutosave: () => _saveRoutine(silent: true),
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
    _scheduleEditorContentChanged();
  }

  void _onMetadataEdited() {
    if (!widget.editorMode || _editorController.trackingSuspended || _loading || !mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _loadRoutine() async {
    if (widget.editorMode && widget.customerId != null) {
      await _loadForEditorMode();
      return;
    }
    final loaded = await WorkoutRoutineStorage.load();
    if (!mounted) return;
    setState(() {
      _routine = hydrateScheduledWeekdays(loaded);
      _routineNameController.text = loaded.name;
      _selectedWeekIndex = 0;
      _selectedDayIndex = 0;
      _loading = false;
    });
  }

  Future<void> _loadForEditorMode() async {
    final customerId = widget.customerId!;
    try {
      Customer? customer;
      _editorController.suspendTracking();
      String? loadedPlanId;
      var loadedInitialWeek = _initialWeekNumber;
      if (widget.planId != null && widget.planId!.isNotEmpty) {
        final plan = await _planRepo.getById(widget.planId!);
        if (plan != null && mounted) {
          final routine = hydrateScheduledWeekdays(
            planDataToRoutine(plan.planData),
          );
          final (weekIndex, dayIndex) = _resolveInitialSelection(routine);
          loadedPlanId = plan.id;
          loadedInitialWeek = plan.initialWeekNumber;
          setState(() {
            _routine = routine;
            _routineNameController.text = routine.name;
            _phaseController.text = plan.phase ?? '';
            _tagsController.text = plan.tags ?? '';
            _notesController.text = plan.notes ?? '';
            _initialWeekNumber = plan.initialWeekNumber;
            _initialWeekController.text = plan.initialWeekNumber.toString();
            _selectedWeekIndex = weekIndex;
            _selectedDayIndex = dayIndex;
            _planCompleted = completedAtForPlan(plan) != null;
            _planArchived = isArchivedPlan(plan);
          });
        }
      } else {
        setState(() {
          _selectedWeekIndex = 0;
          _selectedDayIndex = 0;
        });
      }
      try {
        customer = await _customerRepo.getById(customerId);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _editorCustomer = customer;
        _loading = false;
      });
      _editorController.markLoaded(
        session: _editorSession(),
        planId: loadedPlanId,
        loadedInitialWeekNumber: loadedInitialWeek,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedWeekIndex = 0;
        _selectedDayIndex = 0;
        _loading = false;
      });
      _editorController.markLoaded(session: _editorSession());
    }
  }

  (int, int) _resolveInitialSelection(WorkoutRoutine routine) {
    final week = _pendingSelectedWeekIndex;
    final day = _pendingSelectedDayIndex;
    if (week == null || day == null) {
      return (0, 0);
    }
    if (week < 0 || week >= routine.weeks.length) {
      return (0, 0);
    }
    final days = routine.weeks[week].days;
    if (day < 0 || day >= days.length) {
      return (week, 0);
    }
    _pendingSelectedWeekIndex = null;
    _pendingSelectedDayIndex = null;
    return (week, day);
  }

  Future<void> _pickRoutineStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _routine.startDate ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _routine = _routine.copyWith(
        startDate: DateTime(picked.year, picked.month, picked.day),
      );
    });
  }

  Future<void> _pickRoutineEndDate() async {
    final now = DateTime.now();
    final fallback = DateTime(now.year, now.month, now.day);
    final initial = _routine.endDate ?? _routine.startDate ?? fallback;
    final firstDate = _routine.startDate ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _routine = _routine.copyWith(
        endDate: DateTime(picked.year, picked.month, picked.day),
      );
    });
  }

  Future<bool> _saveRoutine({bool silent = false}) async {
    if (widget.editorMode && widget.customerId != null) {
      if (_editorController.saving) return false;
      final outcome = await _editorController.save(
        session: _editorSession(),
        customerId: widget.customerId!,
        pdfHeader: _editorCustomer?.pdfHeader,
        useCustomPdfHeader: _editorCustomer?.useCustomPdfHeader ?? false,
        silent: silent,
      );
      if (!mounted) return outcome.success;
      if (outcome.success) {
        setState(() {
          if (outcome.savedRoutine != null) {
            _routine = outcome.savedRoutine!;
          }
          if (outcome.savedInitialWeekNumber != null) {
            _initialWeekNumber = outcome.savedInitialWeekNumber!;
          }
        });
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).workoutBuilderPlanSaved,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: StitchM3Theme.accent,
            ),
          );
        }
        final createdPlanId = outcome.createdPlanId;
        if (createdPlanId != null && createdPlanId.isNotEmpty && mounted) {
          navigateReplace(
            context,
            customerWorkoutEditorPath(
              widget.customerId!,
              planId: createdPlanId,
              weekIndex: _selectedWeekIndex,
              dayIndex: _selectedDayIndex,
            ),
          );
        }
      } else if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).workoutExportError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
      return outcome.success;
    }

    if (_saving) return false;
    if (mounted) setState(() => _saving = true);
    final name = _routineNameController.text.trim();
    final toSave = _routine.copyWith(name: name.isEmpty ? _routine.name : name);

    try {
      await WorkoutRoutineStorage.save(toSave);
      if (!mounted) return true;
      setState(() {
        _routine = toSave;
      });
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).workoutBuilderRoutineSaved,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: StitchM3Theme.accent,
          ),
        );
      }
      return true;
    } catch (_) {
      if (!mounted) return false;
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).workoutExportError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<Customer?> _loadCustomerIfNeeded() async {
    if (widget.editorMode && _editorCustomer != null) return _editorCustomer;
    final customerId =
        widget.customerId ??
        GoRouterState.of(context).uri.queryParameters['customerId'];
    if (customerId == null || customerId.isEmpty) return null;
    try {
      return await _customerRepo.getById(customerId);
    } catch (_) {
      return null;
    }
  }

  void _showPdfExportSheet() {
    showWorkoutExportSheet(
      context: context,
      routine: _routine,
      onExportPdf: (options) {
        _exportPdfAndShare(
          options.layout,
          includeMobility: options.includeMobility,
        );
      },
    );
  }

  Future<_WorkoutEditorExitAction?> _showUnsavedChangesDialog() async {
    final l10n = AppLocalizations.of(context);
    return showDialog<_WorkoutEditorExitAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.workoutEditorUnsavedTitle),
        content: Text(l10n.workoutEditorUnsavedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_WorkoutEditorExitAction.cancel),
            child: Text(l10n.workoutEditorCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_WorkoutEditorExitAction.discard),
            child: Text(l10n.workoutEditorDiscard),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_WorkoutEditorExitAction.save),
            child: Text(l10n.workoutEditorSaveAndExit),
          ),
        ],
      ),
    );
  }

  void _navigateBackToPreviousScreen() {
    final customerId = widget.customerId;
    if (widget.editorMode &&
        customerId != null &&
        customerId.isNotEmpty &&
        customerId != kWorkoutPlanTemplateScopeId) {
      navigateBack(context, fallback: customerWorkoutsPath(customerId));
      return;
    }
    if (widget.editorMode && customerId == kWorkoutPlanTemplateScopeId) {
      navigateBack(context, fallback: '/workouts/templates');
      return;
    }
    navigateBack(context, fallback: '/workouts/builder');
  }

  Future<void> _handleExitAttempt() async {
    if (!widget.editorMode || !_isDirty) {
      _navigateBackToPreviousScreen();
      return;
    }
    final action = await _showUnsavedChangesDialog();
    if (!mounted ||
        action == null ||
        action == _WorkoutEditorExitAction.cancel) {
      return;
    }
    if (action == _WorkoutEditorExitAction.discard) {
      _navigateBackToPreviousScreen();
      return;
    }
    final didSave = await _saveRoutine();
    if (didSave && mounted) {
      _navigateBackToPreviousScreen();
    }
  }

  Future<PdfCoachHeaderInfo> _resolvePdfCoachHeader() async {
    final labels = AppLocalizations.of(context).toPdfExportLabels();
    final customer = await _loadCustomerIfNeeded();
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

  Future<void> _exportPdfAndShare(
    WorkoutPdfLayout layout, {
    required bool includeMobility,
  }) async {
    final l10n = AppLocalizations.of(context);
    final labels = l10n.toPdfExportLabels();
    final name = _routineNameController.text.trim();
    final routine = _routine.copyWith(
      name: name.isEmpty ? _routine.name : name,
    );
    showPdfExportProgressDialog(context, message: labels.exportGenerating);
    try {
      final customer = await _loadCustomerIfNeeded();
      final coachHeader = await _resolvePdfCoachHeader();
      final planMetadata = buildPdfPlanMetadata(
        routine: routine,
        labels: labels,
        clientName: customer?.name,
      );
      final artifact = await exportWorkoutRoutineToPdf(
        routine,
        labels: labels,
        coachHeader: coachHeader,
        planMetadata: planMetadata,
        layout: layout,
        includeMobility: includeMobility,
      );
      if (!mounted) return;
      await downloadExportArtifact(artifact);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    } finally {
      if (mounted) hidePdfExportProgressDialog(context);
    }
  }

  Future<void> _exportJsonAndDownload() async {
    final l10n = AppLocalizations.of(context);
    final name = _routineNameController.text.trim();
    final routine = _routine.copyWith(
      name: name.isEmpty ? _routine.name : name,
    );
    try {
      final artifact = await exportWorkoutRoutineToJson(routine);
      if (!mounted) return;
      await downloadExportArtifact(artifact);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _importJsonFromFile() async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

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
      final imported = decodeWorkoutRoutineJson(content);
      if (!mounted) return;
      setState(() {
        _routine = hydrateScheduledWeekdays(imported);
        _routineNameController.text = imported.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutImportJsonSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutImportJsonError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _exportExcelAndShare() async {
    final l10n = AppLocalizations.of(context);
    final name = _routineNameController.text.trim();
    final routine = _routine.copyWith(
      name: name.isEmpty ? _routine.name : name,
    );
    try {
      final artifact = await exportWorkoutRoutineToExcel(routine);
      if (!mounted) return;
      await downloadExportArtifact(artifact);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _exportCurrentDayToHevy() async {
    final l10n = AppLocalizations.of(context);
    final hasKey = await HevySettingsStore.instance.hasApiKey();
    if (!hasKey) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.hevyExportNoCatalogHint)));
      return;
    }
    if (_routine.weeks.isEmpty) return;
    final weekIndex = _selectedWeekIndex.clamp(0, _routine.weeks.length - 1);
    final week = _routine.weeks[weekIndex];
    if (week.days.isEmpty) return;
    final dayIndex = _selectedDayIndex.clamp(0, week.days.length - 1);
    final day = week.days[dayIndex];
    final programName = _routineNameController.text.trim().isEmpty
        ? _routine.name
        : _routineNameController.text.trim();

    if (!mounted) return;
    await showHevyExportReviewSheet(
      context: context,
      day: day,
      programName: programName,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      customerName: _editorCustomer?.name,
    );
  }

  String? get _selectedSectionId {
    final sections = _routine.mobilitySections;
    if (sections.isEmpty) return null;
    final idx = _selectedMobilitySectionIndex.clamp(0, sections.length - 1);
    return sections[idx].id;
  }

  List<MobilityItem> get _mobilityItemsForSelectedSection {
    final sid = _selectedSectionId;
    if (sid == null) return [];
    return _routine.mobilityItems.where((e) => e.sectionId == sid).toList();
  }

  void _addMobilityItem() {
    final sectionId = _selectedSectionId;
    if (sectionId == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    showAddMobilityExerciseDialog(context, theme, cs, (
      title,
      subtitle,
      customExerciseId,
    ) {
      final t = title.trim();
      final s = subtitle.trim();
      if (t.isEmpty && s.isEmpty) return;
      setState(() {
        final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
        _routine = _routine.copyWith(
          mobilityItems: [
            ..._routine.mobilityItems,
            MobilityItem(
              id: id,
              title: t.isEmpty ? l10n.workoutBuilderNewExerciseDefault : t,
              subtitle: s,
              sectionId: sectionId,
              customExerciseId: customExerciseId,
            ),
          ],
        );
      });
    });
  }

  void _removeMobilityItem(String id) {
    setState(() {
      _routine = _routine.copyWith(
        mobilityItems: _routine.mobilityItems.where((e) => e.id != id).toList(),
      );
    });
  }

  void _reorderMobility(int oldIndex, int newIndex) {
    final sectionId = _selectedSectionId;
    if (sectionId == null) return;
    final sectionItems = _mobilityItemsForSelectedSection;
    if (oldIndex < 0 ||
        oldIndex >= sectionItems.length ||
        newIndex < 0 ||
        newIndex >= sectionItems.length) {
      return;
    }
    setState(() {
      final reordered = List<MobilityItem>.from(sectionItems);
      final item = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, item);
      final others = _routine.mobilityItems
          .where((e) => e.sectionId != sectionId)
          .toList();
      _routine = _routine.copyWith(mobilityItems: [...others, ...reordered]);
    });
  }

  void _addMobilitySection() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      final id = 'sec_${DateTime.now().millisecondsSinceEpoch}';
      final name = l10n.workoutBuilderSectionNumbered(
        _routine.mobilitySections.length + 1,
      );
      _routine = _routine.copyWith(
        mobilitySections: [
          ..._routine.mobilitySections,
          MobilitySection(id: id, name: name),
        ],
      );
      _selectedMobilitySectionIndex = _routine.mobilitySections.length - 1;
    });
  }

  void _editMobilitySection(int index) {
    if (index < 0 || index >= _routine.mobilitySections.length) return;
    final section = _routine.mobilitySections[index];
    _showEditSectionDialog(section.name, section.scheduleHint, (
      newName,
      scheduleHint,
    ) {
      if (newName.trim().isEmpty) return;
      setState(() {
        final updated = _routine.mobilitySections
            .map(
              (s) => s.id == section.id
                  ? s.copyWith(
                      name: newName.trim(),
                      scheduleHint: scheduleHint.trim(),
                    )
                  : s,
            )
            .toList();
        _routine = _routine.copyWith(mobilitySections: updated);
      });
    });
  }

  void _deleteMobilitySection(int index) {
    if (index < 0 || index >= _routine.mobilitySections.length) return;
    if (_routine.mobilitySections.length <= 1) {
      return; // keep at least one section
    }
    final section = _routine.mobilitySections[index];
    final firstOtherId = _routine.mobilitySections
        .firstWhere((s) => s.id != section.id)
        .id;
    setState(() {
      _routine = _routine.copyWith(
        mobilitySections: _routine.mobilitySections
            .where((s) => s.id != section.id)
            .toList(),
        mobilityItems: _routine.mobilityItems
            .map(
              (m) => m.sectionId == section.id
                  ? m.copyWith(sectionId: firstOtherId)
                  : m,
            )
            .toList(),
      );
      _selectedMobilitySectionIndex = (_selectedMobilitySectionIndex.clamp(
        0,
        _routine.mobilitySections.length - 1,
      ));
    });
  }

  void _showEditSectionDialog(
    String initialName,
    String initialScheduleHint,
    void Function(String name, String scheduleHint) onSave,
  ) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: initialName);
    final scheduleController = TextEditingController(text: initialScheduleHint);
    showAppBottomSheet<void>(
      context: context,
      title: l10n.workoutBuilderEditSectionTitle,
      bodyBuilder: (sheetContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.workoutBuilderSectionNameLabel,
              ),
              autofocus: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: scheduleController,
              decoration: InputDecoration(
                labelText: l10n.mobilitySectionScheduleHintLabel,
              ),
              maxLines: 2,
            ),
          ],
        );
      },
      primaryActionLabel: l10n.customerSave,
      onPrimaryAction: () {
        onSave(nameController.text.trim(), scheduleController.text.trim());
        Navigator.of(context).pop();
      },
    );
  }

  void _addWeek() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      final id = 'w_${DateTime.now().millisecondsSinceEpoch}';
      final next = _routine.weeks.length + 1;
      _routine = addWeekToRoutine(
        routine: _routine,
        weekId: id,
        weekName: l10n.workoutBuilderWeekNumbered(next),
        firstDayId: '${id}_d1',
        firstDayName: l10n.workoutBuilderDayNumbered(1),
      );
      _selectedWeekIndex = _routine.weeks.length - 1;
      _selectedDayIndex = 0;
    });
  }

  Future<void> _cloneWeek(int weekIndex) async {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final source = _routine.weeks[weekIndex];
    final l10n = AppLocalizations.of(context);
    final defaultName = '${source.name}${l10n.workoutBuilderNameCopySuffix}';
    final name = await showDuplicateWeekDialog(context, defaultName);
    if (!mounted || name == null || name.isEmpty) return;
    _cloneWeekWithName(weekIndex, name);
  }

  void _cloneWeekWithName(int weekIndex, String name) {
    final newId = 'w_${DateTime.now().millisecondsSinceEpoch}';
    final updated = cloneWeekInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      newWeekName: name,
      newWeekId: newId,
    );
    if (updated == null) return;
    setState(() {
      _routine = updated;
      _selectedWeekIndex = _routine.weeks.length - 1;
      _selectedDayIndex = 0;
    });
  }

  void _deleteWeek(int weekIndex) {
    final updated = deleteWeekFromRoutine(routine: _routine, weekIndex: weekIndex);
    if (updated == null) return;
    setState(() {
      _routine = updated;
      _selectedWeekIndex = _selectedWeekIndex.clamp(
        0,
        _routine.weeks.isNotEmpty ? _routine.weeks.length - 1 : 0,
      );
    });
  }

  Future<void> _confirmDeleteWeek(BuildContext context, int weekIndex) async {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.workoutBuilderDeleteWeekTitle,
      message: l10n.workoutBuilderDeleteWeekMessage,
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (confirmed && mounted) _deleteWeek(weekIndex);
  }

  void _renameDay(int weekIndex, int dayIndex, String newName) {
    final updated = renameDayInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      newName: newName,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _renameWeek(int weekIndex, String newName) {
    final updated = renameWeekInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      newName: newName,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _deleteDay(int weekIndex, int dayIndex) {
    final updated = deleteDayFromRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
    );
    if (updated == null) return;
    setState(() {
      _routine = updated;
      final week = _routine.weeks[weekIndex.clamp(0, _routine.weeks.length - 1)];
      _selectedDayIndex = _selectedDayIndex.clamp(
        0,
        week.days.isNotEmpty ? week.days.length - 1 : 0,
      );
    });
  }

  void _addDayToWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    final week = _routine.weeks[weekIndex];
    final dayId = '${week.id}_d_${DateTime.now().millisecondsSinceEpoch}';
    final updated = addDayToWeekInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayId: dayId,
      dayName: l10n.workoutBuilderDayNumbered(week.days.length + 1),
    );
    if (updated == null) return;
    setState(() {
      _routine = updated;
      _selectedWeekIndex = weekIndex;
      _selectedDayIndex = updated.weeks[weekIndex].days.length - 1;
    });
  }

  void _setDayScheduledWeekday(int weekIndex, int dayIndex, int weekday) {
    final updated = setDayScheduledWeekdayInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      weekday: weekday,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _addExerciseToDay(int weekIndex, int dayIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    if (dayIndex < 0 || dayIndex >= _routine.weeks[weekIndex].days.length) {
      return;
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    showAddExerciseDialog(context, theme, cs, (
      name,
      note,
      details, [
      customExerciseId,
    ]) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) return;
      final updated = addExerciseToDayInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exercise: buildExerciseFromPrescription(
          id: exId,
          name: trimmedName,
          note: note,
          setDetails: details,
          customExerciseId: customExerciseId,
        ),
      );
      if (updated == null) return;
      setState(() => _routine = updated);
    }, customerId: widget.customerId);
  }

  /// Adds a new exercise to the day and assigns it to the given superset group.
  /// The new exercise is inserted immediately after the last exercise of that group.
  /// Stesso dialog multi-serie della creazione normale.
  void _addExerciseToSuperset(
    int weekIndex,
    int dayIndex,
    String supersetGroupId,
  ) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    if (dayIndex < 0 || dayIndex >= _routine.weeks[weekIndex].days.length) {
      return;
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    showAddExerciseDialog(context, theme, cs, (
      name,
      note,
      details, [
      customExerciseId,
    ]) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) return;
      final updated = addExerciseToSupersetInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        supersetGroupId: supersetGroupId,
        exercise: buildExerciseFromPrescription(
          id: exId,
          name: trimmedName,
          note: note,
          setDetails: details,
          customExerciseId: customExerciseId,
          supersetGroupId: supersetGroupId,
        ),
      );
      if (updated == null) return;
      setState(() => _routine = updated);
    }, customerId: widget.customerId);
  }

  void _removeExercise(int weekIndex, int dayIndex, String exerciseId) {
    final updated = removeExerciseFromDayInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _moveExerciseInDay(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    required bool up,
  }) {
    final updated = moveExerciseInDayInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      up: up,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _updateMobilityItem(
    String id,
    String title,
    String subtitle, {
    String shortTitle = '',
  }) {
    setState(() {
      _routine = _routine.copyWith(
        mobilityItems: _routine.mobilityItems
            .map(
              (e) => e.id == id
                  ? e.copyWith(
                      title: title,
                      subtitle: subtitle,
                      shortTitle: shortTitle,
                    )
                  : e,
            )
            .toList(),
      );
    });
  }

  void _updateExercise(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  }) {
    final updated = updateExerciseInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      name: name,
      sets: sets,
      reps: reps,
      rpe: rpe,
      note: note,
      shortName: shortName,
      prescriptionScope: prescriptionScope,
      setDetails: setDetails,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _addSetToExercise(int weekIndex, int dayIndex, String exerciseId) {
    final updated = addSetToExerciseInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _updateExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) {
    final updated = updateExerciseSetInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      setIndex: setIndex,
      line: line,
      sets: sets,
      reps: reps,
      rpe: rpe,
      note: note,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _removeExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex,
  ) {
    final updated = removeExerciseSetInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      setIndex: setIndex,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _assignToSuperset(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    String supersetGroupId,
  ) {
    final updated = assignExerciseToSupersetInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      supersetGroupId: supersetGroupId,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _removeFromSuperset(int weekIndex, int dayIndex, String exerciseId) {
    final updated = removeExerciseFromSupersetInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  @override
  void dispose() {
    _editorController.dispose();
    _routineNameController.removeListener(_onMetadataEdited);
    _initialWeekController.removeListener(_onMetadataEdited);
    _phaseController.removeListener(_onMetadataEdited);
    _tagsController.removeListener(_onMetadataEdited);
    _notesController.removeListener(_onMetadataEdited);
    _sectionTabController.dispose();
    _routineNameController.dispose();
    _initialWeekController.dispose();
    _phaseController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildRoutineNameBar(
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _routineNameController,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: l10n.workoutBuilderRoutineNameHint,
          hintStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
          ),
          prefixIcon: Icon(Icons.fitness_center, color: StitchM3Theme.accent),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(ThemeData theme, ColorScheme cs) {
    return WorkoutPlanDetailsTab(
      routine: _routine,
      editorMode: widget.editorMode,
      initialWeekController: _initialWeekController,
      phaseController: _phaseController,
      tagsController: _tagsController,
      notesController: _notesController,
      onPickStartDate: _pickRoutineStartDate,
      onPickEndDate: _pickRoutineEndDate,
      onInitialWeekChanged: (value) {
        final v = int.tryParse(value);
        if (v != null && v >= 1) {
          setState(() => _initialWeekNumber = v);
        }
      },
      onCurrentWeekChanged: (value) {
        setState(() {
          _routine = _routine.copyWith(currentWeek: value);
        });
      },
      onMetadataChanged: _onMetadataEdited,
      planCompleted: _planCompleted,
      planArchived: _planArchived,
      onMarkCompleted: _editorController.loadedPlanId != null &&
              !_planCompleted &&
              !_planArchived
          ? _markPlanCompletedFromEditor
          : null,
    );
  }

  Future<void> _markPlanCompletedFromEditor() async {
    final planId = _editorController.loadedPlanId;
    if (planId == null) return;
    final l10n = AppLocalizations.of(context);
    try {
      await _planRepo.markPlanCompleted(planId);
      if (!mounted) return;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      setState(() {
        _planCompleted = true;
        _routine = _routine.copyWith(endDate: _routine.endDate ?? today);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutPlanCompleteAction),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildMobilityTab(ThemeData theme, ColorScheme cs) {
    return WorkoutMobilityTab(
      theme: theme,
      colorScheme: cs,
      sections: _routine.mobilitySections,
      selectedSectionIndex: _selectedMobilitySectionIndex,
      itemsForSelectedSection: _mobilityItemsForSelectedSection,
      onAddItem: _addMobilityItem,
      onAddSection: _addMobilitySection,
      onEditSection: _editMobilitySection,
      onDeleteSection: _deleteMobilitySection,
      onSelectSection: (i) => setState(() => _selectedMobilitySectionIndex = i),
      onReorderItems: _reorderMobility,
      onUpdateItem: (itemId, t, s, short) =>
          _updateMobilityItem(itemId, t, s, shortTitle: short),
      onDeleteItem: _removeMobilityItem,
    );
  }

  Widget _buildTrainingTab(ThemeData theme, ColorScheme cs) {
    return WorkoutTrainingTab(
      theme: theme,
      cs: cs,
      embeddedInTab: true,
      weeks: _routine.weeks,
      selectedWeekIndex: _selectedWeekIndex,
      selectedDayIndex: _selectedDayIndex,
      onNewWeek: _addWeek,
      onCloneWeek: _cloneWeek,
      onDeleteWeek: (weekIndex) => _confirmDeleteWeek(context, weekIndex),
      onRenameWeek: _renameWeek,
      onAddDay: _addDayToWeek,
      onRenameDay: _renameDay,
      onDeleteDay: _deleteDay,
      onAddExercise: _addExerciseToDay,
      onRemoveExercise: _removeExercise,
      onMoveExercise: _moveExerciseInDay,
      onUpdateExercise: _updateExercise,
      onAddSetToExercise: _addSetToExercise,
      onUpdateExerciseSet: _updateExerciseSet,
      onRemoveExerciseSet: _removeExerciseSet,
      onAssignToSuperset: _assignToSuperset,
      onRemoveFromSuperset: _removeFromSuperset,
      onAddExerciseToSuperset: _addExerciseToSuperset,
      onSelectWeek: (i) => setState(() {
        _selectedWeekIndex = i;
        _selectedDayIndex = 0;
      }),
      onSelectDay: (i) => setState(() => _selectedDayIndex = i),
      onUpdateScheduledWeekday: _setDayScheduledWeekday,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final hideExportMenu =
        widget.editorMode && widget.customerId == kWorkoutPlanTemplateScopeId;

    Widget buildShell({
      required bool canPop,
      required bool saving,
      required bool showManualSaveButton,
      Widget? saveStatusIndicator,
    }) {
      return PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleExitAttempt();
        },
        child: Scaffold(
          appBar: WorkoutEditorAppBar(
            theme: theme,
            colorScheme: cs,
            l10n: l10n,
            editorMode: widget.editorMode,
            loading: _loading,
            hideExportMenu: hideExportMenu,
            saving: saving,
            showManualSaveButton: showManualSaveButton,
            onBack: () async {
              HapticFeedback.mediumImpact();
              await _handleExitAttempt();
            },
            onOpenTemplates: () {
              HapticFeedback.mediumImpact();
              context.push('/workouts/templates');
            },
            onImportJson: _importJsonFromFile,
            onExport: (value) {
              if (value == 'pdf') _showPdfExportSheet();
              if (value == 'excel') _exportExcelAndShare();
              if (value == 'json') _exportJsonAndDownload();
              if (value == 'hevy') _exportCurrentDayToHevy();
            },
            onSave: () {
              _saveRoutine();
            },
            saveStatusIndicator: saveStatusIndicator,
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildRoutineNameBar(theme, cs, l10n),
                    TabBar(
                      controller: _sectionTabController,
                      labelColor: StitchM3Theme.accent,
                      unselectedLabelColor: cs.onSurfaceVariant,
                      indicatorColor: StitchM3Theme.accent,
                      tabs: [
                        Tab(text: l10n.workoutBuilderTabTraining),
                        if (_showsMobilityTab)
                          Tab(text: l10n.workoutBuilderTabMobility),
                        Tab(text: l10n.workoutBuilderTabDetails),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _sectionTabController,
                        children: [
                          WorkoutLazyTab(
                            tabController: _sectionTabController,
                            tabIndex: 0,
                            builder: (_) => RepaintBoundary(
                              child: _buildTrainingTab(theme, cs),
                            ),
                          ),
                          if (_showsMobilityTab)
                            WorkoutLazyTab(
                              tabController: _sectionTabController,
                              tabIndex: 1,
                              builder: (_) => RepaintBoundary(
                                child: _buildMobilityTab(theme, cs),
                              ),
                            ),
                          WorkoutLazyTab(
                            tabController: _sectionTabController,
                            tabIndex: _showsMobilityTab ? 2 : 1,
                            builder: (_) => _buildDetailsTab(theme, cs),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.editorMode)
                      WorkoutBuilderBottomNav(
                        navContext: context,
                        selectedIndex: 0,
                      ),
                  ],
                ),
        ),
      );
    }

    if (!widget.editorMode) {
      return buildShell(
        canPop: true,
        saving: _saving,
        showManualSaveButton: true,
        saveStatusIndicator: null,
      );
    }

    return ListenableBuilder(
      listenable: _editorController,
      builder: (context, _) => buildShell(
        canPop: !_editorController.isDirty,
        saving: _editorController.saving,
        showManualSaveButton: _editorController.shouldShowManualSaveButton(
          loading: _loading,
          editorMode: widget.editorMode,
        ),
        saveStatusIndicator: !_loading
            ? WorkoutEditorSaveStatusIndicator(
                saveState: _editorController.saveState,
                l10n: l10n,
                colorScheme: cs,
                textTheme: theme.textTheme,
                editorMode: widget.editorMode,
                hasLoadedPlan: _editorController.loadedPlanId != null,
              )
            : null,
      ),
    );
  }
}
