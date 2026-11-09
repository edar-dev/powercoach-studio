#!/usr/bin/env bash
# Probe production web + Supabase Auth health (no service-role keys).
# Exit 0 when all checks pass; non-zero on any failure.
set -euo pipefail

WEB_URL="${UPTIME_WEB_URL:-https://powercoach-studio.vercel.app}"
SUPABASE_URL="${SUPABASE_URL:-https://owtkzvphhapjdfibmebl.supabase.co}"
# Strip trailing slash for consistent path joins.
WEB_URL="${WEB_URL%/}"
SUPABASE_URL="${SUPABASE_URL%/}"

TIMEOUT_SECS="${UPTIME_TIMEOUT_SECS:-20}"
CURL=(curl --proto '=https' --tlsv1.2 -fsS --max-time "$TIMEOUT_SECS")

failures=0

pass() { printf 'PASS  %s\n' "$1"; }
fail() {
  printf 'FAIL  %s\n' "$1" >&2
  failures=$((failures + 1))
}

check_web() {
  local body http
  local tmp
  tmp="$(mktemp)"
  # Do not use -f here: we want the status code even on non-2xx.
  http="$(curl --proto '=https' --tlsv1.2 -sS --max-time "$TIMEOUT_SECS" \
    -o "$tmp" -w '%{http_code}' "$WEB_URL/" || true)"
  body="$(cat "$tmp")"
  rm -f "$tmp"

  if [[ "$http" != "200" ]]; then
    fail "web homepage HTTP $http (expected 200) — $WEB_URL/"
    return
  fi
  if ! grep -q 'PowerCoach Studio' <<<"$body"; then
    fail "web homepage missing title marker 'PowerCoach Studio'"
    return
  fi
  if ! grep -q 'flutter_bootstrap.js' <<<"$body"; then
    fail "web homepage missing flutter_bootstrap.js (SPA shell incomplete?)"
    return
  fi
  pass "web homepage $WEB_URL/ (200 + shell markers)"
}

check_supabase_auth() {
  local body http
  local url="$SUPABASE_URL/auth/v1/health"
  local tmp
  tmp="$(mktemp)"

  if [[ -n "${SUPABASE_ANON_KEY:-}" ]]; then
    http="$(curl --proto '=https' --tlsv1.2 -sS --max-time "$TIMEOUT_SECS" \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
      -o "$tmp" -w '%{http_code}' "$url" || true)"
    body="$(cat "$tmp")"
    rm -f "$tmp"
    if [[ "$http" != "200" ]]; then
      fail "supabase auth health HTTP $http (expected 200) — $url"
      return
    fi
    if ! grep -qi 'GoTrue\|version' <<<"$body"; then
      fail "supabase auth health body missing GoTrue/version marker"
      return
    fi
    pass "supabase auth health $url (200)"
    return
  fi

  # Secretless fallback: gateway must answer with the standard missing-apikey 401.
  http="$(curl --proto '=https' --tlsv1.2 -sS --max-time "$TIMEOUT_SECS" \
    -o "$tmp" -w '%{http_code}' "$url" || true)"
  body="$(cat "$tmp")"
  rm -f "$tmp"
  if [[ "$http" != "401" ]]; then
    fail "supabase auth (no key) HTTP $http (expected 401 gateway) — $url"
    return
  fi
  if ! grep -qi 'API key' <<<"$body"; then
    fail "supabase auth (no key) unexpected body (gateway down or changed?)"
    return
  fi
  pass "supabase auth gateway $url (401 missing apikey — service reachable)"
  echo "NOTE: set SUPABASE_ANON_KEY for a full 200 GoTrue health probe" >&2
}

printf 'Uptime healthcheck\n'
printf '  WEB_URL=%s\n' "$WEB_URL"
printf '  SUPABASE_URL=%s\n' "$SUPABASE_URL"
printf '  anon_key=%s\n' "$([[ -n "${SUPABASE_ANON_KEY:-}" ]] && echo set || echo unset)"
echo

check_web
check_supabase_auth

if [[ "$failures" -gt 0 ]]; then
  echo
  printf 'RESULT: %s check(s) failed\n' "$failures" >&2
  exit 1
fi

echo
echo 'RESULT: all checks passed'
exit 0
