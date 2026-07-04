#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example."
  echo "Add your Supabase credentials to .env, then run this script again."
  exit 0
fi

cp .env .env.example
echo "Synced .env -> .env.example for the Flutter asset bundle."
echo "Do not commit .env.example if it contains real secrets."
