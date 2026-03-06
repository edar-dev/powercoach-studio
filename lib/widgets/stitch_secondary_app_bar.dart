import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// App bar per schermate secondarie (profilo, impostazioni, login, ecc.):
/// pulsante indietro, titolo, bordo inferiore. Usa i colori del tema (light/dark).
class StitchSecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StitchSecondaryAppBar({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.mediumImpact();
          if (onBack != null) {
            onBack!();
          } else if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: cs.outline, height: 1),
      ),
    );
  }
}
