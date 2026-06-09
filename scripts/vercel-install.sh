#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FLUTTER_VERSION="${FLUTTER_VERSION:-3.35.6}"
FLUTTER_HOME="${ROOT}/.flutter_sdk"
export FLUTTER_HOME
export PATH="${FLUTTER_HOME}/bin:${PATH}"
export PUB_CACHE="${ROOT}/.pub-cache"

if [[ ! -x "${FLUTTER_HOME}/bin/flutter" ]]; then
  echo "Installing Flutter ${FLUTTER_VERSION} (cold start)..."
  git clone https://github.com/flutter/flutter.git -b "${FLUTTER_VERSION}" --depth 1 "${FLUTTER_HOME}"
  flutter config --enable-web --no-analytics
  flutter precache --web
else
  echo "Reusing cached Flutter SDK at ${FLUTTER_HOME}"
fi

flutter --version
flutter pub get
