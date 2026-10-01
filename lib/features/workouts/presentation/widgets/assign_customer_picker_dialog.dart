import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/models/customer.dart';

Future<Customer?> showAssignCustomerPickerDialog(
  BuildContext context, {
  required List<Customer> customers,
}) {
  return showDialog<Customer>(
    context: context,
    builder: (ctx) => AssignCustomerPickerDialog(customers: customers),
  );
}

class AssignCustomerPickerDialog extends StatefulWidget {
  const AssignCustomerPickerDialog({super.key, required this.customers});

  final List<Customer> customers;

  @override
  State<AssignCustomerPickerDialog> createState() =>
      _AssignCustomerPickerDialogState();
}

class _AssignCustomerPickerDialogState
    extends State<AssignCustomerPickerDialog> {
  final TextEditingController _queryController = TextEditingController();
  String _queryLower = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<Customer> get _filtered {
    final q = _queryLower;
    if (q.isEmpty) return widget.customers;
    return widget.customers
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filtered;
    return AlertDialog(
      title: Text(l10n.workoutAssignCustomerTitle),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: l10n.workoutAssignCustomerSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) {
                setState(() => _queryLower = v.trim().toLowerCase());
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        l10n.workoutAssignCustomerNoMatch,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final c = filtered[i];
                        return ListTile(
                          title: Text(c.name),
                          onTap: () => Navigator.of(context).pop(c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }
}
