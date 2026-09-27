import 'package:flutter/material.dart';

import 'auth_dark_form_shell.dart';

/// Legacy light card — prefer [AuthDarkFormShell] for auth screens.
@Deprecated('Use AuthDarkFormShell')
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    this.headerIcon = Icons.bolt,
    this.headline,
    this.subtitle,
    required this.child,
  });

  final IconData headerIcon;
  final String? headline;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AuthDarkFormShell(
      backLabel: '',
      onBack: () {},
      topBadge: const SizedBox.shrink(),
      cardHeader: Column(
        children: [
          Icon(headerIcon, color: Colors.white, size: 28),
          if (headline != null) ...[
            const SizedBox(height: 12),
            Text(
              headline!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
      child: child,
    );
  }
}
