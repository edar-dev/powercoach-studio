# Code quality — SonarQube Cloud Free

PowerCoach Studio uses **[SonarQube Cloud Free](https://www.sonarsource.com/products/sonarcloud/)** (ex SonarCloud) for static analysis on pull requests and `main`. Dart is supported officially. This is an **informational** quality signal: the CI job fails only if the scanner itself fails, not because the Sonar Quality Gate is red.

## Free tier and LOC limit

Private projects on the free plan are limited to **≤ 50k lines of code (LOC)**.

Strategy in this repo:

| Setting | Value | Why |
|---------|-------|-----|
| `sonar.sources` | `lib` | Only business Dart sources |
| `sonar.tests` | `test` | Tests are not counted as source LOC |
| `sonar.exclusions` | `**/*.g.dart`, `**/*.freezed.dart`, `**/l10n/**`, `**/*.mocks.dart` | Drop generated Drift/Freezed, l10n, mocks |

After the first successful scan, check **LOC in the Sonar UI**. If still above 50k, exclude additional non-critical paths (helpers, large string tables) until under the limit — **without** upgrading to a paid plan.

Coverage upload (`coverage/lcov.info`) is configured as an optional path in `sonar-project.properties` but is **not** generated in CI yet (keeps the first release fast).

## Human setup (Edoardo)

Do these once; CI stays green without them because the `sonar` job is skipped when the secret is missing.

1. **Signup** for [SonarQube Cloud Free](https://www.sonarsource.com/products/sonarcloud/) (GitHub login recommended).
2. **Import** GitHub organization `edar-dev` and project/repo `powercoach-studio`.
3. **Confirm keys** in the Sonar project settings and match `sonar-project.properties`:
   - `sonar.organization` — often `edar-dev` (confirm after signup)
   - `sonar.projectKey` — often `edar-dev_powercoach-studio` (confirm after signup)
   - If Sonar shows different keys, update the properties file and re-run CI.
4. **Create a token** in SonarQube Cloud (My Account → Security → Generate Tokens).
5. Add a GitHub Actions secret on the repo:
   - Name: `SONAR_TOKEN`
   - Value: the token from step 4
6. (Recommended) Install / authorize the **SonarQube Cloud GitHub App** for PR decoration (inline comments and quality summary on PRs).

## CI behavior

Workflow: `.github/workflows/flutter-ci.yml` → job `sonar`.

- Runs **after** `analyze` (`needs: analyze`).
- Uses `SonarSource/sonarqube-scan-action@v5` (composite; required for Dart).
- Checkout uses `fetch-depth: 0` for blame/new-code detection.
- Reuses `./.github/actions/setup-flutter-app` so `pub get` is available to the Dart analyzer.
- **Skip if no token:** `if: secrets.SONAR_TOKEN != ''`.
- First release: **scan without coverage** (no `flutter test --coverage`).
- Job fails only if the scanner fails; do **not** make the Sonar Quality Gate a required branch-protection check until a clean baseline exists.

## How to read the Quality Gate

In the SonarQube Cloud project dashboard:

- **Passed / Failed** reflects conditions on new code (bugs, vulnerabilities, coverage thresholds if enabled, duplication, etc.).
- On PRs (with the GitHub App connected): decoration shows new issues introduced by the change.
- Until the gate is made required in GitHub branch protection, a failed gate is a **signal for review**, not a merge blocker.

Suggested follow-up (out of this initial PR): after 1–2 weeks of baseline, tighten conditions (e.g. no new bugs/vulns on new code) and optionally mark the check required.

## Related files

- `sonar-project.properties` — project key, sources, exclusions
- `.github/workflows/flutter-ci.yml` — `sonar` job
- `README.md` — short link to this doc
