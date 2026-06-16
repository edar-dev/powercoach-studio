import 'dart:async';
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
import '../../domain/exercise_summary_sync.dart';
import '../../domain/export_pdf_usecase.dart';
import '../../../../core/pdf/pdf_plan_metadata.dart';
import '../../domain/workout_routine_json_codec.dart';
import '../workout_editor_snapshot.dart';
import '../widgets/training_week_day_panel.dart';
import '../widgets/workout_builder_bottom_nav.dart';
import '../widgets/workout_editor_app_bar.dart';
import '../widgets/workout_export_sheet.dart';
import '../widgets/exercise_add_sheet.dart';
import '../widgets/exercise_set_edit_controllers.dart';
import '../widgets/mobility_add_sheet.dart';
import '../widgets/workout_plan_details_tab.dart';
import '../../../integrations/hevy/data/hevy_settings_store.dart';
import '../../../integrations/hevy/presentation/hevy_export_review_sheet.dart';
import '../../../customers/data/models/customer.dart' show Customer;

/// Returns list of superset group options for the day (id + label) for "Add to superset" menu.
List<({String id, String label})> _getSupersetGroupOptions(Day day) {
  final byId = <String, List<Exercise>>{};
  for (final e in day.exercises) {
    final id = e.supersetGroupId;
    if (id != null && id.isNotEmpty) {
      byId.putIfAbsent(id, () => []).add(e);
    }
  }
  return byId.entries
      .map((e) => (id: e.key, label: e.value.map((x) => x.name).join(' + ')))
      .toList();
}

/// Workout Builder variant: Enhanced Mobility (694ace9b), Multi-set (9ffa631f), Super Set (e63b1ef6), Intuitive Super Set (7ce630e5).
enum WorkoutBuilderVariant { mobility, multiset, superset, intuitiveSuperset }

enum _WorkoutEditorExitAction { save, discard, cancel }

enum _WorkoutEditorSaveState { saved, saving, unsaved }

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
  String? _loadedPlanId;
  Customer? _editorCustomer;
  WorkoutRoutine _routine = WorkoutRoutine.empty();
  bool _loading = true;
  bool _saving = false;
  bool _suspendEditorTracking = false;
  int _initialWeekNumber = 1;
  int _selectedMobilitySectionIndex = 0;
  int _selectedWeekIndex = 0;
  int _selectedDayIndex = 0;
  int? _pendingSelectedWeekIndex;
  int? _pendingSelectedDayIndex;
  bool _didReadDeepLinkSelection = false;
  late final TabController _sectionTabController;
  Timer? _autosaveTimer;
  String? _savedSnapshot;
  String? _lastObservedSnapshot;
  _WorkoutEditorSaveState _editorSaveState = _WorkoutEditorSaveState.saved;

  bool get _showsMobilityTab =>
      widget.variant == WorkoutBuilderVariant.mobility;

  bool get _isDirty => isWorkoutEditorDirty(
    savedSnapshot: _savedSnapshot,
    currentSnapshot: _currentSnapshot(),
  );

  bool get _shouldShowManualSaveButton {
    if (_loading) return false;
    if (!widget.editorMode) return true;
    if (_loadedPlanId == null) return true;
    return _editorSaveState != _WorkoutEditorSaveState.saved;
  }

  @override
  void initState() {
    super.initState();
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

  String _currentSnapshot() {
    final parsedInitialWeek = int.tryParse(_initialWeekController.text.trim());
    final resolvedInitialWeek =
        (parsedInitialWeek != null && parsedInitialWeek >= 1)
        ? parsedInitialWeek
        : _initialWeekNumber;
    return buildWorkoutEditorSnapshot(
      routine: _routine,
      planName: _routineNameController.text,
      initialWeekNumber: resolvedInitialWeek,
      phase: _phaseController.text,
      tags: _tagsController.text,
      notes: _notesController.text,
    );
  }

  void _captureSavedSnapshot() {
    final snapshot = _currentSnapshot();
    _savedSnapshot = snapshot;
    _lastObservedSnapshot = snapshot;
    _editorSaveState = _WorkoutEditorSaveState.saved;
  }

  void _onMetadataEdited() {
    if (!widget.editorMode || _suspendEditorTracking || _loading || !mounted) {
      return;
    }
    setState(() {});
  }

  void _trackEditorChangesIfNeeded() {
    if (!widget.editorMode || _suspendEditorTracking || _loading) {
      return;
    }
    final current = _currentSnapshot();
    if (_lastObservedSnapshot == current) {
      return;
    }
    _lastObservedSnapshot = current;
    final nextState = _isDirty
        ? _WorkoutEditorSaveState.unsaved
        : _WorkoutEditorSaveState.saved;
    if (_editorSaveState != nextState) {
      _editorSaveState = nextState;
    }
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    if (!widget.editorMode || _loadedPlanId == null || !_isDirty) {
      return;
    }
    _autosaveTimer = Timer(const Duration(milliseconds: 2500), () {
      _saveRoutine(silent: true);
    });
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
      _suspendEditorTracking = true;
      if (widget.planId != null && widget.planId!.isNotEmpty) {
        final plan = await _planRepo.getById(widget.planId!);
        if (plan != null && mounted) {
          final routine = hydrateScheduledWeekdays(
            planDataToRoutine(plan.planData),
          );
          final (weekIndex, dayIndex) = _resolveInitialSelection(routine);
          setState(() {
            _routine = routine;
            _routineNameController.text = routine.name;
            _phaseController.text = plan.phase ?? '';
            _tagsController.text = plan.tags ?? '';
            _notesController.text = plan.notes ?? '';
            _loadedPlanId = plan.id;
            _initialWeekNumber = plan.initialWeekNumber;
            _initialWeekController.text = plan.initialWeekNumber.toString();
            _selectedWeekIndex = weekIndex;
            _selectedDayIndex = dayIndex;
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
        _captureSavedSnapshot();
      });
      _suspendEditorTracking = false;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedWeekIndex = 0;
        _selectedDayIndex = 0;
        _loading = false;
        _captureSavedSnapshot();
      });
      _suspendEditorTracking = false;
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

  int _weekdayFromDayIndex(int dayIndex) => inferredScheduledWeekday(dayIndex);

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
    if (_saving) return false;
    _autosaveTimer?.cancel();
    if (mounted) {
      setState(() {
        _saving = true;
        if (widget.editorMode) {
          _editorSaveState = _WorkoutEditorSaveState.saving;
        }
      });
    }
    final name = _routineNameController.text.trim();
    final toSave = _routine.copyWith(name: name.isEmpty ? _routine.name : name);
    final savedInitialWeek = () {
      final v = int.tryParse(_initialWeekController.text.trim());
      return (v != null && v >= 1) ? v : _initialWeekNumber;
    }();
    final phase = _phaseController.text.trim();
    final tags = _tagsController.text.trim();
    final notes = _notesController.text.trim();

    var success = false;
    var createdPlanIdForUrlSync = '';
    try {
      if (widget.editorMode && widget.customerId != null) {
        if (_loadedPlanId != null) {
          final existingPlan = await _planRepo.getById(_loadedPlanId!);
          await _planRepo.update(
            planId: _loadedPlanId!,
            name: toSave.name,
            planDataJson: _encodeRoutine(
              toSave,
              existingPlanData: existingPlan?.planData,
            ),
            initialWeekNumber: savedInitialWeek,
            phase: phase.isEmpty ? null : phase,
            tags: tags.isEmpty ? null : tags,
            notes: notes.isEmpty ? null : notes,
          );
        } else {
          final created = await _planRepo.create(
            customerId: widget.customerId!,
            name: toSave.name,
            planDataJson: _encodeRoutine(toSave),
            initialWeekNumber: savedInitialWeek,
            pdfHeader: _editorCustomer?.pdfHeader,
            useCustomPdfHeader: _editorCustomer?.useCustomPdfHeader ?? false,
            phase: phase.isEmpty ? null : phase,
            tags: tags.isEmpty ? null : tags,
            notes: notes.isEmpty ? null : notes,
          );
          createdPlanIdForUrlSync = created.id;
          if (mounted) {
            setState(() => _loadedPlanId = created.id);
          }
        }
        success = true;
        if (!mounted) return success;
        setState(() {
          _routine = toSave;
          _initialWeekNumber = savedInitialWeek;
          _captureSavedSnapshot();
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
        if (createdPlanIdForUrlSync.isNotEmpty && mounted) {
          navigateReplace(
            context,
            customerWorkoutEditorPath(
              widget.customerId!,
              planId: createdPlanIdForUrlSync,
              weekIndex: _selectedWeekIndex,
              dayIndex: _selectedDayIndex,
            ),
          );
        }
      } else {
        await WorkoutRoutineStorage.save(toSave);
        success = true;
        if (!mounted) return success;
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
      }
    } catch (_) {
      if (!mounted) return success;
      if (widget.editorMode) {
        setState(() => _editorSaveState = _WorkoutEditorSaveState.unsaved);
      }
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).workoutExportError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    return success;
  }

  static String _encodeRoutine(WorkoutRoutine r, {String? existingPlanData}) {
    final encoded = Map<String, dynamic>.from(r.toJson());
    if (existingPlanData != null && existingPlanData.isNotEmpty) {
      try {
        final existing = jsonDecode(existingPlanData) as Map<String, dynamic>;
        if (existing.containsKey('archivedAt')) {
          encoded['archivedAt'] = existing['archivedAt'];
        }
        if (existing.containsKey('completedAt')) {
          encoded['completedAt'] = existing['completedAt'];
        }
      } catch (_) {}
    }
    return jsonEncode(encoded);
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

  Widget _buildSaveStatusIndicator(AppLocalizations l10n, ColorScheme cs) {
    final (icon, label, foreground, background) = switch (_editorSaveState) {
      _WorkoutEditorSaveState.saving => (
        Icons.sync,
        l10n.workoutEditorAutosaving,
        cs.onPrimaryContainer,
        cs.primaryContainer,
      ),
      _WorkoutEditorSaveState.unsaved => (
        Icons.warning_amber_rounded,
        l10n.workoutEditorUnsavedState,
        const Color(0xFFB45309),
        StitchM3Theme.warning.withValues(alpha: 0.22),
      ),
      _WorkoutEditorSaveState.saved => (
        Icons.check_circle_outline,
        l10n.workoutEditorSavedState,
        StitchM3Theme.success,
        StitchM3Theme.success.withValues(alpha: 0.2),
      ),
    };

    return Tooltip(
      message: widget.editorMode && _loadedPlanId != null
          ? l10n.workoutEditorAutosaveHint
          : label,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: foreground.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
      _routine = _routine.copyWith(
        weeks: [
          ..._routine.weeks,
          Week(
            id: id,
            name: l10n.workoutBuilderWeekNumbered(next),
            days: [
              Day(
                id: '${id}_d1',
                name: l10n.workoutBuilderDayNumbered(1),
                exercises: [],
                scheduledWeekday: _weekdayFromDayIndex(0),
              ),
            ],
          ),
        ],
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
    final name = await _showDuplicateWeekDialog(context, defaultName);
    if (!mounted || name == null || name.isEmpty) return;
    _cloneWeekWithName(weekIndex, name);
  }

  void _cloneWeekWithName(int weekIndex, String name) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    setState(() {
      final source = _routine.weeks[weekIndex];
      final newId = 'w_${DateTime.now().millisecondsSinceEpoch}';
      final newDays = source.days
          .map(
            (d) => Day(
              id: '${newId}_d_${d.id}',
              name: d.name,
              exercises: d.exercises
                  .map(
                    (e) => Exercise(
                      id: '${e.id}_$newId',
                      name: e.name,
                      sets: e.sets,
                      reps: e.reps,
                      rpe: e.rpe,
                      note: e.note,
                      setDetails: e.setDetails
                          ?.map(
                            (s) => ExerciseSet(
                              line: s.line,
                              sets: s.sets,
                              reps: s.reps,
                              rpe: s.rpe,
                              note: s.note,
                            ),
                          )
                          .toList(),
                      supersetGroupId: e.supersetGroupId,
                      customExerciseId: e.customExerciseId,
                    ),
                  )
                  .toList(),
              scheduledWeekday: d.scheduledWeekday,
            ),
          )
          .toList();
      final newWeek = Week(id: newId, name: name, days: newDays);
      _routine = _routine.copyWith(weeks: [..._routine.weeks, newWeek]);
      _selectedWeekIndex = _routine.weeks.length - 1;
      _selectedDayIndex = 0;
    });
  }

  void _deleteWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final weekId = _routine.weeks[weekIndex].id;
    setState(() {
      _routine = _routine.copyWith(
        weeks: _routine.weeks.where((w) => w.id != weekId).toList(),
      );
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
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    final name = newName.trim();
    if (name.isEmpty) return;
    setState(() {
      final day = week.days[dayIndex];
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(name: name);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _renameWeek(int weekIndex, String newName) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final name = newName.trim();
    if (name.isEmpty) return;
    setState(() {
      final week = _routine.weeks[weekIndex];
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(name: name);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _deleteDay(int weekIndex, int dayIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    if (week.days.length <= 1) return; // keep at least one day
    setState(() {
      final newDays = week.days
          .where((d) => d.id != week.days[dayIndex].id)
          .toList();
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
      _selectedDayIndex = _selectedDayIndex.clamp(
        0,
        newDays.isNotEmpty ? newDays.length - 1 : 0,
      );
    });
  }

  void _addDayToWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      final week = _routine.weeks[weekIndex];
      final dayId = '${week.id}_d_${DateTime.now().millisecondsSinceEpoch}';
      final newDays = [
        ...week.days,
        Day(
          id: dayId,
          name: l10n.workoutBuilderDayNumbered(week.days.length + 1),
          exercises: [],
          scheduledWeekday: _weekdayFromDayIndex(week.days.length),
        ),
      ];
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
      _selectedWeekIndex = weekIndex;
      _selectedDayIndex = newDays.length - 1;
    });
  }

  void _setDayScheduledWeekday(int weekIndex, int dayIndex, int weekday) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    if (weekday < DateTime.monday || weekday > DateTime.sunday) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(scheduledWeekday: weekday);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
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
      final list = details.isEmpty ? [const ExerciseSet()] : details;
      setState(() {
        final week = _routine.weeks[weekIndex];
        if (dayIndex < 0 || dayIndex >= week.days.length) return;
        final day = week.days[dayIndex];
        final newExercise = Exercise(
          id: exId,
          name: trimmedName,
          sets: '${list.length}',
          reps: list
              .map((s) => s.displayText)
              .where((r) => r.isNotEmpty)
              .join(' | '),
          rpe: '',
          note: note,
          setDetails: list,
          customExerciseId: customExerciseId,
        );
        final newEx = [...day.exercises, newExercise];
        final newDays = List<Day>.from(week.days);
        newDays[dayIndex] = day.copyWith(exercises: newEx);
        final newWeeks = List<Week>.from(_routine.weeks);
        newWeeks[weekIndex] = week.copyWith(days: newDays);
        _routine = _routine.copyWith(weeks: newWeeks);
      });
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
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    final day = week.days[dayIndex];
    int insertIndex = -1;
    for (var i = day.exercises.length - 1; i >= 0; i--) {
      if (day.exercises[i].supersetGroupId == supersetGroupId) {
        insertIndex = i + 1;
        break;
      }
    }
    if (insertIndex < 0) insertIndex = day.exercises.length;
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
      final list = details.isEmpty ? [const ExerciseSet()] : details;
      setState(() {
        final w = _routine.weeks[weekIndex];
        if (dayIndex < 0 || dayIndex >= w.days.length) return;
        final d = w.days[dayIndex];
        final newExercise = Exercise(
          id: exId,
          name: trimmedName,
          sets: '${list.length}',
          reps: list
              .map((s) => s.displayText)
              .where((r) => r.isNotEmpty)
              .join(' | '),
          rpe: '',
          note: note,
          customExerciseId: customExerciseId,
          setDetails: list,
          supersetGroupId: supersetGroupId,
        );
        final newEx = List<Exercise>.from(d.exercises)
          ..insert(insertIndex, newExercise);
        final newDays = List<Day>.from(w.days);
        newDays[dayIndex] = d.copyWith(exercises: newEx);
        final newWeeks = List<Week>.from(_routine.weeks);
        newWeeks[weekIndex] = w.copyWith(days: newDays);
        _routine = _routine.copyWith(weeks: newWeeks);
      });
    }, customerId: widget.customerId);
  }

  void _removeExercise(int weekIndex, int dayIndex, String exerciseId) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.where((e) => e.id != exerciseId).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _moveExerciseInDay(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    required bool up,
  }) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    final day = week.days[dayIndex];

    final currentIndex = day.exercises.indexWhere((e) => e.id == exerciseId);
    if (currentIndex < 0) return;
    final targetIndex = up ? currentIndex - 1 : currentIndex + 1;
    if (targetIndex < 0 || targetIndex >= day.exercises.length) return;

    setState(() {
      final reordered = List<Exercise>.from(day.exercises);
      final item = reordered.removeAt(currentIndex);
      reordered.insert(targetIndex, item);

      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: reordered);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
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
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) {
        if (e.id != exerciseId) return e;
        return ExerciseSummarySync.apply(
          e.copyWith(
            name: name ?? e.name,
            sets: sets ?? e.sets,
            reps: reps ?? e.reps,
            rpe: rpe ?? e.rpe,
            note: note ?? e.note,
            shortName: shortName ?? e.shortName,
            prescriptionScope: prescriptionScope ?? e.prescriptionScope,
            setDetails: setDetails ?? e.setDetails,
          ),
        );
      }).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _addSetToExercise(int weekIndex, int dayIndex, String exerciseId) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) {
        if (e.id != exerciseId) return e;
        final details = [...e.effectiveSetDetails, const ExerciseSet()];
        return e.copyWith(setDetails: details);
      }).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
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
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) {
        if (e.id != exerciseId) return e;
        final details = e.effectiveSetDetails;
        if (setIndex < 0 || setIndex >= details.length) return e;
        final newDetails = List<ExerciseSet>.from(details);
        final cur = details[setIndex];
        if (line != null) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty) {
            newDetails[setIndex] = ExerciseSet(
              line: trimmed,
              sets: '1',
              reps: '',
              rpe: '',
              note: note ?? cur.note,
            );
          } else {
            newDetails[setIndex] = cur.copyWith(note: note ?? cur.note);
          }
        } else if (sets != null || reps != null || rpe != null) {
          newDetails[setIndex] = ExerciseSet(
            line: '',
            sets: sets ?? cur.sets,
            reps: reps ?? cur.reps,
            rpe: rpe ?? cur.rpe,
            note: note ?? cur.note,
          );
        } else {
          newDetails[setIndex] = cur.copyWith(note: note ?? cur.note);
        }
        return e.copyWith(setDetails: newDetails);
      }).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _removeExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex,
  ) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) {
        if (e.id != exerciseId) return e;
        final details = e.effectiveSetDetails;
        if (details.length <= 1) return e;
        if (setIndex < 0 || setIndex >= details.length) return e;
        final newDetails = List<ExerciseSet>.from(details)..removeAt(setIndex);
        return e.copyWith(setDetails: newDetails);
      }).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _assignToSuperset(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    String supersetGroupId,
  ) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises
          .map(
            (e) => e.id == exerciseId
                ? e.copyWith(supersetGroupId: supersetGroupId)
                : e,
          )
          .toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _removeFromSuperset(int weekIndex, int dayIndex, String exerciseId) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises
          .map(
            (e) =>
                e.id == exerciseId ? e.copyWith(clearSupersetGroupId: true) : e,
          )
          .toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
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
    );
  }

  Widget _buildMobilityTab(ThemeData theme, ColorScheme cs) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.workoutBuilderMobilityRoutineTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: _addMobilityItem,
                icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                label: Text(
                  l10n.workoutBuilderAddShort,
                  style: TextStyle(
                    color: StitchM3Theme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _routine.mobilitySections.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _MobilitySectionChip(
                    label: _routine.mobilitySections[i].name,
                    selected:
                        _selectedMobilitySectionIndex.clamp(
                          0,
                          _routine.mobilitySections.length - 1,
                        ) ==
                        i,
                    onTap: () =>
                        setState(() => _selectedMobilitySectionIndex = i),
                    onEdit: () => _editMobilitySection(i),
                    onDelete: _routine.mobilitySections.length > 1
                        ? () => _deleteMobilitySection(i)
                        : null,
                  ),
                ],
                const SizedBox(width: 8),
                InkWell(
                  onTap: _addMobilitySection,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                        const SizedBox(width: 4),
                        Text(
                          l10n.workoutBuilderSectionHeading,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: StitchM3Theme.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) {
              var target = newIndex;
              if (target > oldIndex) target--;
              _reorderMobility(oldIndex, target);
            },
            itemCount: _mobilityItemsForSelectedSection.length,
            itemBuilder: (context, index) {
              final item = _mobilityItemsForSelectedSection[index];
              return Padding(
                key: ValueKey(item.id),
                padding: EdgeInsets.only(
                  bottom: index < _mobilityItemsForSelectedSection.length - 1
                      ? 8
                      : 0,
                ),
                child: _MobilityItem(
                  index: index,
                  title: item.title,
                  subtitle: item.subtitle,
                  shortTitle: item.shortTitle,
                  onEdit: (t, s, short) =>
                      _updateMobilityItem(item.id, t, s, shortTitle: short),
                  onDelete: () => _removeMobilityItem(item.id),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _DashedButton(
            icon: Icons.add,
            label: l10n.workoutBuilderAddExercise,
            onPressed: _selectedSectionId != null ? _addMobilityItem : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingTab(ThemeData theme, ColorScheme cs) {
    return _TrainingSection(
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
    _trackEditorChangesIfNeeded();

    return PopScope(
      canPop: !(widget.editorMode && _isDirty),
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
          saving: _saving,
          showManualSaveButton: _shouldShowManualSaveButton,
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
          saveStatusIndicator: widget.editorMode && !_loading
              ? _buildSaveStatusIndicator(l10n, cs)
              : null,
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
                        _buildTrainingTab(theme, cs),
                        if (_showsMobilityTab) _buildMobilityTab(theme, cs),
                        _buildDetailsTab(theme, cs),
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
}

class _MobilitySectionChip extends StatelessWidget {
  const _MobilitySectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: StitchM3Theme.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 60,
            color: selected ? StitchM3Theme.accent : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _MobilityItem extends StatelessWidget {
  const _MobilityItem({
    required this.index,
    required this.title,
    required this.subtitle,
    this.shortTitle = '',
    this.onEdit,
    this.onDelete,
  });

  final int index;
  final String title;
  final String subtitle;
  final String shortTitle;
  final void Function(String title, String subtitle, String shortTitle)? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20, color: cs.onSurfaceVariant),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'edit' && onEdit != null) {
                _showEditMobilityDialog(
                  context,
                  theme,
                  cs,
                  title,
                  subtitle,
                  shortTitle,
                  onEdit!,
                );
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (ctx) {
              final menuL10n = AppLocalizations.of(ctx);
              return [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(menuL10n.workoutBuilderEditExercise),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    menuL10n.workoutBuilderDeleteExercise,
                    style: const TextStyle(color: StitchM3Theme.danger),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

void _showRenameDayDialog(
  BuildContext context,
  String initialName,
  void Function(String) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderRenameDayTitle,
    bodyBuilder: (sheetContext) => TextField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.workoutBuilderDayNameLabel),
      autofocus: false,
      onSubmitted: (_) {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        onSave(name);
        Navigator.of(sheetContext).pop();
      },
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      onSave(name);
      Navigator.of(context).pop();
    },
  );
}

Future<String?> _showDuplicateWeekDialog(
  BuildContext context,
  String defaultName,
) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: defaultName);
  try {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.workoutBuilderDuplicateWeekTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.workoutBuilderDuplicateWeekHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(ctx).pop(trimmed);
            },
            child: Text(l10n.workoutBuilderDuplicateWeek),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}

void _showRenameWeekDialog(
  BuildContext context,
  String initialName,
  void Function(String) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderRenameWeekTitle,
    bodyBuilder: (sheetContext) => TextField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.workoutBuilderWeekNameLabel),
      autofocus: false,
      onSubmitted: (_) {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        onSave(name);
        Navigator.of(sheetContext).pop();
      },
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      onSave(name);
      Navigator.of(context).pop();
    },
  );
}

void _showEditMobilityDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialTitle,
  String initialSubtitle,
  String initialShortTitle,
  void Function(String title, String subtitle, String shortTitle) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final titleController = TextEditingController(text: initialTitle);
  final subtitleController = TextEditingController(text: initialSubtitle);
  final shortTitleController = TextEditingController(text: initialShortTitle);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditMobilityExerciseTitle,
    fullScreen: false,
    bodyBuilder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: l10n.mobilityTitle),
          autofocus: false,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: shortTitleController,
          decoration: InputDecoration(labelText: l10n.mobilityShortTitleLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: subtitleController,
          decoration: InputDecoration(labelText: l10n.mobilitySubtitle),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(
        titleController.text.trim(),
        subtitleController.text.trim(),
        shortTitleController.text.trim(),
      );
      Navigator.of(context).pop();
    },
  );
}

void _showEditExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialName,
  String initialSets,
  String initialReps,
  String initialRpe,
  String initialNote,
  void Function(String name, String sets, String reps, String rpe, String note)
  onSave, {
  String initialShortName = '',
  ExercisePrescriptionScope initialScope = ExercisePrescriptionScope.perWeek,
  List<ExerciseSet>? initialSetDetails,
  void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, {
    String shortName,
    ExercisePrescriptionScope prescriptionScope,
  })?
  onSaveWithSets,
}) {
  final nameController = TextEditingController(text: initialName);
  final noteController = TextEditingController(text: initialNote);
  final shortNameController = TextEditingController(text: initialShortName);
  var allWeeksScope = initialScope == ExercisePrescriptionScope.allWeeks;
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final rpeController = TextEditingController(text: initialRpe);
  final useMultiSet =
      onSaveWithSets != null &&
      initialSetDetails != null &&
      initialSetDetails.isNotEmpty;
  final setControllers = useMultiSet
      ? initialSetDetails.map((s) {
          String sets = s.sets.trim();
          String reps = s.reps.trim();
          String load = s.rpe.trim();
          if (sets.isEmpty && reps.isEmpty && s.line.trim().isNotEmpty) {
            final m = RegExp(r'^(\d+)x(\d+)\s*(.*)$').firstMatch(s.line.trim());
            if (m != null) {
              sets = m.group(1)!;
              reps = m.group(2)!;
              load = (m.group(3) ?? '').trim();
            } else {
              sets = s.line.trim();
            }
          }
          return SetEditControllers(
            TextEditingController(text: sets),
            TextEditingController(text: reps),
            TextEditingController(text: load),
            TextEditingController(text: s.note),
          );
        }).toList()
      : <SetEditControllers>[];

  final modalSaving = ValueNotifier<bool>(false);
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: initialName.trim().isEmpty
        ? l10n.workoutBuilderAddExerciseTitle
        : l10n.workoutBuilderEditExerciseTitle,
    fullScreen: useMultiSet,
    bodyBuilder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) {
        void addSetRow() {
          setState(() {
            setControllers.add(
              SetEditControllers(
                TextEditingController(),
                TextEditingController(),
                TextEditingController(),
                TextEditingController(),
              ),
            );
          });
        }

        void removeSetRow(int i) {
          if (setControllers.length <= 1) return;
          setState(() {
            setControllers.removeAt(i);
          });
        }

        final denseDecoration = InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.workoutBuilderNameLabel,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              autofocus: false,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: l10n.workoutBuilderNoteOptionalLabel,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: shortNameController,
              decoration: InputDecoration(
                labelText: l10n.workoutExerciseShortNameLabel,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.workoutExerciseScopeAllWeeks,
                style: theme.textTheme.bodyMedium,
              ),
              value: allWeeksScope,
              onChanged: (value) => setState(() => allWeeksScope = value),
            ),
            if (useMultiSet) ...[
              const SizedBox(height: 12),
              Text(
                l10n.workoutBuilderMultiSetBlockHeader,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              ...setControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: c.sets,
                          decoration: denseDecoration.copyWith(
                            labelText: l10n.workoutBuilderSetLabel,
                            hintText: '1',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: c.reps,
                          decoration: denseDecoration.copyWith(
                            labelText: l10n.workoutBuilderRepsLabel,
                            hintText: '3',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: c.load,
                          decoration: denseDecoration.copyWith(
                            labelText: l10n.workoutBuilderLoadLabel,
                            hintText: '75kg',
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: setControllers.length > 1
                              ? StitchM3Theme.danger
                              : cs.onSurfaceVariant,
                        ),
                        onPressed: setControllers.length > 1
                            ? () => removeSetRow(i)
                            : null,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: addSetRow,
                  icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                  label: Text(
                    l10n.workoutBuilderAddSet,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: StitchM3Theme.accent,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              TextField(
                controller: setsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderSetsLabel,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: repsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderRepsLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rpeController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderRpeOrLoadLabel,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.customerCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: modalSaving,
                    builder: (_, saving, __) => FilledButton(
                      onPressed: saving
                          ? null
                          : () {
                              modalSaving.value = true;
                              final name = nameController.text.trim();
                              final note = noteController.text.trim();
                              if (useMultiSet) {
                                final details = setControllers.map((c) {
                                  final sets = c.sets.text.trim();
                                  final reps = c.reps.text.trim();
                                  final load = c.load.text.trim();
                                  final noteSet = c.note.text.trim();
                                  if (sets.isNotEmpty ||
                                      reps.isNotEmpty ||
                                      load.isNotEmpty) {
                                    return ExerciseSet(
                                      sets: sets.isEmpty ? '1' : sets,
                                      reps: reps,
                                      rpe: load,
                                      note: noteSet,
                                    );
                                  }
                                  return ExerciseSet(note: noteSet);
                                }).toList();
                                onSaveWithSets(
                                  name,
                                  note,
                                  details,
                                  shortName: shortNameController.text.trim(),
                                  prescriptionScope: allWeeksScope
                                      ? ExercisePrescriptionScope.allWeeks
                                      : ExercisePrescriptionScope.perWeek,
                                );
                              } else {
                                onSave(
                                  name,
                                  setsController.text.trim(),
                                  repsController.text.trim(),
                                  rpeController.text.trim(),
                                  note,
                                );
                              }
                              Navigator.of(sheetContext).pop();
                            },
                      child: saving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.onPrimary,
                                ),
                              ),
                            )
                          : Text(l10n.customerSave),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        );
      },
    ),
  );
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: cs.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        ),
        foregroundColor: cs.onSurfaceVariant,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrainingSection extends StatelessWidget {
  const _TrainingSection({
    required this.theme,
    required this.cs,
    this.embeddedInTab = false,
    required this.weeks,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onRenameWeek,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onDeleteDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    required this.onAssignToSuperset,
    required this.onRemoveFromSuperset,
    required this.onAddExerciseToSuperset,
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onUpdateScheduledWeekday,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final bool embeddedInTab;
  final List<Week> weeks;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int, String) onRenameWeek;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int) onDeleteDay;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final void Function(int weekIndex, int dayIndex, int weekday)
  onUpdateScheduledWeekday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, embeddedInTab ? 8 : 24, 12, 8),
      child: TrainingWeekDayPanel(
        theme: theme,
        cs: cs,
        weeks: weeks,
        selectedWeekIndex: selectedWeekIndex,
        selectedDayIndex: selectedDayIndex,
        onSelectWeek: onSelectWeek,
        onSelectDay: onSelectDay,
        onNewWeek: onNewWeek,
        onCloneWeek: onCloneWeek,
        onDeleteWeek: onDeleteWeek,
        onEditWeek: (weekIndex) {
          final week = weeks[weekIndex];
          _showRenameWeekDialog(
            context,
            week.name,
            (name) => onRenameWeek(weekIndex, name),
          );
        },
        onAddDay: onAddDay,
        onEditDay: (weekIndex, dayIndex) {
          final day = weeks[weekIndex].days[dayIndex];
          _showRenameDayDialog(
            context,
            day.name,
            (name) => onRenameDay(weekIndex, dayIndex, name),
          );
        },
        onDeleteDay: onDeleteDay,
        onUpdateScheduledWeekday: onUpdateScheduledWeekday,
        onAddExercise: onAddExercise,
        exerciseListBuilder: (context, weekIndex, dayIndex, day) {
          final l10n = AppLocalizations.of(context);
          final partition = partitionExercisesBySuperset(day.exercises);
          return ListView(
            padding: const EdgeInsets.only(bottom: 96, right: 4),
            children: [
              for (final entry in partition.asMap().entries) ...[
                if (entry.value is Exercise)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildExerciseCard(
                      context,
                      weekIndex: weekIndex,
                      dayIndex: dayIndex,
                      day: day,
                      exercise: entry.value as Exercise,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SuperSetBlock(
                      theme: theme,
                      cs: cs,
                      weekIndex: weekIndex,
                      dayIndex: dayIndex,
                      exercises: entry.value as List<Exercise>,
                      supersetGroupId:
                          (entry.value as List<Exercise>).isNotEmpty &&
                              (entry.value as List<Exercise>)
                                      .first
                                      .supersetGroupId !=
                                  null
                          ? (entry.value as List<Exercise>)
                                .first
                                .supersetGroupId!
                          : null,
                      onAddExercise: () => onAddExercise(weekIndex, dayIndex),
                      onAddExerciseToSuperset: onAddExerciseToSuperset,
                      onRemoveExercise: onRemoveExercise,
                      onMoveExercise: onMoveExercise,
                      onUpdateExercise: onUpdateExercise,
                      onAddSetToExercise: onAddSetToExercise,
                      onUpdateExerciseSet: onUpdateExerciseSet,
                      onRemoveExerciseSet: onRemoveExerciseSet,
                      onAssignToSuperset: onAssignToSuperset,
                      onRemoveFromSuperset: onRemoveFromSuperset,
                      supersetOptionsForDay: _getSupersetGroupOptions(day),
                    ),
                  ),
              ],
              if (day.exercises.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.workoutBuilderExerciseCount(0),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required int weekIndex,
    required int dayIndex,
    required Day day,
    required Exercise exercise,
  }) {
    final ex = exercise;
    return _ExerciseCard(
      theme: theme,
      cs: cs,
      exercise: ex,
      compact: true,
      onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
      onMoveUp: () => onMoveExercise(weekIndex, dayIndex, ex.id, up: true),
      onMoveDown: () => onMoveExercise(weekIndex, dayIndex, ex.id, up: false),
      onEdit:
          (
            name,
            sets,
            reps,
            rpe,
            note, {
            setDetails,
            shortName,
            prescriptionScope,
          }) => onUpdateExercise(
            weekIndex,
            dayIndex,
            ex.id,
            name: name,
            sets: sets,
            reps: reps,
            rpe: rpe,
            note: note,
            setDetails: setDetails,
            shortName: shortName,
            prescriptionScope: prescriptionScope,
          ),
      onAddSet: () => onAddSetToExercise(weekIndex, dayIndex, ex.id),
      onUpdateSet: (setIndex, sets, reps, load, note) => onUpdateExerciseSet(
        weekIndex,
        dayIndex,
        ex.id,
        setIndex,
        sets: sets,
        reps: reps,
        rpe: load,
        note: note,
      ),
      onRemoveSet: (setIndex) =>
          onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex),
      supersetOptions: _getSupersetGroupOptions(
        day,
      ).where((o) => o.id != ex.supersetGroupId).toList(),
      onAssignToSuperset: (groupId) =>
          onAssignToSuperset(weekIndex, dayIndex, ex.id, groupId),
      onRemoveFromSuperset: ex.supersetGroupId != null
          ? () => onRemoveFromSuperset(weekIndex, dayIndex, ex.id)
          : null,
    );
  }
}

class _SuperSetBlock extends StatelessWidget {
  const _SuperSetBlock({
    required this.theme,
    required this.cs,
    required this.weekIndex,
    required this.dayIndex,
    required this.exercises,
    this.supersetGroupId,
    required this.onAddExercise,
    this.onAddExerciseToSuperset,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    this.onAssignToSuperset,
    this.onRemoveFromSuperset,
    this.supersetOptionsForDay = const [],
  });

  final ThemeData theme;
  final ColorScheme cs;
  final int weekIndex;
  final int dayIndex;
  final List<Exercise> exercises;
  final String? supersetGroupId;
  final VoidCallback onAddExercise;
  final void Function(int, int, String)? onAddExerciseToSuperset;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String)? onAssignToSuperset;
  final void Function(int, int, String)? onRemoveFromSuperset;
  final List<({String id, String label})> supersetOptionsForDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border(left: BorderSide(color: StitchM3Theme.accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 18, color: StitchM3Theme.accent),
              const SizedBox(width: 8),
              Text(
                l10n.workoutBuilderSuperSetHeading,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...exercises.map(
            (ex) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseCard(
                theme: theme,
                cs: cs,
                exercise: ex,
                compact: false,
                linked: true,
                onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
                onMoveUp: () =>
                    onMoveExercise(weekIndex, dayIndex, ex.id, up: true),
                onMoveDown: () =>
                    onMoveExercise(weekIndex, dayIndex, ex.id, up: false),
                onEdit:
                    (
                      name,
                      sets,
                      reps,
                      rpe,
                      note, {
                      setDetails,
                      shortName,
                      prescriptionScope,
                    }) => onUpdateExercise(
                      weekIndex,
                      dayIndex,
                      ex.id,
                      name: name,
                      sets: sets,
                      reps: reps,
                      rpe: rpe,
                      note: note,
                      setDetails: setDetails,
                      shortName: shortName,
                      prescriptionScope: prescriptionScope,
                    ),
                onAddSet: () => onAddSetToExercise(weekIndex, dayIndex, ex.id),
                onUpdateSet: (setIndex, sets, reps, load, note) =>
                    onUpdateExerciseSet(
                      weekIndex,
                      dayIndex,
                      ex.id,
                      setIndex,
                      sets: sets,
                      reps: reps,
                      rpe: load,
                      note: note,
                    ),
                onRemoveSet: (setIndex) =>
                    onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex),
                supersetOptions: supersetOptionsForDay
                    .where((o) => o.id != ex.supersetGroupId)
                    .toList(),
                onAssignToSuperset: onAssignToSuperset != null
                    ? (groupId) => onAssignToSuperset!(
                        weekIndex,
                        dayIndex,
                        ex.id,
                        groupId,
                      )
                    : null,
                onRemoveFromSuperset: onRemoveFromSuperset != null
                    ? () => onRemoveFromSuperset!(weekIndex, dayIndex, ex.id)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DashedButton(
            icon: Icons.add,
            label: l10n.workoutBuilderAddExercise,
            onPressed:
                supersetGroupId != null && onAddExerciseToSuperset != null
                ? () => onAddExerciseToSuperset!(
                    weekIndex,
                    dayIndex,
                    supersetGroupId!,
                  )
                : onAddExercise,
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.theme,
    required this.cs,
    required this.exercise,
    required this.compact,
    this.linked = false,
    this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.onEdit,
    this.onAddSet,
    this.onUpdateSet,
    this.onRemoveSet,
    this.supersetOptions = const [],
    this.onAssignToSuperset,
    this.onRemoveFromSuperset,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final Exercise exercise;
  final bool compact;
  final bool linked;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final void Function(
    String name,
    String sets,
    String reps,
    String rpe,
    String note, {
    List<ExerciseSet>? setDetails,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
  })?
  onEdit;
  final VoidCallback? onAddSet;
  final void Function(
    int setIndex,
    String sets,
    String reps,
    String load,
    String note,
  )?
  onUpdateSet;
  final void Function(int setIndex)? onRemoveSet;
  final List<({String id, String label})> supersetOptions;
  final void Function(String groupId)? onAssignToSuperset;
  final VoidCallback? onRemoveFromSuperset;

  void _openEditDialog(BuildContext context) {
    if (onEdit == null) return;
    _showEditExerciseDialog(
      context,
      theme,
      cs,
      exercise.name,
      exercise.sets,
      exercise.reps,
      exercise.rpe,
      exercise.note,
      (name, sets, reps, rpe, note) => onEdit!(name, sets, reps, rpe, note),
      initialShortName: exercise.shortName,
      initialScope: exercise.prescriptionScope,
      initialSetDetails: exercise.effectiveSetDetails,
      onSaveWithSets:
          (
            name,
            note,
            setDetails, {
            shortName = '',
            prescriptionScope = ExercisePrescriptionScope.perWeek,
          }) => onEdit!(
            name,
            exercise.sets,
            exercise.reps,
            exercise.rpe,
            note,
            setDetails: setDetails,
            shortName: shortName,
            prescriptionScope: prescriptionScope,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = exercise.effectiveSetDetails;
    final hasMultipleSets = details.length > 1;
    final l10n = AppLocalizations.of(context);
    final setsSummary = hasMultipleSets
        ? details.map((s) => s.displayText).join(' · ')
        : details.first.displayText;
    final hasMenu =
        onEdit != null ||
        onRemove != null ||
        onMoveUp != null ||
        onMoveDown != null ||
        onAssignToSuperset != null ||
        onRemoveFromSuperset != null;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onEdit != null ? () => _openEditDialog(context) : null,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            if (linked)
                              Icon(
                                Icons.link,
                                size: 16,
                                color: StitchM3Theme.accent,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          setsSummary,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasMenu)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: l10n.workoutBuilderExerciseMenuTooltip,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditDialog(context);
                        } else if (value == 'up') {
                          onMoveUp?.call();
                        } else if (value == 'down') {
                          onMoveDown?.call();
                        } else if (value == 'delete') {
                          onRemove?.call();
                        } else if (value == 'new') {
                          onAssignToSuperset!(
                            'ss_${DateTime.now().millisecondsSinceEpoch}',
                          );
                        } else if (value.startsWith('group:')) {
                          onAssignToSuperset!(value.substring(6));
                        } else if (value == 'remove_ss') {
                          onRemoveFromSuperset?.call();
                        }
                      },
                      itemBuilder: (ctx) {
                        final menuL10n = AppLocalizations.of(ctx);
                        return [
                          if (onEdit != null)
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(menuL10n.workoutBuilderEditExercise),
                            ),
                          if (onMoveUp != null)
                            PopupMenuItem(
                              value: 'up',
                              child: Text(menuL10n.workoutBuilderMoveUp),
                            ),
                          if (onMoveDown != null)
                            PopupMenuItem(
                              value: 'down',
                              child: Text(menuL10n.workoutBuilderMoveDown),
                            ),
                          if (onAssignToSuperset != null)
                            PopupMenuItem(
                              value: 'new',
                              child: Text(menuL10n.workoutBuilderNewSuperset),
                            ),
                          ...supersetOptions.map(
                            (o) => PopupMenuItem(
                              value: 'group:${o.id}',
                              child: Text(
                                o.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (onRemoveFromSuperset != null)
                            PopupMenuItem(
                              value: 'remove_ss',
                              child: Text(
                                menuL10n.workoutBuilderRemoveFromSuperset,
                                style: const TextStyle(
                                  color: StitchM3Theme.danger,
                                ),
                              ),
                            ),
                          if (onRemove != null)
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                menuL10n.workoutBuilderDeleteExercise,
                                style: const TextStyle(
                                  color: StitchM3Theme.danger,
                                ),
                              ),
                            ),
                        ];
                      },
                    ),
                ],
              ),
              if (!compact && hasMultipleSets)
                ...details.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      top: i == 0 ? 8 : 4,
                      bottom: i < details.length - 1 ? 4 : 0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SetRepCell(
                            theme: theme,
                            cs: cs,
                            label: l10n.workoutBuilderSetsLabel,
                            value: s.displayText,
                            compact: compact,
                          ),
                        ),
                        if (onUpdateSet != null)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _showEditSetDialog(
                              context,
                              theme,
                              cs,
                              s.sets,
                              s.reps,
                              s.rpe,
                              s.note,
                              (sets, reps, load, note) =>
                                  onUpdateSet!(i, sets, reps, load, note),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              if (!compact && onAddSet != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onAddSet,
                    icon: Icon(
                      Icons.add,
                      size: 16,
                      color: StitchM3Theme.accent,
                    ),
                    label: Text(l10n.workoutBuilderAddSet),
                  ),
                ),
              ],
              if (exercise.note.isNotEmpty ||
                  (!compact && exercise.note.isEmpty)) ...[
                const SizedBox(height: 4),
                Text(
                  exercise.note.isNotEmpty
                      ? exercise.note
                      : l10n.workoutBuilderNotePlaceholder,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: exercise.note.isNotEmpty
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                    fontStyle: exercise.note.isEmpty ? FontStyle.italic : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void _showEditSetDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialSets,
  String initialReps,
  String initialLoad,
  String initialNote,
  void Function(String sets, String reps, String load, String note) onSave,
) {
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final loadController = TextEditingController(text: initialLoad);
  final noteController = TextEditingController(text: initialNote);
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditSetTitle,
    bodyBuilder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: setsController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderSetLabel,
                  hintText: '1',
                ),
                keyboardType: TextInputType.number,
                autofocus: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: repsController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderRepsLabel,
                  hintText: '3',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: loadController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderLoadLabel,
                  hintText: '75kg',
                ),
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          decoration: InputDecoration(labelText: l10n.workoutBuilderNoteLabel),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(
        setsController.text.trim(),
        repsController.text.trim(),
        loadController.text.trim(),
        noteController.text.trim(),
      );
      Navigator.of(context).pop();
    },
  );
}

class _SetRepCell extends StatelessWidget {
  const _SetRepCell({
    required this.theme,
    required this.cs,
    required this.label,
    required this.value,
    required this.compact,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(compact ? 8 : 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
            border: Border.all(color: cs.outline),
          ),
          child: Center(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
