import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/settings/post_invite_onboarding_store.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/post_invite_onboarding_card.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

DashboardSnapshot _emptySnap() => const DashboardSnapshot(
      clientCount: 0,
      activePrograms: 0,
      weeklyUpdates: 0,
      todayItems: [],
      stalePlans: [],
      customersWithoutPlan: [],
    );

Widget _harness({
  required GoRouter router,
}) {
  return MaterialApp.router(
    theme: StitchM3Theme.dark,
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows three steps with progress', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: PostInviteOnboardingCard(
              snapshot: _emptySnap(),
              userId: 'user-1',
              store: PostInviteOnboardingStore.instance,
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(_harness(router: router));
    await tester.pumpAndSettle();

    expect(find.text('First steps'), findsOneWidget);
    expect(find.text('0 of 3'), findsOneWidget);
    expect(find.text('Add a client'), findsOneWidget);
    expect(find.text('Create a workout plan'), findsOneWidget);
    expect(find.text('Export the PDF'), findsOneWidget);
    expect(find.text('New client'), findsOneWidget);
  });

  testWidgets('dismiss hides the card', (tester) async {
    var dismissed = false;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: PostInviteOnboardingCard(
              snapshot: _emptySnap(),
              userId: 'user-1',
              store: PostInviteOnboardingStore.instance,
              onDismissed: () => dismissed = true,
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(_harness(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
    expect(find.text('First steps'), findsNothing);
    expect(
      await PostInviteOnboardingStore.instance.isDismissed('user-1'),
      isTrue,
    );
  });

  testWidgets('step1 navigates to /customers/new', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: PostInviteOnboardingCard(
              snapshot: _emptySnap(),
              userId: 'user-1',
              store: PostInviteOnboardingStore.instance,
            ),
          ),
        ),
        GoRoute(
          path: '/customers/new',
          builder: (context, state) =>
              const Scaffold(body: Text('New customer destination')),
        ),
      ],
    );

    await tester.pumpWidget(_harness(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New client'));
    await tester.pumpAndSettle();

    expect(find.text('New customer destination'), findsOneWidget);
  });

  testWidgets('shrinks when all steps complete', (tester) async {
    await PostInviteOnboardingStore.instance.markPdfDone('user-1');
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: PostInviteOnboardingCard(
              snapshot: const DashboardSnapshot(
                clientCount: 1,
                activePrograms: 1,
                weeklyUpdates: 0,
                todayItems: [],
                stalePlans: [],
                customersWithoutPlan: [],
              ),
              userId: 'user-1',
              store: PostInviteOnboardingStore.instance,
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(_harness(router: router));
    await tester.pumpAndSettle();

    expect(find.text('First steps'), findsNothing);
  });
}
