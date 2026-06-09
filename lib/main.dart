import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/di/service_locator.dart';
import 'package:powercoach_studio/core/locale/app_locale_controller.dart';
import 'package:powercoach_studio/core/notifications/notification_scheduler_service.dart';
import 'package:powercoach_studio/core/platform/sqlite_android_workaround.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';

Future<void> main() async {
  final startupWatch = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();
  _installDebugFrameTimingProbe();
  try {
    await dotenv.load(fileName: '.env');
    _logStartupStep('dotenv.load completed', startupWatch);
  } catch (_) {
    debugPrint('powercoach-studio: .env not found; Supabase may not work.');
    _logStartupStep('dotenv.load skipped (missing .env)', startupWatch);
  }

  final dsn = dotenv.env['SENTRY_DSN']?.trim();
  final useSentry = kReleaseMode && (dsn != null && dsn.isNotEmpty);

  if (useSentry) {
    _logStartupStep('Sentry init start', startupWatch);
    SentryWidgetsFlutterBinding.ensureInitialized();
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 1.0;
        options.enableAutoNativeBreadcrumbs = true;
        options.attachScreenshot = true;
        options.sendDefaultPii = false;
        options.environment =
            dotenv.env['SENTRY_ENVIRONMENT']?.trim() ?? 'development';
        options.release =
            'powercoach-studio@${const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')}';
      },
      appRunner: () {
        _logStartupStep('Sentry appRunner invoked', startupWatch);
        _runApp(wrapWithSentry: true);
      },
    );
  } else {
    if (kDebugMode) {
      debugPrint('powercoach-studio: Sentry disabled in debug mode.');
    } else if (kProfileMode) {
      debugPrint('powercoach-studio: Sentry disabled in profile mode.');
    } else {
      debugPrint('powercoach-studio: SENTRY_DSN not set; Sentry disabled.');
    }
    _runApp(wrapWithSentry: false);
    _logStartupStep('runApp invoked (no sentry)', startupWatch);
  }
}

void _runApp({required bool wrapWithSentry}) {
  if (wrapWithSentry) {
    runApp(SentryWidget(child: const _BootstrapApp()));
  } else {
    runApp(const _BootstrapApp());
  }
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  bool _ready = false;
  String? _error;
  final Stopwatch _bootstrapWatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _bootstrapWatch.start();
    _logStartupStep('bootstrap widget initState', _bootstrapWatch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logStartupStep('first frame rendered (bootstrap)', _bootstrapWatch);
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      _logStartupStep('bootstrap init start', _bootstrapWatch);
      await applySqliteAndroidWorkaroundIfNeeded();
      _logStartupStep('sqlite workaround step completed', _bootstrapWatch);

      final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
      SupabaseBootstrap.configure(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        _logStartupStep(
          'Supabase init deferred to background',
          _bootstrapWatch,
        );
      } else {
        _logStartupStep(
          'Supabase init unavailable (missing env)',
          _bootstrapWatch,
        );
      }

      configureDependencies();
      _logStartupStep('configureDependencies completed', _bootstrapWatch);

      await AppLocaleController.instance.load();
      _logStartupStep('locale controller loaded', _bootstrapWatch);

      await NotificationSchedulerService.instance.ensureInitialized();
      await NotificationSchedulerService.instance.syncWithNotificationPreference();
      _logStartupStep('local notifications synced', _bootstrapWatch);

      if (!mounted) return;
      setState(() {
        _ready = true;
      });
      _logStartupStep('bootstrap ready=true', _bootstrapWatch);
      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        unawaited(
          SupabaseBootstrap.ensureInitialized().then((_) {
            _logStartupStep(
              'Supabase background init completed',
              _bootstrapWatch,
            );
          }),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
      _logStartupStep('bootstrap error: $e', _bootstrapWatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const PowerCoachStudioApp();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Startup error: $_error',
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ),
    );
  }
}

void _logStartupStep(String label, Stopwatch watch) {
  if (kReleaseMode) return;
  final elapsedMs = watch.elapsedMilliseconds;
  final previousMs = _startupLastElapsedByWatch[watch] ?? 0;
  _startupLastElapsedByWatch[watch] = elapsedMs;
  final deltaMs = elapsedMs - previousMs;
  debugPrint('powercoach-startup: ${elapsedMs}ms (+${deltaMs}ms) - $label');
}

final Map<Stopwatch, int> _startupLastElapsedByWatch = <Stopwatch, int>{};

void _installDebugFrameTimingProbe() {
  if (!kDebugMode) return;

  const sampleFrames = 120;
  const frameBudgetMs = 16;
  var observedFrames = 0;
  var slowBuildFrames = 0;
  var slowRasterFrames = 0;

  late final TimingsCallback callback;
  callback = (timings) {
    for (final timing in timings) {
      observedFrames++;
      final buildMs = timing.buildDuration.inMilliseconds;
      final rasterMs = timing.rasterDuration.inMilliseconds;
      if (buildMs > frameBudgetMs) {
        slowBuildFrames++;
      }
      if (rasterMs > frameBudgetMs) {
        slowRasterFrames++;
      }

      if (observedFrames >= sampleFrames) {
        SchedulerBinding.instance.removeTimingsCallback(callback);
        debugPrint(
          'powercoach-startup-frame-probe: sampled=$observedFrames, '
          'slowBuild=$slowBuildFrames, slowRaster=$slowRasterFrames',
        );
        break;
      }
    }
  };

  SchedulerBinding.instance.addTimingsCallback(callback);
}
