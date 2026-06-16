import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_mobility_mutations.dart';

void main() {
  group('workout_mobility_mutations', () {
    late WorkoutRoutine routine;
    late MobilitySection sectionA;
    late MobilitySection sectionB;

    setUp(() {
      sectionA = const MobilitySection(id: 'sec_a', name: 'Warm-up');
      sectionB = const MobilitySection(id: 'sec_b', name: 'Cool-down');
      routine = WorkoutRoutine.empty().copyWith(
        mobilitySections: [sectionA, sectionB],
        mobilityItems: [
          const MobilityItem(
            id: 'm1',
            title: 'Hip opener',
            subtitle: '30s',
            sectionId: 'sec_a',
          ),
          const MobilityItem(
            id: 'm2',
            title: 'Shoulder CARs',
            subtitle: '5 each',
            sectionId: 'sec_a',
          ),
          const MobilityItem(
            id: 'm3',
            title: 'Child pose',
            subtitle: '60s',
            sectionId: 'sec_b',
          ),
        ],
      );
    });

    test('addMobilityItemToRoutine appends item', () {
      const item = MobilityItem(
        id: 'm_new',
        title: 'Cat-cow',
        subtitle: '10 reps',
        sectionId: 'sec_a',
      );
      final updated = addMobilityItemToRoutine(routine: routine, item: item);
      expect(updated.mobilityItems, hasLength(4));
      expect(updated.mobilityItems.last.id, 'm_new');
    });

    test('removeMobilityItemFromRoutine drops by id', () {
      final updated = removeMobilityItemFromRoutine(
        routine: routine,
        itemId: 'm2',
      );
      expect(updated.mobilityItems.map((e) => e.id), ['m1', 'm3']);
    });

    test('reorderMobilityItemsInSection reorders within section only', () {
      final updated = reorderMobilityItemsInSection(
        routine: routine,
        sectionId: 'sec_a',
        oldIndex: 0,
        newIndex: 1,
      );
      final sectionAItems = updated.mobilityItems
          .where((e) => e.sectionId == 'sec_a')
          .map((e) => e.id)
          .toList();
      expect(sectionAItems, ['m2', 'm1']);
      expect(
        updated.mobilityItems.where((e) => e.sectionId == 'sec_b').length,
        1,
      );
    });

    test('deleteMobilitySectionFromRoutine moves items to another section', () {
      final updated = deleteMobilitySectionFromRoutine(
        routine: routine,
        sectionIndex: 1,
      );
      expect(updated, isNotNull);
      expect(updated!.mobilitySections, hasLength(1));
      expect(updated.mobilitySections.single.id, 'sec_a');
      expect(updated.mobilityItems.every((e) => e.sectionId == 'sec_a'), isTrue);
    });

    test('deleteMobilitySectionFromRoutine returns null for last section', () {
      final singleSection = routine.copyWith(
        mobilitySections: [sectionA],
        mobilityItems: routine.mobilityItems
            .where((e) => e.sectionId == 'sec_a')
            .toList(),
      );
      expect(
        deleteMobilitySectionFromRoutine(
          routine: singleSection,
          sectionIndex: 0,
        ),
        isNull,
      );
    });

    test('updateMobilityItemInRoutine patches fields', () {
      final updated = updateMobilityItemInRoutine(
        routine: routine,
        itemId: 'm1',
        title: '90/90',
        subtitle: '45s',
        shortTitle: '90',
      );
      final item = updated.mobilityItems.firstWhere((e) => e.id == 'm1');
      expect(item.title, '90/90');
      expect(item.subtitle, '45s');
      expect(item.shortTitle, '90');
    });
  });
}
