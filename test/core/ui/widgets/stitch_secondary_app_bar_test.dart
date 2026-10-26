import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'StitchSecondaryAppBar empty-stack back navigates to dashboard not root',
    (tester) async {
      late GoRouter router;
      router = GoRouter(
        initialLocation: AppPaths.settings,
        routes: [
          GoRoute(
            path: AppPaths.settings,
            builder: (context, state) => Scaffold(
              appBar: const StitchSecondaryAppBar(title: 'Settings'),
              body: const Text('settings-body'),
            ),
          ),
          GoRoute(
            path: AppPaths.dashboard,
            builder: (context, state) =>
                const Scaffold(body: Text('dashboard-dest')),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Text('root-dest')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('settings-body'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('dashboard-dest'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppPaths.dashboard,
      );
      expect(find.text('root-dest'), findsNothing);
    },
  );

  testWidgets(
    'StitchSecondaryAppBar Home navigates to dashboard',
    (tester) async {
      late GoRouter router;
      router = GoRouter(
        initialLocation: AppPaths.settings,
        routes: [
          GoRoute(
            path: AppPaths.settings,
            builder: (context, state) => Scaffold(
              appBar: const StitchSecondaryAppBar(title: 'Settings'),
              body: const Text('settings-body'),
            ),
          ),
          GoRoute(
            path: AppPaths.dashboard,
            builder: (context, state) =>
                const Scaffold(body: Text('dashboard-dest')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      expect(find.text('dashboard-dest'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppPaths.dashboard,
      );
    },
  );
}
