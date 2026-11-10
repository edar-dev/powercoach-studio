import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';

/// Shared visual tokens for session-style exercise/item cards.
///
/// Used by [SessionExerciseEditorCard] and mobility item cards so both share
/// one chrome instead of drifting into a third style.
abstract final class WorkoutSessionCardChrome {
  static const Color cardBg = Color(0xFF151D2E);
  static const Color cardBorder = Color(0xFF28354D);
  static const Color inputBg = Color(0xFF0F172A);
  static const Color divider = Color(0xFF28354D);
  static const double radius = 12;
  static const EdgeInsets margin = EdgeInsets.only(bottom: 12);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(12, 10, 4, 10);
  static const EdgeInsets expandedPadding = EdgeInsets.fromLTRB(12, 12, 12, 14);
}

/// Outer shell matching the session exercise editor card surface.
class WorkoutSessionCardShell extends StatelessWidget {
  const WorkoutSessionCardShell({
    super.key,
    required this.child,
    this.margin = WorkoutSessionCardChrome.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: WorkoutSessionCardChrome.cardBg,
        borderRadius: BorderRadius.circular(WorkoutSessionCardChrome.radius),
        border: Border.all(color: WorkoutSessionCardChrome.cardBorder),
      ),
      child: child,
    );
  }
}

/// Accent index badge used in session-style card headers.
class WorkoutSessionIndexBadge extends StatelessWidget {
  const WorkoutSessionIndexBadge({
    super.key,
    required this.index,
    required this.theme,
  });

  final int index;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: StitchM3Theme.accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: StitchM3Theme.accent.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        '$index',
        style: theme.textTheme.labelMedium?.copyWith(
          color: StitchM3Theme.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
