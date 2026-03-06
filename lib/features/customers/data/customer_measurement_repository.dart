import '../../../core/network/gymblog_api_client.dart';
import 'models/customer_measurement.dart';

/// Fetches and persists customer measurements via GymBlog.API.
/// GET/POST/PUT/DELETE under /api/customers/{customerId}/measurements.
class CustomerMeasurementRepository {
  CustomerMeasurementRepository() : _api = GymBlogApiClient();

  final GymBlogApiClient _api;

  Future<List<CustomerMeasurement>> getByCustomerId(String customerId) async {
    final list = await _api.getList('/api/customers/$customerId/measurements');
    return list
        .map((e) => CustomerMeasurement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerMeasurement?> getById(String customerId, String measurementId) async {
    try {
      final data = await _api.get('/api/customers/$customerId/measurements/$measurementId');
      return CustomerMeasurement.fromJson(data);
    } on GymBlogApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<CustomerMeasurement> create(String customerId, Map<String, dynamic> body) async {
    final data = await _api.post('/api/customers/$customerId/measurements', body);
    return CustomerMeasurement.fromJson(data);
  }

  Future<CustomerMeasurement> update(
    String customerId,
    String measurementId,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.put(
      '/api/customers/$customerId/measurements/$measurementId',
      body,
    );
    return CustomerMeasurement.fromJson(data);
  }

  Future<void> delete(String customerId, String measurementId) async {
    await _api.delete('/api/customers/$customerId/measurements/$measurementId');
  }
}
