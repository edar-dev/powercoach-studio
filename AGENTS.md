# PowerCoach Studio - Agent Operating Guide

## Goal
- Deliver production-ready Flutter changes with minimal regressions.
- Prefer small, testable edits over broad refactors.
- Keep UX behavior stable unless the task explicitly asks for a behavior change.

## Required Workflow
1. Map the target area before editing (files, state flow, dependencies).
2. Implement with existing architecture and naming patterns.
3. Run validation commands after substantive edits.
4. Report what changed, why, and how it was verified.

## Flutter Guardrails
- Follow existing feature-based structure under `lib/features/*`.
- Keep business logic outside widgets when complexity grows.
- Reuse theme tokens and shared UI components before adding new styles.
- Avoid introducing new dependencies unless clearly justified.

## Verification Checklist
- Run `flutter analyze`.
- Run focused tests for touched features when available.
- If models/schema changed, run required code generation.

## Team Quality Gates (Definition of Done)
- Behavior is validated for happy path plus key edge states (loading, empty, error).
- New logic is covered by focused tests when testable in reasonable scope.
- No architecture drift: changes align with existing module boundaries.
- Handoff includes explicit risk notes and clear verification evidence.

## Subagent Delegation Defaults
- Use `flutter-explorer` to quickly map unfamiliar areas.
- Use `flutter-implementer` for multi-file implementation tasks.
- Use `flutter-reviewer` for risk/regression review before handoff.
- Use `flutter-test-runner` for analyze/test/codegen execution.

## Commit and PR Hygiene
- Keep commits scoped to one logical change.
- Use imperative commit titles and explain "why" in body when non-obvious.
- Before opening a PR, include: scope summary, risk assessment, and test evidence.
- Prefer small PRs over large mixed refactors.

## Output Expectations
- Explain changes by file path and intent.
- Call out risks, assumptions, and follow-up actions.
- Keep responses concise and actionable.
