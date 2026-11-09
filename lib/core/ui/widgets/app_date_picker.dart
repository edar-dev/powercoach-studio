import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../breakpoints.dart';
import 'app_sheet.dart';

/// Adaptive date picker: full-width bottom sheet on phone, Material dialog on tablet+.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
  String? confirmLabel,
  TransitionBuilder? builder,
}) async {
  final clampedInitial = _clampDate(initialDate, firstDate, lastDate);

  if (Breakpoints.isTabletOrWider(context)) {
    return showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      builder: builder,
    );
  }

  final l10n = AppLocalizations.of(context);
  final selected = ValueNotifier<DateTime>(clampedInitial);

  try {
    return await showAppBottomSheet<DateTime>(
      context: context,
      title: helpText ?? MaterialLocalizations.of(context).datePickerHelpText,
      wrapContent: true,
      primaryActionLabel: confirmLabel ?? l10n.customerSave,
      onPrimaryAction: () {
        Navigator.of(context).pop(selected.value);
      },
      bodyBuilder: (sheetContext) {
        Widget calendar = CalendarDatePicker(
          initialDate: selected.value,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateChanged: (date) => selected.value = date,
        );
        if (builder != null) {
          calendar = builder(sheetContext, calendar);
        }
        return calendar;
      },
    );
  } finally {
    selected.dispose();
  }
}

DateTime _clampDate(DateTime value, DateTime first, DateTime last) {
  if (value.isBefore(first)) return first;
  if (value.isAfter(last)) return last;
  return value;
}
