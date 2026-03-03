import 'package:flutter/material.dart';

import '../theme/stitch_m3_theme.dart';

/// Card Stitch: bg white, rounded-xl (12), border gray-200, shadow-sm. Solo Material.
class StitchCard extends StatelessWidget {
  const StitchCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StitchM3Theme.bg,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: StitchM3Theme.border),
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
