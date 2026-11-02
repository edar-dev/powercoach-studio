import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/dashboard/domain/session_detail_loader.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/session_detail_view.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/session_logger_actions_bar.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('SessionDetailView shows customer, session, and exercise count', (
    tester,
  ) async {
    var openBuilderTapped = false;

    final event = PlanCalendarEvent(
      day: DateTime(2026, 6, 15),
      customerId: 'c1',
      planId: 'p1',
      customerName: 'Marco Rossi',
      programName: 'Hypertrophy',
      weekIndex: 0,
      dayIndex: 0,
      sessionLabel: 'Day A',
      status: PlanSessionStatus.planned,
    );
    final snapshot = SessionDetailSnapshot(
      event: event,
      exerciseCount: 3,
      phase: 'Accumulation',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SessionDetailView(
            snapshot: snapshot,
            onOpenBuilder: () => openBuilderTapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Marco Rossi'), findsOneWidget);
    expect(find.textContaining('Hypertrophy'), findsOneWidget);
    expect(find.text('Accumulation'), findsOneWidget);
    expect(find.text('3 exercises'), findsOneWidget);

    await tester.tap(find.text('Open in builder'));
    expect(openBuilderTapped, isTrue);
  });

  testWidgets('SessionLoggerActionsBar exposes Skip / Log / Complete', (
    tester,
  ) async {
    var skip = false;
    var log = false;
    var complete = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          bottomNavigationBar: SessionLoggerActionsBar(
            onSkip: () => skip = true,
            onLog: () => log = true,
            onComplete: () => complete = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.tap(find.text('Log'));
    await tester.tap(find.text('Complete'));
    expect(skip, isTrue);
    expect(log, isTrue);
    expect(complete, isTrue);
  });
}
