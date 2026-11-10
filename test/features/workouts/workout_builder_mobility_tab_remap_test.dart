import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_mobility_tab_remap.dart';

void main() {
  group('remapTabIndexAfterMobilityVisibilityChange', () {
    test('hiding mobility: training stays, mobility→training, details→details', () {
      expect(
        remapTabIndexAfterMobilityVisibilityChange(
          showingMobility: false,
          previousIndex: 0,
        ),
        0,
      );
      expect(
        remapTabIndexAfterMobilityVisibilityChange(
          showingMobility: false,
          previousIndex: 1,
        ),
        0,
      );
      expect(
        remapTabIndexAfterMobilityVisibilityChange(
          showingMobility: false,
          previousIndex: 2,
        ),
        1,
      );
    });

    test('showing mobility: training stays, details shifts past mobility', () {
      expect(
        remapTabIndexAfterMobilityVisibilityChange(
          showingMobility: true,
          previousIndex: 0,
        ),
        0,
      );
      expect(
        remapTabIndexAfterMobilityVisibilityChange(
          showingMobility: true,
          previousIndex: 1,
        ),
        2,
      );
    });
  });
}
