import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_editor_exit.dart';

void main() {
  testWidgets('standalone builder back exits to dashboard', (tester) async {
    final router = GoRouter(
      initialLocation: '/workouts/builder',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const Scaffold(body: Text('dashboard')),
        ),
        GoRoute(
          path: '/workouts/builder',
          builder: (context, _) {
            return Scaffold(
              body: TextButton(
                onPressed: () => navigateBackFromWorkoutBuilder(
                  context: context,
                  editorMode: false,
                ),
                child: const Text('back'),
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('back'), findsOneWidget);
    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();

    expect(find.text('dashboard'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/dashboard');
  });

  testWidgets('editor-mode Home always exits to dashboard', (tester) async {
    final router = GoRouter(
      initialLocation: '/customers/cust-1/workouts/plan-1',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const Scaffold(body: Text('dashboard')),
        ),
        GoRoute(
          path: '/customers/cust-1/workouts',
          builder: (_, _) => const Scaffold(body: Text('workouts list')),
        ),
        GoRoute(
          path: '/customers/cust-1/workouts/plan-1',
          builder: (context, _) {
            return Scaffold(
              body: TextButton(
                onPressed: () => navigateHomeFromWorkoutBuilder(context),
                child: const Text('home'),
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();

    expect(find.text('dashboard'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/dashboard');
  });
}
