import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'app_platform_io.dart';

Future<void> applySqliteAndroidWorkaroundIfNeeded() async {
  if (isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }
}
