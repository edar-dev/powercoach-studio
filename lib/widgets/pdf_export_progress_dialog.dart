import 'package:flutter/material.dart';

/// Non-dismissible progress dialog while a PDF is being generated.
///
/// Do not await this call: [showDialog] completes only when the route is popped,
/// which would deadlock with [hidePdfExportProgressDialog] after generation.
void showPdfExportProgressDialog(
  BuildContext context, {
  required String message,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

void hidePdfExportProgressDialog(BuildContext context) {
  final nav = Navigator.of(context, rootNavigator: true);
  if (nav.canPop()) nav.pop();
}
