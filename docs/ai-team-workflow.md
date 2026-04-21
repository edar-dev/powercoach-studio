# AI Team Workflow (Cursor)

## Objective
Use Cursor agents consistently to deliver small, safe, verifiable changes.

## Standard Flow
1. Explore scope and identify touched modules.
2. Implement the minimal safe diff.
3. Run verification (`flutter analyze`, targeted tests).
4. Review for regressions and architecture drift.
5. Open PR with evidence, risks, and manual QA notes.

## Subagent Usage
- `flutter-explorer`: map file responsibilities and data flow.
- `flutter-implementer`: implement feature/refactor/bugfix changes.
- `flutter-test-runner`: run analyze/tests/codegen and report failures.
- `flutter-reviewer`: final regression and quality review.

## Definition of Done
- Happy path and key edge states (loading/empty/error) are validated.
- Relevant tests are executed for changed behavior.
- No architecture drift from existing feature boundaries.
- PR includes risk notes and validation evidence.

## Stop Conditions (ask before proceeding)
- Destructive DB/API changes
- New dependencies or major upgrades
- Security/auth flow breaking changes
- Destructive git operations

## PR Expectations
- Keep PRs focused to one logical change.
- Include summary, scope, evidence, risks, and QA checklist.
- Prefer small PRs over broad mixed refactors.

## Team Cadence
- Weekly: review recurring PR comments and tighten rules/templates.
- Monthly: refine subagent prompts based on regressions or review bottlenecks.
