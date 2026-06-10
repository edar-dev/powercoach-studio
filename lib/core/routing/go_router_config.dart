import 'package:go_router/go_router.dart';

/// Must be initialized before [GoRouter] is constructed (import this library
/// before `app.dart` in `main.dart`).
///
/// Without this, every [GoRouter.push] on web keeps the previous URL in the
/// address bar (default since go_router 8.0). That breaks refresh/deep links
/// for all screens navigated via push — customers, workouts, settings, etc.
void configureGoRouterPlatformOptions() {
  GoRouter.optionURLReflectsImperativeAPIs = true;
}

final bool goRouterOptionsConfigured = (() {
  configureGoRouterPlatformOptions();
  return true;
})();
