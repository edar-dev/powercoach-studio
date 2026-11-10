import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'workout_expandable_card.dart';

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

/// Stitch phase-rail style section pill (radius 12, primary when selected).
class MobilitySectionChip extends StatelessWidget {
  const MobilitySectionChip({
    super.key,
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
    final l10n = AppLocalizations.of(context);
    final bg = selected ? cs.primary : cs.surfaceContainerHighest;
    final fg = selected ? cs.onPrimary : cs.onSurface;
    final border = selected
        ? cs.primary.withValues(alpha: 0.55)
        : cs.outlineVariant.withValues(alpha: 0.7);

    return Material(
      color: bg,
      elevation: selected ? 2 : 0,
      shadowColor: cs.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: EdgeInsets.only(
            left: 12,
            right: selected ? 4 : 12,
            top: 4,
            bottom: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 18,
                    color: cs.onPrimary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed outline chip matching [TrainingPhaseRail] add-phase CTA.
class MobilityDashedSectionChip extends StatelessWidget {
  const MobilityDashedSectionChip({
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: cs.outlineVariant,
            radius: StitchM3Theme.radiusLg,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.colorScheme;
    final l10n = AppLocalizations.of(context);
    final summary = widget.subtitle.trim().isNotEmpty
        ? widget.subtitle
        : (widget.shortTitle.trim().isNotEmpty ? widget.shortTitle : null);
    final secondaryColor = cs.onSurface.withValues(alpha: 0.72);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: WorkoutExpandableCard(
        title: Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        summary: _expanded ? null : summary,
        expanded: _expanded,
        onExpandedChanged: (value) => setState(() => _expanded = value),
        leading: ReorderableDragStartListener(
          index: widget.index,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(
              Icons.drag_indicator,
              size: 20,
              color: secondaryColor,
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 22, color: cs.onSurfaceVariant),
          iconSize: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
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
        expandedChild: Column(
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
                ),
              ),
            ],
          ],
        ),
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

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 5.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
