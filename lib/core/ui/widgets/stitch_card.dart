import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Card Stitch: superficie dal tema (light/dark), rounded-xl (12), bordo, shadow-sm.
/// Se [useTheme] è true (default quando usato in schermate con tema), usa colorScheme.
class StitchCard extends StatelessWidget {
  const StitchCard({
    super.key,
    required this.child,
    this.padding,
    this.useTheme = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  /// Se true, usa Theme.of(context).colorScheme per superficie e bordo (coerente con dark/light).
  final bool useTheme;

  @override
  Widget build(BuildContext context) {
    final cs = useTheme ? Theme.of(context).colorScheme : null;
    final color = cs?.surface ?? StitchM3Theme.bg;
    final borderColor = cs?.outline ?? StitchM3Theme.border;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? StitchM3Theme.padding24,
        child: child,
      ),
    );
  }
}
