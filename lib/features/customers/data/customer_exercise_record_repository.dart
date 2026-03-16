import '../../../core/network/gymblog_api_client.dart';
import 'models/customer_exercise_record.dart';

/// Fetches and persists customer exercise records via GymBlog.API.
/// GET/POST/PUT/DELETE under /api/customers/{customerId}/exercise-records.
class CustomerExerciseRecordRepository {
  CustomerExerciseRecordRepository() : _api = GymBlogApiClient();

  final GymBlogApiClient _api;

  Future<List<CustomerExerciseRecord>> getByCustomerId(
    String customerId, {
    String? customExerciseId,
  }) async {
    final query = customExerciseId != null && customExerciseId.isNotEmpty
        ? '?customExerciseId=$customExerciseId'
        : '';
    final list = await _api.getList(
      '/api/customers/$customerId/exercise-records$query',
    );
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => CustomerExerciseRecord.fromJson(e))
        .toList();
  }

  Future<CustomerExerciseRecord?> getById(
    String customerId,
    String recordId,
  ) async {
    try {
      final data = await _api.get(
        '/api/customers/$customerId/exercise-records/$recordId',
      );
      return CustomerExerciseRecord.fromJson(data);
    } on GymBlogApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<CustomerExerciseRecord> create(
    String customerId,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.post(
      '/api/customers/$customerId/exercise-records',
      body,
    );
    return CustomerExerciseRecord.fromJson(data);
  }

  Future<CustomerExerciseRecord> update(
    String customerId,
    String recordId,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.put(
      '/api/customers/$customerId/exercise-records/$recordId',
      body,
    );
    return CustomerExerciseRecord.fromJson(data);
  }

  Future<void> delete(String customerId, String recordId) async {
    await _api.delete(
      '/api/customers/$customerId/exercise-records/$recordId',
    );
  }
}
