import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_diary_filter.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_diary_metrics.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_diary_filters_bar.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_diary_kpi_row.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('wide diary KPI strip and filters bar smoke', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: WorkoutDiaryKpiRow(
                  kpis: WorkoutDiaryKpis(
                    completedCount: 3,
                    skippedCount: 1,
                    volumeKg: 1200,
                    hasParsableVolume: true,
                    setCount: 24,
                    exerciseCount: 8,
                    compliancePercent: 75,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: WorkoutDiaryFiltersBar(
                  dateRange: DiaryDateRange.last30,
                  statusFilter: DiaryStatusFilter.all,
                  customers: const [],
                  filterCustomerId: null,
                  visibleCount: 3,
                  onDateRangeChanged: (_) {},
                  onStatusChanged: (_) {},
                  onAthleteTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('COMPLETATE'), findsOneWidget);
    expect(find.text('Tutti gli stati'), findsOneWidget);
    expect(find.textContaining('Mostrando 3'), findsOneWidget);
  });
}
