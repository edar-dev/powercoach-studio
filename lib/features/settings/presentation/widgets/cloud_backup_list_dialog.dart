import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/backup/cloud_backup_storage.dart';
import '../../../../l10n/app_localizations.dart';

/// Lets the coach pick a cloud snapshot to restore, or delete old ones.
///
/// Returns the selected [CloudBackupObject], or `null` if dismissed.
class CloudBackupListDialog extends StatefulWidget {
  const CloudBackupListDialog({
    super.key,
    required this.l10n,
    required this.backups,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final List<CloudBackupObject> backups;

  /// Deletes [backup] from cloud storage; returns true on success.
  final Future<bool> Function(CloudBackupObject backup) onDelete;

  @override
  State<CloudBackupListDialog> createState() => _CloudBackupListDialogState();
}

class _CloudBackupListDialogState extends State<CloudBackupListDialog> {
  late List<CloudBackupObject> _backups;
  final Set<String> _deletingPaths = {};

  @override
  void initState() {
    super.initState();
    _backups = [...widget.backups];
  }

  Future<void> _handleDelete(CloudBackupObject backup) async {
    setState(() => _deletingPaths.add(backup.path));
    final success = await widget.onDelete(backup);
    if (!mounted) return;
    setState(() {
      _deletingPaths.remove(backup.path);
      if (success) {
        _backups.removeWhere((b) => b.path == backup.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      title: Text(l10n.settingsCloudBackupListTitle),
      content: SizedBox(
        width: 400,
        child: _backups.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.settingsCloudBackupListEmpty),
              )
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _backups.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final backup = _backups[index];
                    final isDeleting = _deletingPaths.contains(backup.path);
                    return ListTile(
                      leading: const Icon(Icons.cloud_outlined),
                      title: Text(
                        DateFormat.yMMMd(
                          l10n.localeName,
                        ).add_Hm().format(backup.createdAt.toLocal()),
                      ),
                      trailing: isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              tooltip: l10n.settingsCloudBackupDeleteTooltip,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _handleDelete(backup),
                            ),
                      onTap: isDeleting
                          ? null
                          : () => Navigator.of(context).pop(backup),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.exerciseLibraryCancel),
        ),
      ],
    );
  }
}
