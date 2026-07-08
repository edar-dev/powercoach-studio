import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Bottom sheet for updating a scheduled session (status or calendar override).
Future<String?> showPlanSessionActionsSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(l10n.sessionCompleted),
            onTap: () => Navigator.of(ctx).pop('status_completed'),
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle_outline),
            title: Text(l10n.sessionSkipped),
            onTap: () => Navigator.of(ctx).pop('status_skipped'),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.sessionMarkPlanned),
            onTap: () => Navigator.of(ctx).pop('status_planned'),
          ),
          ListTile(
            leading: const Icon(Icons.event_busy_outlined),
            title: Text(l10n.sessionSkipDate),
            onTap: () => Navigator.of(ctx).pop('override_skip'),
          ),
          ListTile(
            leading: const Icon(Icons.event_repeat_outlined),
            title: Text(l10n.sessionReschedule),
            onTap: () => Navigator.of(ctx).pop('override_move'),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.sessionOverrideClear),
            onTap: () => Navigator.of(ctx).pop('override_clear'),
          ),
        ],
        ),
      ),
    ),
  );
}
