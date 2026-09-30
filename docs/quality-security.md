# Quality & security (supply chain)

Baseline for PowerCoach Studio: Dependabot, pinned GitHub Actions, security policy, and CI gates. SonarQube Cloud Free remains an **informational** signal (see [sonar-quality.md](sonar-quality.md)).

## Automated in this repo

| Control | Where |
|---------|--------|
| Dependabot (`github-actions` + `pub`, weekly) | [`.github/dependabot.yml`](../.github/dependabot.yml) |
| Third-party Actions pinned to full commit SHAs (`# vX.Y.Z` comments) | Workflows under `.github/workflows/` + [`.github/actions/setup-flutter-app`](../.github/actions/setup-flutter-app/action.yml) |
| Lockfile enforcement | `flutter pub get --enforce-lockfile` in setup-flutter-app |
| Vulnerability reporting | [`SECURITY.md`](../SECURITY.md) + GitHub Security Advisories |
| Issue template contact | [`.github/ISSUE_TEMPLATE/config.yml`](../.github/ISSUE_TEMPLATE/config.yml) → security policy |

## CI checks (GitHub Actions)

| Job name | Workflow | Role |
|----------|----------|------|
| **Static analysis** | Flutter CI | Required for merge (once branch protection is set) |
| **Unit and widget tests** | Flutter CI | Required for merge (once branch protection is set) |
| **SonarQube Cloud** | Flutter CI | Informational; Quality Gate (incl. coverage) is **not** a required check |

Do **not** treat Sonar “Coverage on New Code” failures as merge blockers until CI uploads real `lcov` (documented in [sonar-quality.md](sonar-quality.md)).

## Human checklist (GitHub Settings — Edoardo)

Agents cannot flip these UI toggles. Complete once on `edar-dev/powercoach-studio`:

1. **Settings → Code security** (or Security → Dependabot):
   - Enable **Dependabot alerts**
   - Enable **Dependabot security updates** (optional but recommended alongside the weekly `dependabot.yml`)
   - Enable **Secret scanning** (and push protection if available on the plan)
2. **Settings → Branches → Branch protection** for `main`:
   - Require status checks before merging
   - Required checks: **`Static analysis`** and **`Unit and widget tests`**
   - Do **not** require **SonarQube Cloud** (or any Sonar coverage gate)
3. **Sonar QG:** keep **Coverage on New Code** disabled/soft until coverage upload exists ([sonar-quality.md](sonar-quality.md)).

## Related docs

- [sonar-quality.md](sonar-quality.md) — SonarQube Cloud Free setup
- [testing.md](testing.md) — local/CI test commands
