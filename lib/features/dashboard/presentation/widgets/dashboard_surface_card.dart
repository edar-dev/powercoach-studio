import 'package:flutter/material.dart';

import '../../../../theme/stitch_m3_theme.dart';

/// Rounded surface used for dashboard section bodies and empty states.
class DashboardSurfaceCard extends StatelessWidget {
  const DashboardSurfaceCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}
