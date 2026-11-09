// Phase B smoke 2: day editor / session edit sticky Salva above safe area.
// Local harness with in-memory WorkoutRoutine — no live Supabase.
//
// Run (emulator / device):
//   flutter test integration_test/phone_smokes/day_editor_smoke_test.dart -d <deviceId>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_path_provider_platform.dart';
import '../support/phone_smoke_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_day_editor_smoke_',
    );
  });

  testWidgets(
    'phone day editor: sticky Salva modifiche clears home indicator',
    (tester) async {
      await setPhoneSmokeView(
        tester,
        bottomPadding: kPhoneSmokeHomeIndicator,
      );

      final session = WorkoutBuilderSessionController(
        routine: smokeRoutineWithExercise(),
      );
      final day = session.routine.weeks.first.days.first;

      await tester.pumpWidget(
        wrapItalianPhone(
          size: kPhoneSmokeSize,
          padding: const EdgeInsets.only(bottom: kPhoneSmokeHomeIndicator),
          Builder(builder: (context) => dayEditorSmokeBody(context, session, day)),
        ),
      );
      await tester.pumpAndSettle();

      final saveLabel = find.text('Salva modifiche');
      expect(saveLabel, findsOneWidget);
      // Header Cancel stays off the sticky phone path.
      expect(find.text('Annulla'), findsNothing);

      final saveRect = tester.getRect(saveLabel);
      expect(
        saveRect.bottom,
        lessThanOrEqualTo(kPhoneSmokeSize.height - kPhoneSmokeHomeIndicator),
      );

      // Sticky CTA uses full-width chrome with check icon.
      expect(find.byIcon(Icons.check), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
