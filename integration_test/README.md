# E2E / integration tests – PowerCoach Studio

Stock Flutter `integration_test` (no Patrol). Two suites live here:

| Suite | Purpose | Secrets | CI |
|-------|---------|---------|-----|
| `app_test.dart`, `landing_flow_test.dart` | Unauthenticated login/landing flows | `.env` Supabase | **Not** in CI |
| `phone_smokes/` | Phase B phone UI smokes (shell, day editor, Modifica blocco) | **None** — local harness / seed | **Codemagic nightly only** (`android_integration_nightly`) |

Required PR CI remains `flutter test test/` (widget/unit). Emulator smokes are **not** blocking on every PR.

## Phone UI smokes (Phase B)

Harnesses mirror Phase A widget tests: `MaterialApp` + in-memory fixtures / shell router — **no live Supabase auth**.

```bash
# All three smokes (needs a device / emulator / desktop target)
flutter test integration_test/phone_smokes/ -d <deviceId>

# Singles
flutter test integration_test/phone_smokes/shell_smoke_test.dart -d <deviceId>
flutter test integration_test/phone_smokes/day_editor_smoke_test.dart -d <deviceId>
flutter test integration_test/phone_smokes/edit_block_smoke_test.dart -d <deviceId>
```

Local Android emulator example:

```bash
flutter emulators --launch <emulator_id>
adb wait-for-device
flutter test integration_test/phone_smokes/ -d emulator-5554
```

On Linux/macOS desktop (no AVD), pass `-d linux` / `-d macos` after enabling the desktop device.

### What they cover

1. **Shell** — 4 primary tabs → Settings hides `NavigationBar`
2. **Day editor** — sticky `Salva modifiche` clears home-indicator band
3. **Modifica blocco** — type `Serie`, keyboard inset, `Salva` hittable / dismiss

## Legacy login / landing E2E

Require a synced env asset:

1. Put `SUPABASE_URL` / `SUPABASE_ANON_KEY` in `.env`
2. `bash scripts/ensure-env.sh`
3. `flutter test integration_test/app_test.dart`

On Windows, Developer Mode may be required for plugin symlink builds.

## Codemagic nightly

Workflow `android_integration_nightly` in `codemagic.yaml`:

- Linux instance + Android emulator
- Runs **only** `integration_test/phone_smokes/`
- **No** push/PR triggers — schedule in Codemagic UI: **Scheduled builds** → workflow `Android Integration Smokes (Nightly)` → branch `main`

See also `docs/testing.md`.
