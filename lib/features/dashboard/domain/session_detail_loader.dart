import '../../customers/data/customer_repository.dart';
import '../../workouts/data/workout_plan_repository.dart';
import 'plan_calendar_event.dart';

class SessionDetailSnapshot {
  const SessionDetailSnapshot({
    required this.event,
    required this.exerciseCount,
    required this.phase,
  });

  final PlanCalendarEvent event;
  final int exerciseCount;
  final String? phase;
}

class SessionDetailLoader {
  SessionDetailLoader({
    WorkoutPlanRepository? workoutPlanRepository,
    CustomerRepository? customerRepository,
  }) : _workoutPlanRepository =
           workoutPlanRepository ?? WorkoutPlanRepository(),
       _customerRepository = customerRepository ?? CustomerRepository();

  final WorkoutPlanRepository _workoutPlanRepository;
  final CustomerRepository _customerRepository;

  Future<SessionDetailSnapshot?> load({
    required String customerId,
    required String planId,
    required int weekIndex,
    required int dayIndex,
    DateTime? explicitDate,
    required String unknownClientLabel,
    required String untitledProgramLabel,
  }) async {
    if (weekIndex < 0 || dayIndex < 0) return null;
    final plan = await _workoutPlanRepository.getById(planId);
    if (plan == null) return null;
    final routine = planDataToRoutine(plan.planData);
    if (weekIndex >= routine.weeks.length) return null;
    final week = routine.weeks[weekIndex];
    if (dayIndex >= week.days.length) return null;
    final day = week.days[dayIndex];

    String customerName = unknownClientLabel;
    try {
      final customer = await _customerRepository.getById(customerId);
      if (customer != null && customer.name.trim().isNotEmpty) {
        customerName = customer.name;
      }
    } catch (_) {}

    final programName = plan.name.trim().isEmpty
        ? untitledProgramLabel
        : plan.name.trim();
    final sessionLabel = day.name.trim().isEmpty
        ? 'W${weekIndex + 1} D${dayIndex + 1}'
        : day.name.trim();
    final eventDate =
        explicitDate ??
        planSessionDate(
          startDate: routine.startDate ?? DateTime.now(),
          weekIndex: weekIndex,
          dayIndex: dayIndex,
          scheduledWeekday: day.scheduledWeekday,
        );
    final event = PlanCalendarEvent(
      day: calendarDayOnly(eventDate),
      customerId: customerId,
      planId: plan.id,
      customerName: customerName,
      programName: programName,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      sessionLabel: sessionLabel,
      status: planSessionStatus(
        completionByKey: routine.sessionCompletionByKey,
        skippedByKey: routine.sessionSkippedByKey,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
      ),
    );
    return SessionDetailSnapshot(
      event: event,
      exerciseCount: day.exercises.length,
      phase: plan.phase,
    );
  }
}
