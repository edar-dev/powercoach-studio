import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/locale/app_locale_controller.dart';
import 'package:powercoach_studio/core/routing/app_routes.dart';
import 'package:powercoach_studio/core/routing/root_navigator_key.dart';
import 'package:powercoach_studio/core/routing/route_redirect.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

late final GoRouter appGoRouter;

void configureAppRouter() {
  appGoRouter = GoRouter(
    navigatorKey: appRootNavigatorKey,
    initialLocation: '/',
    observers:
        kReleaseMode ? [SentryNavigatorObserver()] : const <NavigatorObserver>[],
    refreshListenable: SupabaseBootstrap.refreshTick,
    redirect: (context, state) => resolveAppRouteRedirect(state),
    routes: buildAppRoutes(),
  );
}

class PowerCoachStudioApp extends StatelessWidget {
  const PowerCoachStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLocaleController.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'PowerCoach Studio',
          debugShowCheckedModeBanner: false,
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: AppLocaleController.instance.locale,
          supportedLocales: const [
            Locale('it'),
            Locale('en'),
          ],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeResolutionCallback: (locale, supported) {
            if (locale != null) {
              for (final s in supported) {
                if (s.languageCode == locale.languageCode) return s;
              }
            }
            return const Locale('it');
          },
          routerConfig: appGoRouter,
        );
      },
    );
  }
}
