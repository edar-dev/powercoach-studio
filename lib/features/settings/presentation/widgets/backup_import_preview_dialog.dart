import 'package:flutter/material.dart';

import '../../../../core/backup/user_data_backup_codec.dart';
import '../../../../l10n/app_localizations.dart';

/// User choice when importing a backup file.
class BackupImportDecision {
  const BackupImportDecision({required this.replaceAll});

  final bool replaceAll;
}

/// Preview merge vs replace-all before restoring a backup.
class BackupImportPreviewDialog extends StatefulWidget {
  const BackupImportPreviewDialog({
    super.key,
    required this.l10n,
    required this.counts,
  });

  final AppLocalizations l10n;
  final BackupPreviewCounts counts;

  @override
  State<BackupImportPreviewDialog> createState() =>
      _BackupImportPreviewDialogState();
}

class _BackupImportPreviewDialogState extends State<BackupImportPreviewDialog> {
  var _replaceAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final counts = widget.counts;

    return AlertDialog(
      title: Text(l10n.backupImportPreviewTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.backupImportCounts(
              counts.customers,
              counts.plans,
              counts.executions,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(
                value: false,
                label: Text(l10n.backupImportMerge),
              ),
              ButtonSegment<bool>(
                value: true,
                label: Text(l10n.backupImportReplaceAll),
              ),
            ],
            selected: {_replaceAll},
            onSelectionChanged: (selection) {
              setState(() => _replaceAll = selection.first);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.exerciseLibraryCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(BackupImportDecision(replaceAll: _replaceAll)),
          child: Text(l10n.backupImportConfirm),
        ),
      ],
    );
  }
}
