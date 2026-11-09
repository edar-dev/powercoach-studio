// Phase B smoke 1: authenticated shell (local harness — no live Supabase).
// Cold start → 4 primary tabs → Settings hides bottom NavigationBar.
//
// Run (emulator / device):
//   flutter test integration_test/phone_smokes/shell_smoke_test.dart -d <deviceId>
// Nightly: Codemagic android_integration_nightly workflow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_path_provider_platform.dart';
import '../support/phone_smoke_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_shell_smoke_',
    );
  });

  testWidgets(
    'phone shell: 4 tabs then Settings hides bottom bar',
    (tester) async {
      final router = buildShellSmokeRouter();
      await pumpPhoneShellSmoke(tester, router);

      expect(find.text('Today body'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.destinations, hasLength(4));
      expect(bar.height, 64);

      await tester.tap(find.text('Customers'));
      await tester.pumpAndSettle();
      expect(find.text('Customers body'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, AppPaths.customers);

      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();
      expect(find.text('Builder body'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppPaths.workoutBuilder,
      );

      await tester.tap(find.text('Diary'));
      await tester.pumpAndSettle();
      expect(find.text('Diary body'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppPaths.workoutDiary,
      );

      // Return to Today so Settings action is in the hub AppBar.
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(find.text('Today body'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings destination'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, AppPaths.settings);
      expect(find.byType(NavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
