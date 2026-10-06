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

# PostHog first-party proxy routes MUST come before filesystem + SPA fallback.
# Production uses `vercel deploy --prebuilt`, which ignores vercel.json rewrites.
cat > .vercel/output/config.json <<'EOF'
{
  "version": 3,
  "routes": [
    {
      "src": "/pcs-ph/static/(.*)",
      "dest": "https://eu-assets.i.posthog.com/static/$1"
    },
    {
      "src": "/pcs-ph/array/(.*)",
      "dest": "https://eu-assets.i.posthog.com/array/$1"
    },
    {
      "src": "/pcs-ph/(.*)",
      "dest": "https://eu.i.posthog.com/$1"
    },
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
