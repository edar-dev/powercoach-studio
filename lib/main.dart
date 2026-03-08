import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:powercoach_studio/core/network/gymblog_api_client.dart';
import 'package:powercoach_studio/core/network/persistent_api_cache.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('powercoach-studio: .env not found; Supabase may not work.');
  }

  final dsn = dotenv.env['SENTRY_DSN']?.trim();
  final useSentry = !kDebugMode && (dsn != null && dsn.isNotEmpty);

  if (useSentry) {
    SentryWidgetsFlutterBinding.ensureInitialized();
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
        options.enableAutoNativeBreadcrumbs = true;
        options.attachScreenshot = true;
        options.sendDefaultPii = false;
        options.environment =
            dotenv.env['SENTRY_ENVIRONMENT']?.trim() ?? 'development';
        options.release =
            'powercoach-studio@${const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')}';
      },
      appRunner: () => _runApp(wrapWithSentry: true),
    );
  } else {
    if (kDebugMode) {
      debugPrint('powercoach-studio: Sentry disabled in debug mode.');
    } else {
      debugPrint('powercoach-studio: SENTRY_DSN not set; Sentry disabled.');
    }
    await _runApp(wrapWithSentry: false);
  }
}

Future<void> _runApp({required bool wrapWithSentry}) async {
  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  await PersistentApiCache.restore(GymBlogApiClient.apiCache);

  if (wrapWithSentry) {
    runApp(SentryWidget(child: const PowerCoachStudioApp()));
  } else {
    runApp(const PowerCoachStudioApp());
  }
}
