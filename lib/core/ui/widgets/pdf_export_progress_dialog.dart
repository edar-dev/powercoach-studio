import 'package:flutter/material.dart';

/// True while a PDF progress dialog is expected to be on the navigator.
///
/// Cleared eagerly in [hidePdfExportProgressDialog] so a second hide cannot
/// [Navigator.pop] the underlying page (e.g. workout builder after Chiudi).
bool _pdfExportProgressOpen = false;

/// Visible for tests.
@visibleForTesting
bool get debugPdfExportProgressOpen => _pdfExportProgressOpen;

/// Visible for tests.
@visibleForTesting
void debugResetPdfExportProgressOpen() => _pdfExportProgressOpen = false;

/// Non-dismissible progress dialog while a PDF is being generated.
///
/// Do not await this call: [showDialog] completes only when the route is popped,
/// which would deadlock with [hidePdfExportProgressDialog] after generation.
void showPdfExportProgressDialog(
  BuildContext context, {
  required String message,
}) {
  _pdfExportProgressOpen = true;
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
  ).whenComplete(() {
    _pdfExportProgressOpen = false;
  });
}

/// Pops the PDF progress dialog if one is still open.
///
/// Safe to call more than once: after the first successful hide (or route
/// dismissal), further calls are no-ops and will not pop the page underneath.
void hidePdfExportProgressDialog(BuildContext context) {
  if (!_pdfExportProgressOpen) return;
  // Clear before pop so a synchronous second hide cannot race whenComplete.
  _pdfExportProgressOpen = false;
  final nav = Navigator.of(context, rootNavigator: true);
  if (nav.canPop()) nav.pop();
}
