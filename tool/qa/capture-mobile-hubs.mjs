#!/usr/bin/env node
/**
 * Phase C — optional mobile viewport screenshot capture.
 *
 * Auth: Supabase password grant → inject `sb-<ref>-auth-token` into localStorage
 * before navigation (CanvasKit paints CTAs on <canvas>; DOM login clicks fail).
 *
 * Mode: capture + CI artifact (no hard pixel-diff). CanvasKit antialiasing,
 * font metrics, and modal overlays make golden pixel thresholds brittle.
 * Committed `baselines/` are reference shots for manual / opportunistic review;
 * refresh with `--update-baselines`.
 *
 * Credentials: NAV_QA_EMAIL / NAV_QA_PASSWORD from env (never commit secrets).
 */

import { chromium } from 'playwright';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const BASELINES_DIR = path.join(__dirname, 'baselines');
const UPDATE_BASELINES = process.argv.includes('--update-baselines');

/** Authenticated hubs useful for shell / bottom-bar visual QA. */
const HUBS = [
  { id: 'dashboard', route: '/dashboard', label: 'Today / Dashboard' },
  { id: 'customers', route: '/customers', label: 'Clients' },
  { id: 'builder', route: '/workouts/builder', label: 'Workout builder' },
  { id: 'settings', route: '/settings', label: 'Settings shell' },
];

function fail(message) {
  console.error(`[qa] ${message}`);
  process.exit(1);
}

function authStorageKey(supabaseUrl) {
  let host;
  try {
    host = new URL(supabaseUrl).hostname;
  } catch {
    fail(`Invalid SUPABASE_URL: ${supabaseUrl}`);
  }
  const ref = host.split('.')[0];
  if (!ref) fail(`Could not derive project ref from ${supabaseUrl}`);
  return `sb-${ref}-auth-token`;
}

function loadDotEnvIfPresent() {
  const candidates = [
    path.join(__dirname, '.env'),
    path.join(__dirname, '../../.env'),
  ];
  for (const file of candidates) {
    if (!fs.existsSync(file)) continue;
    const text = fs.readFileSync(file, 'utf8');
    for (const line of text.split('\n')) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;
      const eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      const key = trimmed.slice(0, eq).trim();
      let value = trimmed.slice(eq + 1).trim();
      if (
        (value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))
      ) {
        value = value.slice(1, -1);
      }
      if (process.env[key] === undefined) process.env[key] = value;
    }
  }
}

async function waitForFlutterReady(page) {
  // Playwright signature: waitForFunction(fn, arg, options) — options must be 3rd.
  await page.waitForFunction(
    () => {
      const body = document.body;
      if (!body) return false;
      return (
        body.getAttribute('flt-renderer') === 'canvaskit' ||
        !!document.querySelector('flt-glass-pane, canvas, flt-scene-host')
      );
    },
    null,
    { timeout: 120_000 },
  );
  // Let first frame + auth restore settle (DWDS never reaches networkidle).
  await page.waitForTimeout(3500);
}

async function enableFlutterSemantics(page) {
  try {
    const placeholder = page.locator('flt-semantics-placeholder').first();
    if (await placeholder.count()) {
      await placeholder.click({ timeout: 2000, force: true });
      await page.waitForTimeout(500);
    }
  } catch {
    // Semantics already enabled or unavailable.
  }
}

async function tryDismissCloudRecovery(page) {
  // Italian UI default; English fallback if locale differs.
  const labels = ['Non ora', 'Not now'];
  await enableFlutterSemantics(page);

  for (const label of labels) {
    try {
      const locator = page.getByRole('button', { name: label }).first();
      if (await locator.isVisible({ timeout: 2000 })) {
        await locator.click({ timeout: 2000 });
        await page.waitForTimeout(800);
        console.log(`[qa] Dismissed cloud recovery via role button "${label}"`);
        return;
      }
    } catch {
      // Fall through to aria-label scan.
    }
  }

  try {
    const clicked = await page.evaluate((labelsInner) => {
      const root = document.querySelector('flt-semantics-host') || document.body;
      const nodes = root.querySelectorAll(
        '[aria-label], [role="button"], button, flt-semantics',
      );
      for (const node of nodes) {
        const text = (
          node.getAttribute('aria-label') ||
          node.textContent ||
          ''
        ).trim();
        if (labelsInner.includes(text)) {
          node.click();
          return text;
        }
      }
      return null;
    }, labels);
    if (clicked) {
      await page.waitForTimeout(800);
      console.log(`[qa] Dismissed cloud recovery via semantics "${clicked}"`);
      return;
    }
  } catch {
    // ignore
  }

  console.warn(
    '[qa] Could not dismiss cloud recovery dialog (may appear in screenshot)',
  );
}

async function captureHub(page, hub, { baseUrl, outDir }) {
  const target = `${baseUrl}${hub.route}`;
  console.log(`[qa] Capturing ${hub.label} → ${target}`);
  await page.goto(target, { waitUntil: 'load', timeout: 120_000 });
  await waitForFlutterReady(page);
  if (hub.id === 'dashboard') {
    await tryDismissCloudRecovery(page);
  }
  // Extra settle for shell NavigationBar / empty states.
  await page.waitForTimeout(1500);

  const fileName = `mobile-${hub.id}.png`;
  const outPath = path.join(outDir, fileName);
  await page.screenshot({ path: outPath, fullPage: false });
  console.log(`[qa] Wrote ${outPath}`);

  if (UPDATE_BASELINES) {
    fs.mkdirSync(BASELINES_DIR, { recursive: true });
    const baselinePath = path.join(BASELINES_DIR, fileName);
    fs.copyFileSync(outPath, baselinePath);
    console.log(`[qa] Updated baseline ${baselinePath}`);
  } else {
    const baselinePath = path.join(BASELINES_DIR, fileName);
    if (fs.existsSync(baselinePath)) {
      const artifactStat = fs.statSync(outPath);
      const baselineStat = fs.statSync(baselinePath);
      const delta = Math.abs(artifactStat.size - baselineStat.size);
      const rel = baselineStat.size === 0 ? 1 : delta / baselineStat.size;
      // Soft advisory only — size drift can flag blank/error pages without
      // brittle pixel comparison on CanvasKit.
      if (rel > 0.35) {
        console.warn(
          `[qa] Advisory: ${fileName} size differs from baseline by ${(rel * 100).toFixed(1)}% (artifact ${artifactStat.size}B vs baseline ${baselineStat.size}B)`,
        );
      } else {
        console.log(
          `[qa] Baseline present for ${fileName} (size delta ${(rel * 100).toFixed(1)}%)`,
        );
      }
    } else {
      console.warn(
        `[qa] No baseline for ${fileName} — run with --update-baselines after a good capture`,
      );
    }
  }

  return outPath;
}

async function passwordGrant({ supabaseUrl, anonKey, email, password }) {
  const url = `${supabaseUrl}/auth/v1/token?grant_type=password`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      apikey: anonKey,
      Authorization: `Bearer ${anonKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    fail(
      `Password grant failed (${res.status}): ${body.error_description || body.msg || JSON.stringify(body)}`,
    );
  }
  if (!body.access_token || !body.refresh_token || !body.user) {
    fail('Password grant response missing access_token / refresh_token / user');
  }
  const expiresAt =
    body.expires_at ??
    Math.floor(Date.now() / 1000) + Number(body.expires_in || 3600);
  return {
    access_token: body.access_token,
    refresh_token: body.refresh_token,
    expires_in: body.expires_in,
    expires_at: expiresAt,
    token_type: body.token_type || 'bearer',
    user: body.user,
  };
}

async function main() {
  loadDotEnvIfPresent();

  const baseUrl = (process.env.QA_BASE_URL || 'http://127.0.0.1:8080').replace(
    /\/$/,
    '',
  );
  const viewport = {
    width: Number(process.env.QA_VIEWPORT_WIDTH || 390),
    height: Number(process.env.QA_VIEWPORT_HEIGHT || 844),
  };
  const outDir = process.env.QA_OUT_DIR
    ? path.resolve(process.env.QA_OUT_DIR)
    : path.join(__dirname, 'artifacts');
  const email = process.env.NAV_QA_EMAIL || 'nav.qa@powerstudio.com';
  const password = process.env.NAV_QA_PASSWORD;
  const supabaseUrl = (process.env.SUPABASE_URL || '').replace(/\/$/, '');
  const anonKey = process.env.SUPABASE_ANON_KEY || '';

  if (!supabaseUrl || !anonKey) {
    fail('SUPABASE_URL and SUPABASE_ANON_KEY are required (env or repo .env)');
  }
  if (!password) {
    fail(
      'NAV_QA_PASSWORD is required (do not commit secrets; set env from project preferences)',
    );
  }

  const storageKey = authStorageKey(supabaseUrl);
  console.log(`[qa] Base URL: ${baseUrl}`);
  console.log(`[qa] Viewport: ${viewport.width}×${viewport.height}`);
  console.log(`[qa] Auth storage key: ${storageKey}`);
  console.log(`[qa] Email: ${email}`);

  fs.mkdirSync(outDir, { recursive: true });

  const session = await passwordGrant({
    supabaseUrl,
    anonKey,
    email,
    password,
  });
  console.log(`[qa] Session user: ${session.user?.email || '?'}`);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport,
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
    userAgent:
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
  });

  await context.addInitScript(
    ({ key, value }) => {
      window.localStorage.setItem(key, JSON.stringify(value));
    },
    { key: storageKey, value: session },
  );

  const page = await context.newPage();
  const written = [];
  try {
    for (const hub of HUBS) {
      written.push(await captureHub(page, hub, { baseUrl, outDir }));
    }
  } finally {
    await browser.close();
  }

  const manifest = {
    capturedAt: new Date().toISOString(),
    baseUrl,
    viewport,
    hubs: HUBS.map((h) => h.id),
    files: written.map((p) => path.basename(p)),
    mode: UPDATE_BASELINES ? 'update-baselines' : 'capture',
    notes:
      'Capture + artifact mode (no hard pixel-diff). Complements Phase A/B; CanvasKit DOM clicks remain weak.',
  };
  fs.writeFileSync(
    path.join(outDir, 'manifest.json'),
    `${JSON.stringify(manifest, null, 2)}\n`,
  );
  console.log(`[qa] Done — ${written.length} screenshots in ${outDir}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
