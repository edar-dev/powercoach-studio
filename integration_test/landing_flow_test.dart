// E2E tests for unauthenticated flows: login form, optional landing when visible.
// Same .env requirement as app_test.dart.
// When not logged in the app redirects to /login, so we mainly assert login UI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:powercoach_studio/app.dart';
import 'package:powercoach_studio/core/platform/app_env_loader.dart';

Future<void> _initForTest() async {
  try {
    await loadAppEnv();
  } catch (_) {}
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

  group('Unauthenticated flow E2E', () {
    testWidgets('Login screen shows form fields and links', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Accedi'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Password dimenticata?'), findsOneWidget);
      expect(find.text('Registrati'), findsWidgets);
    });

    testWidgets('Landing hero visible when on landing', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (find.text('Power').evaluate().isEmpty) return;

      expect(find.text('Power'), findsOneWidget);
      expect(find.text('Inizia ora'), findsWidgets);
    });

    testWidgets('Landing features visible after scroll when on landing', (WidgetTester tester) async {
      await tester.pumpWidget(const PowerCoachStudioApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (find.text('Power').evaluate().isEmpty) return;

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Funzionalità Premium'), findsOneWidget);
    });
  });
}
