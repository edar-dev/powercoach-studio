import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/backup/user_data_backup_codec.dart';
import '../../../../l10n/app_localizations.dart';

/// User choice when importing a backup file (always restores all entity types).
class BackupImportDecision {
  const BackupImportDecision({
    required this.replaceAll,
  });

  final bool replaceAll;
}

/// Preview merge vs replace-all before restoring a backup.
class BackupImportPreviewDialog extends StatefulWidget {
  const BackupImportPreviewDialog({
    super.key,
    required this.l10n,
    required this.counts,
    this.exportedAt,
    this.appVersion,
  });

  final AppLocalizations l10n;
  final BackupPreviewCounts counts;
  final String? exportedAt;
  final String? appVersion;

  @override
  State<BackupImportPreviewDialog> createState() =>
      _BackupImportPreviewDialogState();
}

class _BackupImportPreviewDialogState extends State<BackupImportPreviewDialog> {
  var _replaceAll = false;

  String? _metadataLine(AppLocalizations l10n) {
    final exportedAt = widget.exportedAt;
    final appVersion = widget.appVersion;
    if (exportedAt == null && appVersion == null) return null;
    final parsed = exportedAt == null ? null : DateTime.tryParse(exportedAt);
    final dateLabel = parsed == null
        ? (exportedAt ?? '—')
        : DateFormat.yMMMd(l10n.localeName).format(parsed.toLocal());
    return l10n.backupImportMetadata(
      dateLabel,
      appVersion ?? '—',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final counts = widget.counts;
    final metadata = _metadataLine(l10n);

    return AlertDialog(
      title: Text(l10n.backupImportPreviewTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (metadata != null) ...[
              Text(metadata),
              const SizedBox(height: 8),
            ],
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.exerciseLibraryCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            BackupImportDecision(replaceAll: _replaceAll),
          ),
          child: Text(l10n.backupImportConfirm),
        ),
      ],
    );
  }
}
