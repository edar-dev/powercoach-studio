import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/haptics.dart';
import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../core/ui/widgets/truncated_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import 'workout_session_card_chrome.dart';

/// True when [name] is empty or a legacy auto-numbered default
/// (`Section 1`, `Sezione 2`, …).
bool isUnsetMobilitySectionName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return true;
  return RegExp(
    r'^(section|sezione)\s+\d+$',
    caseSensitive: false,
  ).hasMatch(trimmed);
}

/// Localized chip/label for a mobility section; keeps persisted name unchanged.
String mobilitySectionDisplayName({
  required String name,
  required int index,
  required AppLocalizations l10n,
}) {
  if (isUnsetMobilitySectionName(name)) {
    return l10n.workoutBuilderSectionNumbered(index + 1);
  }
  return name.trim();
}

/// Full day-card style mobility section preview (tap opens section editor).
class MobilitySectionCard extends StatelessWidget {
  const MobilitySectionCard({
    super.key,
    required this.label,
    required this.items,
    required this.onOpen,
    required this.onEdit,
    this.onDelete,
    this.scheduleHint = '',
  });

  final String label;
  final List<MobilityItem> items;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final String scheduleHint;

  static const int previewItemLimit = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final preview = items.take(previewItemLimit).toList(growable: false);
    final remaining = items.length - preview.length;
    final hint = scheduleHint.trim();

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.65),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hint.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            hint,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: l10n.workoutBuilderEditSectionTitle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(l10n.workoutBuilderEditSectionTitle),
                      ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            l10n.workoutBuilderDeleteSection,
                            style: const TextStyle(color: StitchM3Theme.danger),
                          ),
                        ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Text(
                  l10n.workoutPhaseNoExercisesYet,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                )
              else ...[
                for (var i = 0; i < preview.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _MobilityItemPreviewRow(
                    item: preview[i],
                    theme: theme,
                    cs: cs,
                  ),
                ],
                if (remaining > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.workoutPhaseMoreExercises(remaining),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.workoutBuilderExerciseCount(items.length),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onOpen,
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.workoutPhaseEditSession,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right, size: 16, color: cs.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobilityItemPreviewRow extends StatelessWidget {
  const _MobilityItemPreviewRow({
    required this.item,
    required this.theme,
    required this.cs,
  });

  final MobilityItem item;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final summary = item.subtitle.trim().isNotEmpty
        ? item.subtitle
        : (item.shortTitle.trim().isNotEmpty ? item.shortTitle : null);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.self_improvement_outlined,
            size: 14,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (summary != null)
                Text(
                  summary,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dashed full-width CTA to add a mobility section (day-add pattern).
class MobilityAddSectionCard extends StatelessWidget {
  const MobilityAddSectionCard({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: cs.outlineVariant,
            radius: 14,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainerHighest,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Icon(Icons.add, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Session-chrome mobility item card with controlled expand-in-place editing.
class MobilityItemCard extends StatefulWidget {
  const MobilityItemCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onExpandedChanged,
    this.shortTitle = '',
    this.onUpdate,
    this.onDelete,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final int index;
  final String title;
  final String subtitle;
  final String shortTitle;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final void Function(String title, String subtitle, String shortTitle)?
      onUpdate;
  final VoidCallback? onDelete;

  @override
  State<MobilityItemCard> createState() => _MobilityItemCardState();
}

class _MobilityItemCardState extends State<MobilityItemCard> {
  late final TextEditingController _titleController;
  late final TextEditingController _shortTitleController;
  late final TextEditingController _subtitleController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _shortTitleController = TextEditingController(text: widget.shortTitle);
    _subtitleController = TextEditingController(text: widget.subtitle);
  }

  @override
  void didUpdateWidget(covariant MobilityItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title &&
        widget.title != _titleController.text) {
      _titleController.text = widget.title;
    }
    if (oldWidget.shortTitle != widget.shortTitle &&
        widget.shortTitle != _shortTitleController.text) {
      _shortTitleController.text = widget.shortTitle;
    }
    if (oldWidget.subtitle != widget.subtitle &&
        widget.subtitle != _subtitleController.text) {
      _subtitleController.text = widget.subtitle;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _shortTitleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _flushSave);
  }

  void _flushSave() {
    final onUpdate = widget.onUpdate;
    if (onUpdate == null) return;
    onUpdate(
      _titleController.text.trim(),
      _subtitleController.text.trim(),
      _shortTitleController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.colorScheme;
    final l10n = AppLocalizations.of(context);
    final summary = widget.subtitle.trim().isNotEmpty
        ? widget.subtitle
        : (widget.shortTitle.trim().isNotEmpty ? widget.shortTitle : null);
    final hasMenu = widget.onDelete != null;

    return WorkoutSessionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: WorkoutSessionCardChrome.headerPadding,
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(width: 8),
                WorkoutSessionIndexBadge(
                  index: widget.index + 1,
                  theme: theme,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      AppHaptics.selection();
                      widget.onExpandedChanged(!widget.expanded);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TruncatedText(
                              widget.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              tooltip: widget.title,
                            ),
                            if (!widget.expanded && summary != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  summary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: widget.expanded
                      ? MaterialLocalizations.of(context).expandedIconTapHint
                      : MaterialLocalizations.of(context).collapsedIconTapHint,
                  icon: Icon(
                    widget.expanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () {
                    AppHaptics.selection();
                    widget.onExpandedChanged(!widget.expanded);
                  },
                ),
                if (hasMenu)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 22,
                      color: cs.onSurfaceVariant,
                    ),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        widget.onDelete?.call();
                      }
                    },
                    itemBuilder: (ctx) {
                      final menuL10n = AppLocalizations.of(ctx);
                      return [
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
          ),
          if (widget.expanded) ...[
            const Divider(height: 1, color: WorkoutSessionCardChrome.divider),
            Padding(
              padding: WorkoutSessionCardChrome.expandedPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.onUpdate != null) ...[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.mobilityTitle,
                        filled: true,
                        fillColor: WorkoutSessionCardChrome.inputBg,
                      ),
                      onChanged: (_) => _scheduleSave(),
                      onEditingComplete: _flushSave,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _shortTitleController,
                      decoration: InputDecoration(
                        labelText: l10n.mobilityShortTitleLabel,
                        filled: true,
                        fillColor: WorkoutSessionCardChrome.inputBg,
                      ),
                      onChanged: (_) => _scheduleSave(),
                      onEditingComplete: _flushSave,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _subtitleController,
                      decoration: InputDecoration(
                        labelText: l10n.mobilitySubtitle,
                        filled: true,
                        fillColor: WorkoutSessionCardChrome.inputBg,
                      ),
                      maxLines: 2,
                      onChanged: (_) => _scheduleSave(),
                      onEditingComplete: _flushSave,
                    ),
                  ] else ...[
                    if (widget.shortTitle.trim().isNotEmpty)
                      Text(
                        widget.shortTitle,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (widget.subtitle.trim().isNotEmpty) ...[
                      if (widget.shortTitle.trim().isNotEmpty)
                        const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                    if (widget.subtitle.trim().isEmpty &&
                        widget.shortTitle.trim().isEmpty)
                      Text(
                        l10n.workoutBuilderNotePlaceholder,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Legacy bottom-sheet editor — kept for callers outside the primary expand path.
@Deprecated('Prefer expand-in-place editing via MobilityItemCard.onUpdate')
void showEditMobilityItemDialog(
  BuildContext context,
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

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 6.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
