import 'package:flutter/material.dart';

import '../../../core/remote/coach_entities_migration_service.dart';
import '../../../core/theme/marketing_dark_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Runs the one-shot local→cloud migration with a non-dismissible progress UI.
///
/// Returns `true` when migration finished successfully (or was a no-op).
Future<bool> showCoachEntitiesMigrationDialog(
  BuildContext context, {
  required String userId,
  CoachEntitiesMigrationService? service,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => CoachEntitiesMigrationDialog(
      userId: userId,
      service: service ?? CoachEntitiesMigrationService.instance,
    ),
  );
  return result == true;
}

class CoachEntitiesMigrationDialog extends StatefulWidget {
  const CoachEntitiesMigrationDialog({
    super.key,
    required this.userId,
    required this.service,
  });

  final String userId;
  final CoachEntitiesMigrationService service;

  @override
  State<CoachEntitiesMigrationDialog> createState() =>
      _CoachEntitiesMigrationDialogState();
}

class _CoachEntitiesMigrationDialogState
    extends State<CoachEntitiesMigrationDialog> {
  int _done = 0;
  int _total = 0;
  bool _running = true;
  bool _failed = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _run();
    });
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _failed = false;
      _error = null;
      _done = 0;
      _total = 0;
    });
    try {
      await widget.service.runMigration(
        userId: widget.userId,
        onProgress: (done, total) {
          if (!mounted) return;
          setState(() {
            _done = done;
            _total = total;
          });
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _failed = true;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progressLabel = _total <= 0
        ? l10n.coachEntitiesMigrationPreparing
        : l10n.coachEntitiesMigrationProgress(_done, _total);

    return AlertDialog(
      backgroundColor: MarketingDarkColors.stitchCard,
      title: Text(
        l10n.coachEntitiesMigrationTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _failed
                ? l10n.coachEntitiesMigrationFailure
                : l10n.coachEntitiesMigrationMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MarketingDarkColors.slate300,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          if (_running) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              progressLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MarketingDarkColors.slate300,
              ),
            ),
          ] else if (_failed) ...[
            Text(
              l10n.coachEntitiesMigrationFailureDetail('$_error'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_failed)
          FilledButton(
            onPressed: _run,
            child: Text(l10n.coachEntitiesMigrationRetry),
          ),
      ],
    );
  }
}
