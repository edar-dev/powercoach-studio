import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('powercoach-studio: .env not found; Supabase may not work.');
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN']?.trim();
      if (options.dsn == null || options.dsn!.isEmpty) {
        options.dsn = null;
        debugPrint('powercoach-studio: SENTRY_DSN not set; Sentry disabled.');
      } else {
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
        options.enableAutoNativeBreadcrumbs = true;
        options.attachScreenshot = true;
        options.sendDefaultPii = false;
        options.environment =
            dotenv.env['SENTRY_ENVIRONMENT']?.trim() ?? 'development';
        options.release =
            'powercoach-studio@${const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')}';
      }
    },
    appRunner: () async {
      final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
      }

      runApp(SentryWidget(child: const PowerCoachStudioApp()));
    },
  );
}
