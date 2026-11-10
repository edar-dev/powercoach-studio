import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/haptics.dart';
import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../core/ui/widgets/truncated_text.dart';
import '../../../../l10n/app_localizations.dart';
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

/// Compact day-card style section selector (surface + primary border when selected).
class MobilitySectionCard extends StatelessWidget {
  const MobilitySectionCard({
    super.key,
    required this.label,
    required this.itemCount,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
  });

  final String label;
  final int itemCount;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minWidth: 132),
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.75)
                  : cs.outlineVariant.withValues(alpha: 0.65),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.9),
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.workoutBuilderExerciseCount(itemCount),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.workoutBuilderEditSectionTitle,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
        ),
      ),
    );
  }
}

/// Dashed compact card CTA to add a mobility section (day-add pattern).
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 112, minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Session-chrome expandable mobility item card.
class MobilityItemCard extends StatefulWidget {
  const MobilityItemCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.index,
    required this.title,
    required this.subtitle,
    this.shortTitle = '',
    this.onEdit,
    this.onDelete,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final int index;
  final String title;
  final String subtitle;
  final String shortTitle;
  final void Function(String title, String subtitle, String shortTitle)? onEdit;
  final VoidCallback? onDelete;

  @override
  State<MobilityItemCard> createState() => _MobilityItemCardState();
}

class _MobilityItemCardState extends State<MobilityItemCard> {
  bool _expanded = false;

  void _setExpanded(bool value) {
    if (_expanded == value) return;
    AppHaptics.selection();
    setState(() => _expanded = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.colorScheme;
    final l10n = AppLocalizations.of(context);
    final summary = widget.subtitle.trim().isNotEmpty
        ? widget.subtitle
        : (widget.shortTitle.trim().isNotEmpty ? widget.shortTitle : null);
    final secondaryColor = cs.onSurface.withValues(alpha: 0.72);
    final hasMenu = widget.onEdit != null || widget.onDelete != null;

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
                    onTap: () => _setExpanded(!_expanded),
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
                            if (!_expanded && summary != null)
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
                  tooltip: _expanded
                      ? MaterialLocalizations.of(context).expandedIconTapHint
                      : MaterialLocalizations.of(context).collapsedIconTapHint,
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () => _setExpanded(!_expanded),
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
                      if (value == 'edit' && widget.onEdit != null) {
                        showEditMobilityItemDialog(
                          context,
                          widget.title,
                          widget.subtitle,
                          widget.shortTitle,
                          widget.onEdit!,
                        );
                      } else if (value == 'delete') {
                        widget.onDelete?.call();
                      }
                    },
                    itemBuilder: (ctx) {
                      final menuL10n = AppLocalizations.of(ctx);
                      return [
                        if (widget.onEdit != null)
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(menuL10n.workoutBuilderEditExercise),
                          ),
                        if (widget.onDelete != null)
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
          if (_expanded) ...[
            const Divider(height: 1, color: WorkoutSessionCardChrome.divider),
            Padding(
              padding: WorkoutSessionCardChrome.expandedPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.shortTitle.trim().isNotEmpty)
                    Text(
                      widget.shortTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: secondaryColor,
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
                        color: secondaryColor,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (widget.onEdit != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => showEditMobilityItemDialog(
                          context,
                          widget.title,
                          widget.subtitle,
                          widget.shortTitle,
                          widget.onEdit!,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(l10n.workoutBuilderEditExercise),
                        style: TextButton.styleFrom(
                          foregroundColor: StitchM3Theme.accent,
                          visualDensity: VisualDensity.compact,
                          minimumSize: const Size(0, 44),
                        ),
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
