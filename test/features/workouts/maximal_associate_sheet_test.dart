import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/data/customer_maximal_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_maximal.dart';
import 'package:powercoach_studio/features/customers/data/customer_measurement_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_ref.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/maximal_associate_sheet.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxIterations = 40,
}) async {
  for (var i = 0; i < maxIterations; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  }
  fail('Timed out waiting for $finder');
}

Future<void> _pumpSheetFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _tapListTileWithTitle(WidgetTester tester, String title) async {
  final titleFinder = find.textContaining(title);
  await tester.ensureVisible(titleFinder);
  final listTile = find.ancestor(
    of: titleFinder,
    matching: find.byType(ListTile),
  );
  await tester.tap(listTile);
  await _pumpSheetFrames(tester);
}

Widget _host({
  required void Function(BuildContext context) onOpen,
}) {
  return MaterialApp(
    theme: StitchM3Theme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return FilledButton(
            onPressed: () => onOpen(context),
            child: const Text('Open'),
          );
        },
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CustomerMeasurementRepository measurementRepo;
  late CustomerMaximalRepository maximalRepo;

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_maximal_associate_sheet_test_',
    );
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
    final offline = OfflineRepositorySupport();
    measurementRepo = CustomerMeasurementRepository(offline: offline);
    maximalRepo = CustomerMaximalRepository(offline: offline);
  });

  Future<void> allowDriftWork(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  }

  testWidgets('selecting bench measurement returns measurement ref',
      (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await measurementRepo.create('c1', {
        'measurementDate':
            CustomerMeasurement.toDateString(DateTime(2025, 1, 1)),
        'benchPress1RM': 100.0,
      });
    });

    MaximalAssociateResult? result;
    await tester.pumpWidget(
      _host(
        onOpen: (context) async {
          result = await showMaximalAssociateSheet(
            context,
            customerId: 'c1',
            measurementRepository: measurementRepo,
            maximalRepository: maximalRepo,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await allowDriftWork(tester);
    await _pumpUntilFound(
      tester,
      find.text('From measurements (1RM)'),
    );

    expect(find.textContaining('Bench press: 100 kg'), findsOneWidget);

    await _tapListTileWithTitle(tester, 'Bench press: 100 kg');

    expect(result, isNotNull);
    expect(result!.cleared, isFalse);
    expect(
      result!.ref,
      const MaximalRef.measurement(lift: MaximalLift.bench),
    );
  });

  testWidgets('selecting existing custom maximal links by id', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    late CustomerMaximal created;
    await tester.runAsync(() async {
      created = await maximalRepo.create('c1', {
        'label': 'Military press',
        'weightKg': 60.0,
      });
    });

    MaximalAssociateResult? result;
    await tester.pumpWidget(
      _host(
        onOpen: (context) async {
          result = await showMaximalAssociateSheet(
            context,
            customerId: 'c1',
            measurementRepository: measurementRepo,
            maximalRepository: maximalRepo,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await allowDriftWork(tester);
    await _pumpUntilFound(
      tester,
      find.text('From measurements (1RM)'),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Military press: 60 kg'), findsOneWidget);

    await _tapListTileWithTitle(tester, 'Military press: 60 kg');

    expect(result, isNotNull);
    expect(result!.ref?.isCustom, isTrue);
    expect(result!.ref?.maximalId, created.id);
  });

  testWidgets('empty custom section shows localized empty copy', (tester) async {
    await tester.pumpWidget(
      _host(
        onOpen: (context) async {
          await showMaximalAssociateSheet(
            context,
            customerId: 'c1',
            measurementRepository: measurementRepo,
            maximalRepository: maximalRepo,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await allowDriftWork(tester);
    await _pumpUntilFound(
      tester,
      find.text('From measurements (1RM)'),
    );
    await tester.pumpAndSettle();

    expect(find.text('No custom maximals yet'), findsOneWidget);
    expect(find.text('Create custom maximal'), findsOneWidget);
  });

  testWidgets('clear removes association', (tester) async {
    MaximalAssociateResult? result;
    await tester.pumpWidget(
      _host(
        onOpen: (context) async {
          result = await showMaximalAssociateSheet(
            context,
            customerId: 'c1',
            currentRef: const MaximalRef.measurement(lift: MaximalLift.squat),
            measurementRepository: measurementRepo,
            maximalRepository: maximalRepo,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await allowDriftWork(tester);
    await _pumpUntilFound(
      tester,
      find.text('From measurements (1RM)'),
    );
    await tester.pumpAndSettle();

    final removeLink = find.widgetWithText(TextButton, 'Remove link');
    expect(removeLink, findsOneWidget);
    await tester.ensureVisible(removeLink);
    await tester.tap(removeLink);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.cleared, isTrue);
    expect(result!.ref, isNull);
  });
}
