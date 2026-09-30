# Code quality — SonarQube Cloud Free

PowerCoach Studio uses **[SonarQube Cloud Free](https://www.sonarsource.com/products/sonarcloud/)** (ex SonarCloud) for static analysis on pull requests and `main`. Dart is supported officially **via CI-based analysis only**. This is an **informational** quality signal: the CI job fails only if the scanner itself fails, not because the Sonar Quality Gate is red.

## Two analysis methods (do not run both)

| Method | Config file | Analyzes Dart? | Who runs it |
|--------|-------------|----------------|-------------|
| **CI-based** (preferred) | `sonar-project.properties` | Yes | GitHub Actions `sonar` job + `SONAR_TOKEN` |
| **Automatic Analysis** (GitHub App) | `.sonarcloud.properties` only | **No** (Dart unsupported) | SonarQube Cloud after push/PR |

Sonar docs: Automatic Analysis **ignores** `sonar-project.properties`. If a project has that file, turn Automatic Analysis **off** and use CI to honor it. Automatic Analysis and CI analysis must not run together — CI fails with *“You are running CI analysis while Automatic Analysis is enabled”* once `SONAR_TOKEN` is set.

**Why ~438 issues stuck after #134:** Automatic Analysis stayed on (`autoscanEnabled=true`), re-scanned `main` at `92e07af`, ignored CI exclusions in `sonar-project.properties`, and kept indexing `design/**` (~177) + `web/drift_worker.js` (~259). The GHA Sonar job skipped (`SONAR_TOKEN` unset). Residual real issues outside that noise: **2** (`text:S8569` gradle lockfile, `cpp:S5813` `wcslen`).

## Free tier and LOC limit

Private projects on the free plan are limited to **≤ 50k lines of code (LOC)**.

Strategy in this repo:

| Setting | Value | Why |
|---------|-------|-----|
| `sonar.sources` | `lib` | Only business Dart sources (**CI scanner**) |
| `sonar.tests` | `test` | Tests are not counted as source LOC |
| `sonar.exclusions` | generated + `design/**` + Drift web worker assets | Drop Drift/Freezed/l10n/mocks, Stitch HTML mockups, vendored `web/drift_worker.js` / `sqlite3.wasm` |

`.sonarcloud.properties` mirrors `sonar.sources=lib` (and exact-path exclusions without `**` wildcards) so Automatic Analysis stops counting design/worker noise until it is turned off.

After a successful **CI** scan, check **LOC in the Sonar UI**. If still above 50k, exclude additional non-critical paths until under the limit — **without** upgrading to a paid plan.

Coverage upload (`coverage/lcov.info`) is configured as an optional path in `sonar-project.properties` but is **not** generated in CI yet (keeps the first release fast).

## Required human steps (Edoardo) — fix the sticky 438

Do these in SonarQube Cloud (project admin) and GitHub. Agents cannot toggle Automatic Analysis via public API without an admin token.

### A. Make CI the source of truth (recommended)

1. Open [Sonar project](https://sonarcloud.io/project/overview?id=edar-dev_powercoach-studio) → **Administration** → **Analysis Method**.
2. Turn **Automatic Analysis** **OFF**.
3. Confirm **Last analysis method** (Project information) is no longer “Analyzed by SonarQube Cloud” after the next CI run.
4. Ensure GitHub Actions secret **`SONAR_TOKEN`** exists (My Account → Security → Generate Tokens → paste into repo Secrets).
5. Re-run **Flutter CI** on `main` (or push a no-op) so the `sonar` job actually scans with `sonar.sources=lib`.
6. **Expected dashboard:** ~**0** open issues under current inventory (noise gone; android/windows outside `lib` not scanned). Quality Gate stays informational.

If Administration → Analysis Method is missing, restore project admin: org **Administration** → **Projects Management** → ⋮ on the project → **Restore Access**.

### B. Keep Automatic Analysis temporarily (noise-only fix)

If you must leave Automatic Analysis on for a short time:

1. Merge the PR that adds `.sonarcloud.properties` (scopes AA to `lib` / excludes design + worker).
2. Wait for the next Automatic Analysis on `main` (or re-analyze).
3. **Expected dashboard:** ~**0** issues from AA (Dart not analyzed; design/worker out of scope). Residual android/windows noise only appears if AA still scans outside `lib`.
4. Optionally also set UI exclusions (wildcards allowed here): **Administration** → **General Settings** → **Analysis Scope** → **Source File Exclusions**:
   - `design/**`
   - `web/drift_worker.js`
   - `web/sqlite3.wasm`
5. Still add `SONAR_TOKEN` and plan to switch to method A — Dart quality will not appear until CI runs with Automatic Analysis off.

### C. First-time setup checklist

1. **Signup** for [SonarQube Cloud Free](https://www.sonarsource.com/products/sonarcloud/) (GitHub login recommended).
2. **Import** GitHub organization `edar-dev` and project/repo `powercoach-studio`.
3. **Confirm keys** match `sonar-project.properties`:
   - `sonar.organization` — often `edar-dev`
   - `sonar.projectKey` — often `edar-dev_powercoach-studio`
4. **Create a token** (My Account → Security → Generate Tokens).
5. Add GitHub Actions secret `SONAR_TOKEN`.
6. Install / authorize the **SonarQube Cloud GitHub App** for PR decoration.
7. Complete **section A** (disable Automatic Analysis) so CI can upload.

## CI behavior

Workflow: `.github/workflows/flutter-ci.yml` → job `sonar`.

- Runs **after** `analyze` (`needs: analyze`). The job itself always schedules (GitHub forbids `secrets.*` in job-level `if` except `GITHUB_TOKEN`).
- **Skip if no token:** first step “Detect Sonar token” sets `skip=true/false` from env `SONAR_TOKEN`; checkout, Flutter setup, and scan run only when `steps.detect.outputs.skip != 'true'`. Without a secret the job succeeds quickly (no Flutter install).
- Uses `SonarSource/sonarqube-scan-action` pinned to a **full commit SHA** (comment `# v5.3.2`, current `v5` tag) — required for Sonar GitHub Actions security rating (`githubactions:S7637`); do not use a floating tag.
- Checkout uses `fetch-depth: 0` for blame/new-code detection.
- Reuses `./.github/actions/setup-flutter-app` so `pub get` is available to the Dart analyzer.
- First release: **scan without coverage** (no `flutter test --coverage`).
- Job fails only if the scanner fails; do **not** make the Sonar Quality Gate a required branch-protection check until a clean baseline exists.
- Once `SONAR_TOKEN` is set, Automatic Analysis **must** be off or this job will fail.

## How to read the Quality Gate

In the SonarQube Cloud project dashboard:

- **Passed / Failed** reflects conditions on new code (bugs, vulnerabilities, coverage thresholds if enabled, duplication, etc.).
- On PRs (with the GitHub App connected): decoration shows new issues introduced by the change.
- Until the gate is made required in GitHub branch protection, a failed gate is a **signal for review**, not a merge blocker.
- **Do not** add “SonarCloud Code Analysis” as a required status check while the gate still fails on expected conditions (see coverage below).

### Coverage on New Code (keep off until lcov upload)

CI does **not** generate or upload `coverage/lcov.info` yet. Any Quality Gate condition that requires coverage on new code (default often ≥ 80%) will fail on real Dart PRs even when the scanner job is green — as seen on [#136](https://github.com/edar-dev/powercoach-studio/pull/136) (const-only / `dart:S7112`).

**Until CI uploads coverage:** in SonarQube Cloud → **Quality Gate** (project or org default), remove or soften **Coverage on New Code**. Do not invent fake coverage files to silence the gate.

After `flutter test --coverage` + lcov upload is wired in the `sonar` job, re-enable a coverage condition and optionally make the gate a required check.

Suggested follow-up (out of this initial PR): after 1–2 weeks of baseline, tighten conditions (e.g. no new bugs/vulns on new code) and optionally mark the check required.

## Related files

- `sonar-project.properties` — CI project key, sources, exclusions (ignored by Automatic Analysis)
- `.sonarcloud.properties` — Automatic Analysis scope only (ignored by CI scanner)
- `.github/workflows/flutter-ci.yml` — `sonar` job
- `README.md` — short link to this doc

## References

- [Automatic analysis](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/automatic-analysis) — ignores `sonar-project.properties`; use `.sonarcloud.properties` or UI; Dart unsupported
- [CI vs Automatic conflict](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/ci-based-analysis/overview-of-integrated-cis)
- [Excluding files based on patterns](https://docs.sonarsource.com/sonarqube-cloud/managing-your-projects/project-analysis/setting-analysis-scope/excluding-files-based-on-patterns)
