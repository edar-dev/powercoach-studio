import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Future<void> importCustomerFromContacts(BuildContext context) async {
  final granted = await FlutterContacts.requestPermission();
  if (!context.mounted) return;
  if (!granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).customersImportContactsDenied),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }
  final contact = await FlutterContacts.openExternalPick();
  if (!context.mounted || contact == null) return;
  final name = contact.displayName.isNotEmpty
      ? contact.displayName
      : '${contact.name.first} ${contact.name.last}'.trim();
  final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
  final uri = Uri(
    path: '/customers/new',
    queryParameters: <String, String>{
      if (name.isNotEmpty) 'name': name,
      if (phone.isNotEmpty) 'phone': phone,
    },
  );
  navigateTo(context, uri.toString());
}
