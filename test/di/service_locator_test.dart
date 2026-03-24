import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/di/service_locator.dart';
import 'package:powercoach_studio/core/network/gymblog_api_client.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(
      fileName: '.env.missing.for.tests',
      isOptional: true,
      mergeWith: {'GYMBLOG_API_URL': 'http://localhost:5999'},
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('configureDependencies registers a single GymBlogApiClient', () {
    configureDependencies();
    final a = getIt<GymBlogApiClient>();
    final b = getIt<GymBlogApiClient>();
    expect(identical(a, b), isTrue);
  });
}
