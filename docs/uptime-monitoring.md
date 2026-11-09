# Uptime monitoring (web + Supabase)

Lightweight production probes for PowerCoach Studio — **no paid uptime SaaS required**.

| Target | Default URL | Probe |
|--------|-------------|-------|
| Vercel web | `https://powercoach-studio.vercel.app` | `GET /` → HTTP 200 + HTML markers (`PowerCoach Studio`, `flutter_bootstrap.js`) |
| Supabase Auth | `https://owtkzvphhapjdfibmebl.supabase.co` | `GET /auth/v1/health` with **anon** key → HTTP 200 + GoTrue body |

There is **no** dedicated `/health` SPA route (Vercel rewrites unknown paths to `index.html`). Homepage content checks are intentional.

**Never** use the Supabase **service role** key here. The workflow uses the same `SUPABASE_ANON_KEY` Actions secret as CI/CD (publishable). If the anon secret is missing, the script falls back to treating a gateway `401` “No API key” response as “Auth reachable.”

## In-repo automation

| Piece | Path |
|-------|------|
| Probe script | [`scripts/uptime-healthcheck.sh`](../scripts/uptime-healthcheck.sh) |
| Scheduled workflow | [`.github/workflows/uptime-healthcheck.yml`](../.github/workflows/uptime-healthcheck.yml) |

- **Schedule:** every 15 minutes (`cron: "*/15 * * * *"`) + manual **workflow_dispatch**
- **Alert (default):** open / comment a GitHub Issue titled `[uptime] Production healthcheck failing` with label `uptime`
- **Recovery:** next successful run comments and closes that issue
- **Optional Slack:** if repo secret `SLACK_WEBHOOK_URL` is set, POST a short failure message

Watchers of the repo also get **GitHub Actions failure emails** (per personal notification settings).

## Local dry-run

```bash
# Uses documented defaults; set anon key for full GoTrue 200 check
export SUPABASE_ANON_KEY='…'   # publishable / anon only
bash scripts/uptime-healthcheck.sh
```

Optional overrides:

```bash
export UPTIME_WEB_URL='https://powercoach-studio.vercel.app'
export SUPABASE_URL='https://owtkzvphhapjdfibmebl.supabase.co'
export UPTIME_TIMEOUT_SECS=20
```

## What Edoardo must enable (one-time)

Agents cannot flip GitHub UI toggles. On `edar-dev/powercoach-studio`:

1. **Actions secrets** (Settings → Secrets and variables → Actions) — usually already present for web deploy:
   - `SUPABASE_URL` — recommended (falls back to documented prod URL if unset)
   - `SUPABASE_ANON_KEY` — **recommended** for a real 200 Auth health probe
   - `SLACK_WEBHOOK_URL` — **optional** Incoming Webhook for Slack alerts
2. **Scheduled workflows / token permissions:**
   - Actions must be enabled for the repo
   - **Settings → Actions → General → Workflow permissions:** allow **Read and write** permissions for `GITHUB_TOKEN` (needed to open/close Issues). The workflow also declares `permissions: issues: write`.
   - After merge, open **Actions → Uptime Healthcheck → Run workflow** once to verify; confirm the schedule appears (GitHub disables schedules on forks and after ~60 days of inactivity on public repos)
3. **Notifications:** enable email (or mobile) for **Actions → Workflow runs** failures and/or **Issues** on this repo so downtime is noticeable without Slack. Watching the repo + “Notify me on Issues” is enough for the default GitHub Issue alert path.
4. **Optional repo variable:** `UPTIME_WEB_URL` if the production hostname changes (Settings → Secrets and variables → Actions → Variables).
5. **Label:** the workflow upserts label `uptime` on each run; no manual label create required unless org policy blocks label creation via `GITHUB_TOKEN`.

## Optional SaaS (not wired)

If you later want external ping without Actions minutes:

| Tool | Fit |
|------|-----|
| [UptimeRobot](https://uptimerobot.com/) free | HTTP(s) monitors on the same URLs; email/Slack |
| Better Stack / Better Uptime | Same idea; richer status pages |
| Vercel Monitoring / Speed Insights | Useful for performance; **not** a substitute for Supabase Auth reachability |

Prefer keeping the GitHub Actions probe as the source of truth so checks and alert docs stay in-repo.

## Related

- [vercel-web-deploy.md](vercel-web-deploy.md) — prod web deploy + secrets
- [quality-security.md](quality-security.md) — CI / human checklist
- `.env.example` — `SUPABASE_URL` documented for local/dev
