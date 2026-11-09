#!/usr/bin/env bash
# Upload Flutter debug symbols / web source maps to Sentry when CI secrets exist.
# No-op (exit 0) when SENTRY_AUTH_TOKEN / SENTRY_ORG / SENTRY_PROJECT are missing
# so opt-in DSN-only deploys keep working.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -z "${SENTRY_AUTH_TOKEN:-}" ]]; then
  echo "sentry-upload: SENTRY_AUTH_TOKEN unset — skipping symbol upload."
  exit 0
fi
if [[ -z "${SENTRY_ORG:-}" || -z "${SENTRY_PROJECT:-}" ]]; then
  echo "sentry-upload: SENTRY_ORG / SENTRY_PROJECT unset — skipping symbol upload."
  exit 0
fi

APP_VERSION="${APP_VERSION:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)}"
APP_BUILD="${APP_BUILD:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f2)}"
export SENTRY_RELEASE="${SENTRY_RELEASE:-powercoach-studio@${APP_VERSION}}"
export SENTRY_DIST="${SENTRY_DIST:-${APP_BUILD}}"
export SENTRY_ORG
export SENTRY_PROJECT
export SENTRY_AUTH_TOKEN

echo "sentry-upload: uploading artifacts for release=${SENTRY_RELEASE} dist=${SENTRY_DIST} org=${SENTRY_ORG} project=${SENTRY_PROJECT}"
dart run sentry_dart_plugin
