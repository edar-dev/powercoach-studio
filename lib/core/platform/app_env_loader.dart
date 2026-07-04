import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Bundled env file declared in [pubspec.yaml] assets.
///
/// CI build scripts overwrite this file with real credentials in the build
/// workspace. Locally, copy [.env.example] and add your Supabase keys, or run
/// `bash scripts/ensure-env.sh` to create a gitignored `.env` and sync it here
/// before `flutter run`.
const appEnvAssetPath = '.env.example';

Future<void> loadAppEnv() async {
  await dotenv.load(fileName: appEnvAssetPath);
}
