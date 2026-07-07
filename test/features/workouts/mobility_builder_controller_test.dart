import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/mobility_builder_controller.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';

WorkoutRoutine _routineWithMobility() {
  return WorkoutRoutine.empty().copyWith(
    mobilitySections: const [
      MobilitySection(id: 'sec-a', name: 'Warm-up'),
      MobilitySection(id: 'sec-b', name: 'Cooldown'),
    ],
    mobilityItems: const [
      MobilityItem(
        id: 'm1',
        title: 'Band pull',
        subtitle: '2x15',
        sectionId: 'sec-a',
      ),
      MobilityItem(
        id: 'm2',
        title: 'Stretch',
        subtitle: '60s',
        sectionId: 'sec-b',
      ),
    ],
  );
}

void main() {
  group('MobilityBuilderController', () {
    late WorkoutBuilderSessionController session;
    late MobilityBuilderController mobility;

    setUp(() {
      session = WorkoutBuilderSessionController(routine: _routineWithMobility());
      mobility = MobilityBuilderController(session);
    });

    tearDown(() {
      mobility.dispose();
      session.dispose();
    });

    test('itemsForSelectedSection filters by selected section', () {
      expect(mobility.itemsForSelectedSection, hasLength(1));
      expect(mobility.itemsForSelectedSection.first.id, 'm1');

      mobility.selectSection(1);
      expect(mobility.itemsForSelectedSection.single.id, 'm2');
    });

    test('addSection selects the new section', () {
      expect(
        mobility.addSection(name: 'Finisher'),
        isTrue,
      );
      expect(mobility.sections, hasLength(3));
      expect(mobility.selectedSectionIndex, 2);
      expect(mobility.sections.last.name, 'Finisher');
    });

    test('deleteSection refuses to remove the last section', () {
      session.setRoutine(
        WorkoutRoutine.empty().copyWith(
          mobilitySections: const [
            MobilitySection(id: 'only', name: 'Only'),
          ],
        ),
      );
      expect(mobility.deleteSection(0), isFalse);
    });

    test('reorderItems reorders within the active section only', () {
      mobility.addItem(
        const MobilityItem(
          id: 'm3',
          title: 'Second warm-up',
          subtitle: '',
          sectionId: 'sec-a',
        ),
      );
      expect(mobility.reorderItems(0, 1), isTrue);
      expect(
        mobility.itemsForSelectedSection.map((e) => e.id).toList(),
        ['m3', 'm1'],
      );
      expect(session.routine.mobilityItems.singleWhere((e) => e.id == 'm2').sectionId, 'sec-b');
    });

    test('updateItem changes title and subtitle', () {
      expect(
        mobility.updateItem(
          itemId: 'm1',
          title: 'Updated',
          subtitle: '3x10',
        ),
        isTrue,
      );
      final item = session.routine.mobilityItems.firstWhere((e) => e.id == 'm1');
      expect(item.title, 'Updated');
      expect(item.subtitle, '3x10');
    });
  });
}
