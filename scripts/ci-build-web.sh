#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -z "${SUPABASE_URL:-}" && -f .vercel/.env.production.local ]]; then
  echo "Loading production env from vercel pull..."
  set -a
  # shellcheck disable=SC1091
  source .vercel/.env.production.local
  set +a
fi

if [[ ! -f web/sqlite3.wasm ]]; then
  curl -fsSL -o web/sqlite3.wasm \
    "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm"
fi
if [[ ! -f web/drift_worker.js ]]; then
  curl -fsSL -o web/drift_worker.js \
    "https://github.com/simolus3/drift/releases/download/drift-2.31.0/drift_worker.js"
fi

cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL:-}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}
GYMBLOG_API_URL=${GYMBLOG_API_URL:-}
SENTRY_DSN=${SENTRY_DSN:-}
SENTRY_ENVIRONMENT=${SENTRY_ENVIRONMENT:-production}
EOF

APP_VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)"

# pub get runs in Setup Flutter (subosito/flutter-action cache step).
flutter build web --release --no-pub --no-wasm-dry-run --dart-define="APP_VERSION=${APP_VERSION}"
