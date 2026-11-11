import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/ui/widgets/pdf_export_progress_dialog.dart';

void main() {
  setUp(debugResetPdfExportProgressOpen);

  tearDown(debugResetPdfExportProgressOpen);

  testWidgets(
    'hidePdfExportProgressDialog is idempotent and does not pop the page',
    (tester) async {
      var pagePops = 0;
      BuildContext? pageContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute<void>(
                          builder: (ctx) {
                            pageContext = ctx;
                            return const Scaffold(
                              body: Center(child: Text('Workout page')),
                            );
                          },
                        ),
                      )
                          .then((_) => pagePops++);
                    },
                    child: const Text('Open page'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open page'));
      await tester.pumpAndSettle();
      expect(find.text('Workout page'), findsOneWidget);
      expect(pageContext, isNotNull);

      showPdfExportProgressDialog(pageContext!, message: 'Generating…');
      // CircularProgressIndicator animates forever — avoid pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating…'), findsOneWidget);
      expect(debugPdfExportProgressOpen, isTrue);

      hidePdfExportProgressDialog(pageContext!);
      // Synchronous second hide — mirrors finally after an early hide.
      hidePdfExportProgressDialog(pageContext!);
      await tester.pump();
      // Allow the dialog route transition to finish (spinner blocks settle).
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Generating…'), findsNothing);
      expect(find.text('Workout page'), findsOneWidget);
      expect(pagePops, 0);
      expect(debugPdfExportProgressOpen, isFalse);
    },
  );
}
