import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

import '../../data/models/customer.dart';

void showCustomerDetailActionsSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required Customer customer,
  required int unreadNotesCount,
  required VoidCallback onOpenNotes,
  required VoidCallback onOpenReminder,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  showAppBottomSheet<void>(
    context: context,
    title: l10n.actionsTitle,
    bodyBuilder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.chat_bubble_outline),
          title: Text(l10n.customerNotesOpen),
          trailing: unreadNotesCount > 0
              ? Badge(label: Text('$unreadNotesCount'))
              : null,
          onTap: () {
            Navigator.pop(sheetContext);
            onOpenNotes();
          },
        ),
        ListTile(
          leading: const Icon(Icons.alarm_add_outlined),
          title: Text(l10n.customerReminderAction),
          onTap: () {
            Navigator.pop(sheetContext);
            onOpenReminder();
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(l10n.customerEdit),
          onTap: () {
            Navigator.pop(sheetContext);
            onEdit();
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_outline, color: colorScheme.error),
          title: Text(
            l10n.customerDelete,
            style: TextStyle(color: colorScheme.error),
          ),
          onTap: () {
            Navigator.pop(sheetContext);
            onDelete();
          },
        ),
      ],
    ),
  );
}
