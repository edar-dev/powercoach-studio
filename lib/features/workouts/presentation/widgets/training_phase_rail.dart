import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/workout_phase_presets.dart';

/// Horizontal Stitch-style phase pills strip (never a vertical desktop rail).
class TrainingPhaseRail extends StatelessWidget {
  const TrainingPhaseRail({
    super.key,
    required this.phases,
    required this.selectedPhaseIndex,
    required this.onSelectPhase,
    this.onAddPhase,
    this.onDuplicatePhase,
    this.onEditPhaseSettings,
    @Deprecated('Vertical phase rail is no longer used; always horizontal.')
    this.vertical = false,
  });

  final List<Phase> phases;
  final int selectedPhaseIndex;
  final ValueChanged<int> onSelectPhase;
  final VoidCallback? onAddPhase;
  final VoidCallback? onDuplicatePhase;
  final VoidCallback? onEditPhaseSettings;

  /// Ignored — layout is always horizontal to match Stitch.
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final pills = <Widget>[
      for (var i = 0; i < phases.length; i++)
        _PhasePill(
          index: i,
          phase: phases[i],
          selected: i == selectedPhaseIndex,
          onTap: () => onSelectPhase(i),
          l10n: l10n,
          theme: theme,
          cs: cs,
        ),
      if (onAddPhase != null)
        _DashedActionChip(
          icon: Icons.add,
          label: l10n.workoutPhaseAdd,
          onTap: onAddPhase!,
          cs: cs,
          theme: theme,
        ),
    ];

    final trailing = <Widget>[
      if (onDuplicatePhase != null)
        _OutlineActionChip(
          icon: Icons.copy_outlined,
          label: l10n.workoutPhaseDuplicate,
          onTap: onDuplicatePhase!,
          cs: cs,
          theme: theme,
        ),
      if (onEditPhaseSettings != null)
        _OutlineActionChip(
          icon: Icons.tune,
          label: l10n.workoutPhaseSettings,
          onTap: onEditPhaseSettings!,
          cs: cs,
          theme: theme,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackTrailing = constraints.maxWidth < 720;
        final pillsRow = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < pills.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                pills[i],
              ],
            ],
          ),
        );

        if (trailing.isEmpty) return pillsRow;

        if (stackTrailing) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              pillsRow,
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trailing,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: pillsRow),
            const SizedBox(width: 12),
            ...[
              for (var i = 0; i < trailing.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                trailing[i],
              ],
            ],
          ],
        );
      },
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({
    required this.index,
    required this.phase,
    required this.selected,
    required this.onTap,
    required this.l10n,
    required this.theme,
    required this.cs,
  });

  final int index;
  final Phase phase;
  final bool selected;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final label = localizedPhaseName(l10n, phase.name);
    final weeksLabel = selected
        ? l10n.workoutPhaseWeeksCount(phase.weeks.length)
        : l10n.workoutPhaseWeeksCountShort(phase.weeks.length);

    final bg = selected ? cs.primary : cs.surfaceContainerHighest;
    final fg = selected ? cs.onPrimary : cs.onSurface;
    final muted = selected
        ? cs.onPrimary.withValues(alpha: 0.9)
        : cs.onSurfaceVariant;
    final border = selected
        ? cs.primary.withValues(alpha: 0.55)
        : cs.outlineVariant.withValues(alpha: 0.7);

    return Material(
      color: bg,
      elevation: selected ? 2 : 0,
      shadowColor: cs.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulseDot(active: selected, cs: cs),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.workoutPhaseNumbered(index + 1).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.onPrimary.withValues(alpha: 0.14)
                      : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                  border: selected
                      ? Border.all(color: cs.onPrimary.withValues(alpha: 0.25))
                      : null,
                ),
                child: Text(
                  weeksLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.active, required this.cs});

  final bool active;
  final ColorScheme cs;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.active
        ? widget.cs.onPrimary
        : widget.cs.onSurfaceVariant.withValues(alpha: 0.55);
    if (!widget.active) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: base, shape: BoxShape.circle),
      );
    }
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: base, shape: BoxShape.circle),
      ),
    );
  }
}

class _DashedActionChip extends StatelessWidget {
  const _DashedActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cs,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: cs.outlineVariant,
            radius: 12,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: cs.onSurfaceVariant),
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

class _OutlineActionChip extends StatelessWidget {
  const _OutlineActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cs,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
