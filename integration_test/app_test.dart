// E2E tests for PowerCoach Studio: UI and user interaction.
// Requires .env with SUPABASE_URL and SUPABASE_ANON_KEY so the app can build the router.
// Run: flutter test integration_test/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:powercoach_studio/app.dart';

Future<void> _initForTest() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env optional for local runs; Supabase.initialize will be no-op if empty
  }
  final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
  final key = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
  if (url.isNotEmpty && key.isNotEmpty) {
    await Supabase.initialize(url: url, anonKey: key);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _initForTest();
  });

  group('PowerCoach Studio E2E', () {
    testWidgets('App shows login or landing', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final onLanding = find.text('Power').evaluate().isNotEmpty;
      final onLogin = find.text('Accedi').evaluate().isNotEmpty;
      expect(onLanding || onLogin, true, reason: 'Expected landing (Power) or login (Accedi)');
    });

    testWidgets('Navigate landing -> login and see form', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (find.text('Power').evaluate().isNotEmpty) {
        await tester.tap(find.text('Accedi').first);
        await tester.pumpAndSettle();
      }
      expect(find.text('Accedi'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
    });

    testWidgets('Navigate login -> register and see registration form', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (find.text('Power').evaluate().isNotEmpty) {
        await tester.tap(find.text('Accedi').first);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Registrati').first);
      await tester.pumpAndSettle();

      expect(find.text('Conferma password'), findsOneWidget);
      expect(find.text('Registrati'), findsWidgets);
    });

    testWidgets('Navigate login -> forgot password', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (find.text('Power').evaluate().isNotEmpty) {
        await tester.tap(find.text('Accedi').first);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Password dimenticata?'));
      await tester.pumpAndSettle();

      expect(find.text('Reimposta password'), findsOneWidget);
      expect(find.text('Invia link'), findsOneWidget);
    });

    testWidgets('Login form shows validation when submit empty', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (find.text('Power').evaluate().isNotEmpty) {
        await tester.tap(find.text('Accedi').first);
        await tester.pumpAndSettle();
      }
      final loginButtons = find.text('Accedi');
      expect(loginButtons, findsWidgets);
      await tester.tap(loginButtons.last);
      await tester.pumpAndSettle();

      expect(
        find.text('Inserisci un\'email valida.').evaluate().isNotEmpty ||
            find.text('Inserisci la password.').evaluate().isNotEmpty,
        true,
        reason: 'Expected email or password validation message',
      );
    });

    testWidgets('Register screen back button returns to login', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (find.text('Power').evaluate().isNotEmpty) {
        await tester.tap(find.text('Accedi').first);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Registrati').first);
      await tester.pumpAndSettle();
      expect(find.text('Conferma password'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Password dimenticata?'), findsOneWidget);
    });

    testWidgets('Forgot password screen back to login', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (find.text('Power').evaluate().isNotEmpty) {
        await tester.tap(find.text('Accedi').first);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Password dimenticata?'));
      await tester.pumpAndSettle();
      expect(find.text('Invia link'), findsOneWidget);

      await tester.tap(find.text('Torna al login'));
      await tester.pumpAndSettle();

      expect(find.text('Password dimenticata?'), findsOneWidget);
    });
  });
}
