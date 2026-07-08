import '../../exercise_library/data/custom_exercise_item.dart';
import '../../exercise_library/data/custom_exercise_repository.dart';
import '../../workouts/data/workout_plan_api_model.dart';
import '../../workouts/data/workout_plan_repository.dart';
import '../../workouts/domain/session_execution_service.dart';
import '../../workouts/domain/workout_plan_list_helpers.dart';
import '../data/customer_exercise_record_repository.dart';
import '../data/customer_measurement_repository.dart';
import '../data/customer_notes_repository.dart';
import '../data/customer_repository.dart';
import '../data/models/customer.dart';
import '../data/models/customer_exercise_record.dart';
import '../data/models/customer_measurement.dart';
import '../domain/customer_progress_metrics.dart';

/// Repository-backed reads for [CustomerDetailScreen].
class CustomerDetailDataLoader {
  CustomerDetailDataLoader({
    CustomerRepository? customerRepo,
    CustomerMeasurementRepository? measurementRepo,
    CustomerNotesRepository? notesRepo,
    CustomerExerciseRecordRepository? recordRepo,
    CustomExerciseRepository? exerciseRepo,
    WorkoutPlanRepository? planRepo,
    SessionExecutionService? executionService,
  })  : _customerRepo = customerRepo ?? CustomerRepository(),
        _measurementRepo = measurementRepo ?? CustomerMeasurementRepository(),
        _notesRepo = notesRepo ?? CustomerNotesRepository(),
        _recordRepo = recordRepo ?? CustomerExerciseRecordRepository(),
        _exerciseRepo = exerciseRepo ?? CustomExerciseRepository(),
        _planRepo = planRepo ?? WorkoutPlanRepository(),
        _executionService = executionService ?? SessionExecutionService();

  final CustomerRepository _customerRepo;
  final CustomerMeasurementRepository _measurementRepo;
  final CustomerNotesRepository _notesRepo;
  final CustomerExerciseRecordRepository _recordRepo;
  final CustomExerciseRepository _exerciseRepo;
  final WorkoutPlanRepository _planRepo;
  final SessionExecutionService _executionService;

  Future<Customer?> loadCustomer(String customerId) =>
      _customerRepo.getById(customerId);

  Future<List<CustomerMeasurement>> loadMeasurements(String customerId) async {
    final list = await _measurementRepo.getByCustomerId(customerId);
    list.sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
    return list;
  }

  Future<int> loadUnreadNotesCount(String customerId) =>
      _notesRepo.unreadCount(customerId);

  Future<List<WorkoutPlanApiModel>> loadWorkoutPlans(String customerId) async {
    final list = await _planRepo.getByCustomerId(customerId);
    return sortWorkoutPlans(list, WorkoutPlanSort.startDateDesc);
  }

  Future<({List<CustomerExerciseRecord> records, Map<String, String> names})>
      loadRecords(String customerId) async {
    final records = await _recordRepo.getByCustomerId(customerId);
    final names = await buildExerciseNameMap();
    return (records: records, names: names);
  }

  Future<CustomerProgressSnapshot> loadProgress({
    required String customerId,
    required List<WorkoutPlanApiModel> plans,
    required List<CustomerExerciseRecord> records,
  }) async {
    final allExecutions = await _executionService.listAll();
    return CustomerProgressMetrics.build(
      customerId: customerId,
      plans: plans,
      exerciseRecords: records,
      allExecutions: allExecutions,
    );
  }

  Future<Map<String, String>> buildExerciseNameMap() async {
    final roots = await _exerciseRepo.getTree();
    final namesById = <String, String>{};
    void visit(CustomExerciseItem node, String? parentPath) {
      final displayName =
          parentPath == null ? node.name : '$parentPath › ${node.name}';
      namesById[node.id] = displayName;
      for (final child in node.children) {
        visit(child, displayName);
      }
    }

    for (final root in roots) {
      visit(root, null);
    }
    return namesById;
  }
}
