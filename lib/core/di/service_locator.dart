import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Registers app-wide singletons. Call from [main] before [runApp].
void configureDependencies() {
  // Local-only mode does not require network singletons.
}
