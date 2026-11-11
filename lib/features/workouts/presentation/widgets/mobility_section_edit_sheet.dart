import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/haptics.dart';
import '../../../../core/ui/widgets/keyboard_dismiss.dart';
import '../../../../core/ui/widgets/truncated_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/maximal_ref.dart';
import '../../domain/mobility_session_presentation.dart';
import '../mobility_builder_controller.dart';
import 'exercise_library_pick_panel.dart';
import 'workout_day_exercise_list.dart';

/// Stitch dark tokens shared with the training session edit modal.
abstract final class _MobilitySectionEditColors {
  static const Color backdrop = Color(0xFF090D16);
  static const Color card = Color(0xFF111827);
  static const Color border = Color(0xFF28354D);
  static const Color header = Color(0xE6111827);
  static const Color footer = Color(0xFF0F1624);
}

/// Opens a fullscreen mobility section editor (mirrors training session edit).
///
/// Tracks the section by stable [MobilitySection.id] so deletes while open
/// auto-dismiss. Selects the section on the controller before mutations so
/// reorder/add target the correct section.
Future<void> showMobilitySectionEditSheet({
  required BuildContext context,
  required ThemeData theme,
  required ColorScheme cs,
  required MobilityBuilderController mobilityController,
  required String sectionId,
  required void Function(int sectionIndex) onRenameSection,
  required void Function(int sectionIndex) onDeleteSection,
  required void Function(MobilityItem item) onUpdateItem,
  required void Function(String itemId) onAddSetToItem,
  required void Function(
    String itemId,
    int setIndex, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) onUpdateItemSet,
  required void Function(String itemId, int setIndex) onRemoveSetFromItem,
  required void Function(String itemId) onDeleteItem,
  required void Function(int oldIndex, int newIndex) onReorderItems,
  String? customerId,
  bool readOnly = false,
}) {
  final l10n = AppLocalizations.of(context);
  final initial = _locateSectionById(mobilityController.sections, sectionId);
  if (initial == null) return Future.value();

  // Ensure CRUD targets this section while the editor is open.
  mobilityController.selectSection(initial.index);

  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (routeContext) {
        return ListenableBuilder(
          listenable: mobilityController,
          builder: (context, _) {
            final located =
                _locateSectionById(mobilityController.sections, sectionId);
            if (located == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (routeContext.mounted) {
                  Navigator.of(routeContext).maybePop();
                }
              });
              return Scaffold(
                backgroundColor: _MobilitySectionEditColors.backdrop,
                body: Center(
                  child: Text(
                    l10n.workoutBuilderMobilityEmptyTitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }
            final items = mobilityController.routine.mobilityItems
                .where((e) => e.sectionId == sectionId)
                .toList(growable: false);
            return MobilitySectionEditBody(
              theme: theme,
              cs: cs,
              section: located.section,
              sectionIndex: located.index,
              itemCount: items.length,
              canDelete: mobilityController.sections.length > 1,
              items: items,
              customerId: customerId,
              readOnly: readOnly,
              onRename: () => onRenameSection(located.index),
              onDelete: () {
                Navigator.of(routeContext).maybePop();
                onDeleteSection(located.index);
              },
              onUpdateItem: onUpdateItem,
              onAddSetToItem: onAddSetToItem,
              onUpdateItemSet: onUpdateItemSet,
              onRemoveSetFromItem: onRemoveSetFromItem,
              onDeleteItem: onDeleteItem,
              onReorderItems: onReorderItems,
              onAddFromLibrary: readOnly
                  ? null
                  : () => _openLibraryPicker(
                        context: context,
                        theme: theme,
                        cs: cs,
                        mobilityController: mobilityController,
                        sectionId: sectionId,
                        l10n: l10n,
                      ),
              onClose: () => Navigator.of(routeContext).maybePop(),
            );
          },
        );
      },
    ),
  );
}

({int index, MobilitySection section})? _locateSectionById(
  List<MobilitySection> sections,
  String sectionId,
) {
  for (var i = 0; i < sections.length; i++) {
    if (sections[i].id == sectionId) {
      return (index: i, section: sections[i]);
    }
  }
  return null;
}

void _openLibraryPicker({
  required BuildContext context,
  required ThemeData theme,
  required ColorScheme cs,
  required MobilityBuilderController mobilityController,
  required String sectionId,
  required AppLocalizations l10n,
}) {
  showExerciseLibraryPickPanel(
    context: context,
    theme: theme,
    cs: cs,
    onPicked: (item, displayName) {
      final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
      mobilityController.addItem(
        MobilityItem(
          id: id,
          title: displayName.trim().isEmpty
              ? l10n.workoutBuilderNewExerciseDefault
              : displayName.trim(),
          subtitle: '',
          sectionId: sectionId,
          customExerciseId: item.id,
        ),
      );
    },
  );
}

class MobilitySectionEditBody extends StatelessWidget {
  const MobilitySectionEditBody({
    super.key,
    required this.theme,
    required this.cs,
    required this.section,
    required this.sectionIndex,
    required this.itemCount,
    required this.canDelete,
    required this.items,
    required this.onRename,
    required this.onDelete,
    required this.onUpdateItem,
    required this.onAddSetToItem,
    required this.onUpdateItemSet,
    required this.onRemoveSetFromItem,
    required this.onDeleteItem,
    required this.onReorderItems,
    this.onAddFromLibrary,
    this.customerId,
    this.readOnly = false,
    this.onClose,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final MobilitySection section;
  final int sectionIndex;
  final int itemCount;
  final bool canDelete;
  final List<MobilityItem> items;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final void Function(MobilityItem item) onUpdateItem;
  final void Function(String itemId) onAddSetToItem;
  final void Function(
    String itemId,
    int setIndex, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) onUpdateItemSet;
  final void Function(String itemId, int setIndex) onRemoveSetFromItem;
  final void Function(String itemId) onDeleteItem;
  final void Function(int oldIndex, int newIndex) onReorderItems;
  final VoidCallback? onAddFromLibrary;
  final String? customerId;
  final bool readOnly;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final maxWidth = isDesktop
        ? AppBreakpoints.sessionSheetMaxWidth
        : double.infinity;
    final displayName = mobilitySectionDisplayName(
      name: section.name,
      index: sectionIndex,
      l10n: l10n,
    );
    final scheduleHint = section.scheduleHint.trim();
    final pinBottomCtas = !isDesktop && !readOnly;
    final close = onClose ?? () => Navigator.of(context).maybePop();
    final presentationDay = MobilitySectionSessionView(
      section: section,
      sectionIndex: sectionIndex,
      items: items,
    ).toPresentationDay(l10n);
    final itemById = {for (final item in items) item.id: item};

    void noopDup(int _, int _, Exercise _) {}
    void noopMoveWithin(int _, int _, String _, {required bool up}) {}
    void noopAssign(int _, int _, String _, String _) {}
    void noopRemoveSs(int _, int _, String _) {}
    void noopAddToSs(int _, int _, String _) {}

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        KeyboardDismiss.unfocus();
      },
      child: ColoredBox(
        color: _MobilitySectionEditColors.backdrop,
        child: SafeArea(
          bottom: !pinBottomCtas,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 0,
                  vertical: isDesktop ? 16 : 0,
                ),
                child: Material(
                  color: _MobilitySectionEditColors.card,
                  elevation: isDesktop ? 8 : 0,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 0),
                    side: isDesktop
                        ? const BorderSide(
                            color: _MobilitySectionEditColors.border,
                          )
                        : BorderSide.none,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MobilitySectionEditHeader(
                        theme: theme,
                        cs: cs,
                        l10n: l10n,
                        sectionName: displayName,
                        itemCountLabel:
                            l10n.workoutBuilderExerciseCount(itemCount),
                        scheduleHint: scheduleHint,
                        readOnly: readOnly,
                        showPrimaryActions: isDesktop,
                        onClose: close,
                        onRename: readOnly ? null : onRename,
                        onDelete: readOnly || !canDelete ? null : onDelete,
                        onCancel: close,
                        onSave: close,
                      ),
                      Expanded(
                        child: WorkoutDayExerciseList(
                          theme: theme,
                          colorScheme: cs,
                          weekIndex: 0,
                          dayIndex: 0,
                          day: presentationDay,
                          variant: SessionListVariant.mobility,
                          sessionEditStyle: true,
                          pinBottomCtas: pinBottomCtas,
                          customerId: customerId,
                          readOnly: readOnly,
                          onAddExercise: onAddFromLibrary == null
                              ? null
                              : (_, _) => onAddFromLibrary!(),
                          onDuplicateExercise: noopDup,
                          onRemoveExercise: (_, _, id) => onDeleteItem(id),
                          onMoveExercise: (_, _, id, {required up}) {
                            final idx =
                                items.indexWhere((e) => e.id == id);
                            if (idx < 0) return;
                            final target = up ? idx - 1 : idx + 1;
                            if (target < 0 || target >= items.length) {
                              return;
                            }
                            onReorderItems(idx, target);
                          },
                          onMoveExerciseWithinSuperset: noopMoveWithin,
                          onUpdateExercise: (
                            _,
                            _,
                            id, {
                            String? name,
                            String? sets,
                            String? reps,
                            String? rpe,
                            String? note,
                            String? shortName,
                            ExercisePrescriptionScope? prescriptionScope,
                            List<ExerciseSet>? setDetails,
                            MaximalRef? maximalRef,
                            bool clearMaximalRef = false,
                          }) {
                            final original = itemById[id];
                            if (original == null) return;
                            final presentation =
                                mobilityItemToPresentationExercise(original)
                                    .copyWith(
                              name: name ?? original.title,
                              sets: sets ?? original.sets,
                              reps: reps ?? original.reps,
                              rpe: rpe ?? original.rpe,
                              note: note ?? original.subtitle,
                              shortName: shortName ?? original.shortTitle,
                              prescriptionScope:
                                  prescriptionScope ?? original.prescriptionScope,
                              setDetails: setDetails ?? original.setDetails,
                              maximalRef: maximalRef,
                              clearMaximalRef: clearMaximalRef,
                            );
                            onUpdateItem(
                              applyPresentationExerciseToItem(
                                presentation,
                                original,
                                clearMaximalRef: clearMaximalRef,
                              ),
                            );
                          },
                          onAddSetToExercise: (_, _, id) => onAddSetToItem(id),
                          onUpdateExerciseSet: (
                            _,
                            _,
                            id,
                            setIndex, {
                            String? line,
                            String? sets,
                            String? reps,
                            String? rpe,
                            String? note,
                          }) {
                            onUpdateItemSet(
                              id,
                              setIndex,
                              line: line,
                              sets: sets,
                              reps: reps,
                              rpe: rpe,
                              note: note,
                            );
                          },
                          onRemoveExerciseSet: (_, _, id, setIndex) =>
                              onRemoveSetFromItem(id, setIndex),
                          onAssignToSuperset: noopAssign,
                          onRemoveFromSuperset: noopRemoveSs,
                          onAddExerciseToSuperset: noopAddToSs,
                        ),
                      ),
                      _MobilitySectionEditFooter(
                        theme: theme,
                        l10n: l10n,
                        stickyPhoneActions: pinBottomCtas,
                        hasItems: items.isNotEmpty,
                        onSave: close,
                        onAddFromLibrary: onAddFromLibrary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobilitySectionEditHeader extends StatelessWidget {
  const _MobilitySectionEditHeader({
    required this.theme,
    required this.cs,
    required this.l10n,
    required this.sectionName,
    required this.itemCountLabel,
    required this.scheduleHint,
    required this.readOnly,
    this.showPrimaryActions = true,
    required this.onClose,
    this.onRename,
    this.onDelete,
    required this.onCancel,
    required this.onSave,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final String sectionName;
  final String itemCountLabel;
  final String scheduleHint;
  final bool readOnly;
  final bool showPrimaryActions;
  final VoidCallback onClose;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final title = l10n.workoutBuilderEditSectionTitle;
    return Material(
      color: _MobilitySectionEditColors.header,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _MobilitySectionEditColors.border),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 22),
            ),
            const SizedBox(width: 4),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: StitchM3Theme.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: StitchM3Theme.accent.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.self_improvement_outlined,
                size: 20,
                color: StitchM3Theme.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TruncatedText(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          tooltip: title,
                        ),
                      ),
                      if (onRename != null)
                        IconButton(
                          tooltip: l10n.workoutBuilderEditSectionTitle,
                          onPressed: onRename,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sectionName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itemCountLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (scheduleHint.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      scheduleHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (onDelete != null)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _MobilitySectionEditColors.border,
                        ),
                      ),
                      child: IconButton(
                        tooltip: l10n.workoutBuilderDeleteSection,
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: cs.error,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  if (!readOnly && showPrimaryActions) ...[
                    TextButton(
                      onPressed: onCancel,
                      child: Text(l10n.workoutEditorCancel),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        AppHaptics.light();
                        onSave();
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n.workoutSessionSaveChanges),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobilitySectionEditFooter extends StatelessWidget {
  const _MobilitySectionEditFooter({
    required this.theme,
    required this.l10n,
    this.stickyPhoneActions = false,
    this.hasItems = false,
    required this.onSave,
    this.onAddFromLibrary,
  });

  final ThemeData theme;
  final AppLocalizations l10n;
  final bool stickyPhoneActions;
  final bool hasItems;
  final VoidCallback onSave;
  final VoidCallback? onAddFromLibrary;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = stickyPhoneActions
        ? MediaQuery.paddingOf(context).bottom
        : 0.0;
    final bottomInset = keyboardInset + safeBottom;
    final showStickyCtas =
        stickyPhoneActions && hasItems && onAddFromLibrary != null;
    final saveLabel = l10n.workoutSessionSaveChanges;

    return Material(
      color: _MobilitySectionEditColors.footer,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: _MobilitySectionEditColors.border),
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stickyPhoneActions) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    AppHaptics.light();
                    onSave();
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(saveLabel),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
              if (showStickyCtas) ...[
                const SizedBox(height: 10),
                SessionDayBottomCtas(
                  l10n: l10n,
                  onAddFromLibrary: onAddFromLibrary,
                ),
              ],
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.workoutSessionAutosaveActive,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
