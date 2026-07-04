import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// App bar Stitch: logo + titolo, bordo inferiore, solo Material.
class StitchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StitchAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  static const String _logoAsset = 'assets/images/powercoach_logo.png';

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: leading,
      title: Row(
        children: [
          _LogoBadge(logoAsset: _logoAsset),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: cs.outline, height: 1),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.logoAsset});

  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        logoAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _FallbackLogoBadge(),
      ),
    );
  }
}

class _FallbackLogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StitchM3Theme.logoStart, StitchM3Theme.logoEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
      ),
      alignment: Alignment.center,
      child: const Text(
        'PCS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
