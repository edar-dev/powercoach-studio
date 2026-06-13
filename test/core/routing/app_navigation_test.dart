import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';

void main() {
  test('customer workout editor paths are customer-scoped', () {
    expect(
      customerWorkoutEditorPath('cust-1'),
      '/customers/cust-1/workouts/new',
    );
    expect(
      customerWorkoutEditorPath('cust-1', planId: 'plan-9'),
      '/customers/cust-1/workouts/plan-9',
    );
    expect(customerWorkoutsPath('cust-1'), '/customers/cust-1/workouts');
    expect(customerPath('cust-1'), '/customers/cust-1');
  });

  test('customer workout editor path supports session deep-link query', () {
    expect(
      customerWorkoutEditorPath(
        'cust-1',
        planId: 'plan-9',
        weekIndex: 2,
        dayIndex: 4,
      ),
      '/customers/cust-1/workouts/plan-9?week=2&day=4',
    );
  });
}
