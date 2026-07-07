import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:powercoach_studio/features/integrations/hevy/data/hevy_api_client.dart';
import 'package:powercoach_studio/features/integrations/hevy/data/hevy_api_models.dart';
import 'package:powercoach_studio/features/integrations/hevy/data/hevy_settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dio _dioWithInterceptor(Interceptor interceptor) {
  final dio = Dio(
    BaseOptions(baseUrl: 'https://api.hevyapp.com'),
  );
  dio.interceptors.add(interceptor);
  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SettingsPrefsKeys.hevyApiKey: 'test-api-key',
    });
  });

  group('HevyApiClient', () {
    test('throws when API key is not configured', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final client = HevyApiClient(settings: HevySettingsStore.instance);

      expect(
        () => client.fetchAllExerciseTemplates(),
        throwsA(
          isA<HevyApiException>().having(
            (e) => e.message,
            'message',
            'Hevy API key not configured',
          ),
        ),
      );
    });

    test('fetchAllExerciseTemplates parses paginated response', () async {
      final dio = _dioWithInterceptor(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers['api-key'], 'test-api-key');
            expect(options.queryParameters['page'], 1);
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'page_count': 1,
                  'exercise_templates': [
                    {'id': 'ex-1', 'title': 'Bench Press'},
                  ],
                },
              ),
            );
          },
        ),
      );

      final client = HevyApiClient(
        dio: dio,
        settings: HevySettingsStore.instance,
      );
      final templates = await client.fetchAllExerciseTemplates();

      expect(templates, hasLength(1));
      expect(templates.first.id, 'ex-1');
      expect(templates.first.title, 'Bench Press');
    });

    test('createRoutine posts JSON body with api-key header', () async {
      Map<String, dynamic>? capturedBody;
      final dio = _dioWithInterceptor(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedBody = options.data as Map<String, dynamic>?;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {'id': 'routine-1'},
              ),
            );
          },
        ),
      );

      final client = HevyApiClient(
        dio: dio,
        settings: HevySettingsStore.instance,
      );
      final result = await client.createRoutine({'title': 'Push Day'});

      expect(capturedBody?['title'], 'Push Day');
      expect(result['id'], 'routine-1');
    });

    test('handleDioError maps DioException to HevyApiException', () {
      expect(
        () => HevyApiClient.handleDioError(
          DioException(
            requestOptions: RequestOptions(path: '/v1/routines'),
            response: Response(
              requestOptions: RequestOptions(path: '/v1/routines'),
              statusCode: 401,
              data: 'Unauthorized',
            ),
          ),
        ),
        throwsA(
          isA<HevyApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });
}
