import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/routing/primary_shell_top_chrome.dart';
import 'package:powercoach_studio/core/ui/widgets/shell_utility_actions.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child, {GoRouter? router}) {
  if (router != null) {
    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
    );
  }
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('it'),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ShellUtilityActions shows help, bell, and profile chip',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const Center(child: ShellUtilityActions())),
    );
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    expect(find.byTooltip(l10n.shellHelpTooltip), findsOneWidget);
    expect(find.byTooltip(l10n.shellNotificationsTooltip), findsOneWidget);
    expect(find.byTooltip(l10n.shellProfileTooltip), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });

  testWidgets('help opens tip dialog with settings link', (tester) async {
    await tester.pumpWidget(
      _wrap(const Center(child: ShellUtilityActions())),
    );
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    await tester.tap(find.byTooltip(l10n.shellHelpTooltip));
    await tester.pumpAndSettle();

    expect(find.text(l10n.shellHelpDialogTitle), findsOneWidget);
    expect(find.text(l10n.shellHelpDialogBody), findsOneWidget);
    expect(find.text(l10n.settingsTitle), findsOneWidget);
  });

  testWidgets('includeSettings adds gear action', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Center(
          child: ShellUtilityActions(includeSettings: true, dense: true),
        ),
      ),
    );
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    expect(find.byTooltip(l10n.settingsTitle), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('PrimaryShellTopChrome lays out search + utility actions',
      (tester) async {
    final router = GoRouter(
      initialLocation: AppPaths.dashboard,
      routes: [
        GoRoute(
          path: AppPaths.dashboard,
          builder: (context, state) => const Scaffold(
            body: PrimaryShellTopChrome(),
          ),
        ),
        GoRoute(
          path: AppPaths.customers,
          builder: (context, state) =>
              const Scaffold(body: Text('customers')),
        ),
      ],
    );

    await tester.pumpWidget(_wrap(const SizedBox.shrink(), router: router));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byTooltip(l10n.shellHelpTooltip), findsOneWidget);
    expect(find.byTooltip(l10n.shellNotificationsTooltip), findsOneWidget);
  });
}
