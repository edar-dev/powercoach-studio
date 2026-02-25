import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Shows a visual alert that the feature is not yet implemented.
/// Use for every user action (button, link, menu) that has no real logic yet.
void showNotImplementedAlert(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.notImplementedMessage),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
