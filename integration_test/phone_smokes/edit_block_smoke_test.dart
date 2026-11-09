// Phase B smoke 3: Modifica blocco → type a field → Salva / keyboard dismiss.
// Local harness via showEditSetDialog — no live Supabase.
//
// Run (emulator / device):
//   flutter test integration_test/phone_smokes/edit_block_smoke_test.dart -d <deviceId>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_path_provider_platform.dart';
import '../support/phone_smoke_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_edit_block_smoke_',
    );
  });

  testWidgets(
    'phone Modifica blocco: type Serie then Salva stays hittable',
    (tester) async {
      await setPhoneSmokeView(tester);

      await tester.pumpWidget(editBlockSmokeHarness());
      await tester.tap(find.text('Open set'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica blocco'), findsOneWidget);
      expect(find.text('Salva'), findsOneWidget);

      final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(sheet.showDragHandle, isTrue);

      final serieField = fieldByLabel(tester, 'Serie');
      final serieFinder = find.byWidget(serieField);
      await tester.tap(serieFinder);
      await tester.pumpAndSettle();
      await tester.enterText(serieFinder, '4');
      await tester.pumpAndSettle();

      // Simulate keyboard inset after focus/type (device keyboards vary).
      const keyboardInset = 300.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboardInset);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      final saveFinder = find.widgetWithText(FilledButton, 'Salva');
      expect(saveFinder, findsOneWidget);
      final saveRect = tester.getRect(saveFinder);
      expect(
        saveRect.bottom,
        lessThanOrEqualTo(kPhoneSmokeSize.height - keyboardInset + 0.5),
      );
      expect(saveRect.top, greaterThanOrEqualTo(0));

      // Dismiss keyboard path: clear insets and tap Salva.
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();
      await tester.tap(saveFinder);
      await tester.pumpAndSettle();

      expect(find.text('Modifica blocco'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
