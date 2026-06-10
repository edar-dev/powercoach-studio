import 'package:go_router/go_router.dart';

/// Must be initialized before [GoRouter] is constructed (import this library
/// before `app.dart` in `main.dart`).
void configureGoRouterPlatformOptions() {
  GoRouter.optionURLReflectsImperativeAPIs = true;
}

final bool goRouterOptionsConfigured = (() {
  configureGoRouterPlatformOptions();
  return true;
})();
