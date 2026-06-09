#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.35.6}"
FLUTTER_HOME="${FLUTTER_HOME:-/tmp/flutter}"

if [[ ! -d "${FLUTTER_HOME}/bin" ]]; then
  git clone https://github.com/flutter/flutter.git -b "${FLUTTER_VERSION}" --depth 1 "${FLUTTER_HOME}"
fi

export PATH="${FLUTTER_HOME}/bin:${PATH}"
flutter --version
flutter config --enable-web
flutter precache --web

# Drift web assets (versions must match pubspec.lock: drift 2.31.0, sqlite3 2.9.4)
curl -fsSL -o web/sqlite3.wasm \
  "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm"
curl -fsSL -o web/drift_worker.js \
  "https://github.com/simolus3/drift/releases/download/drift-2.31.0/drift_worker.js"

cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL:-}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}
GYMBLOG_API_URL=${GYMBLOG_API_URL:-}
SENTRY_DSN=${SENTRY_DSN:-}
SENTRY_ENVIRONMENT=${SENTRY_ENVIRONMENT:-production}
EOF

APP_VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)"

flutter pub get
flutter build web --release --dart-define="APP_VERSION=${APP_VERSION}"
