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
          builder: (_, __) => const Scaffold(body: Text('dashboard')),
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
}
