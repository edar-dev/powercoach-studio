#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -d build/web ]]; then
  echo "build/web not found. Run ci-build-web.sh first." >&2
  exit 1
fi

rm -rf .vercel/output
mkdir -p .vercel/output/static
cp -r build/web/. .vercel/output/static/

cat > .vercel/output/config.json <<'EOF'
{
  "version": 3,
  "routes": [
    { "handle": "filesystem" },
    { "src": "/(.*)", "dest": "/index.html" }
  ],
  "overrides": {
    "sqlite3.wasm": {
      "contentType": "application/wasm"
    },
    "drift_worker.js": {
      "contentType": "application/javascript"
    }
  }
}
EOF

echo "Packaged prebuilt output at .vercel/output ($(du -sh .vercel/output/static | awk '{print $1}') static)"
