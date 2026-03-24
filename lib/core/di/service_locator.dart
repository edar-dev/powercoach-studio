import 'package:get_it/get_it.dart';

import '../network/gymblog_api_client.dart';

final GetIt getIt = GetIt.instance;

/// Registers app-wide singletons. Call from [main] before [SyncOrchestrator] and [runApp].
void configureDependencies() {
  if (!getIt.isRegistered<GymBlogApiClient>()) {
    getIt.registerLazySingleton<GymBlogApiClient>(() => GymBlogApiClient());
  }
}
