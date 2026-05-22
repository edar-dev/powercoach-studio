# Play Store Release Guide (PowerCoach Studio)

This guide explains how to publish `powercoach-studio` to Google Play using Codemagic.

## 1) Prerequisites

- Google Play Console app created (same `applicationId` as Android project):
  - `com.gymblog.powercoach_studio`
- At least one tester channel enabled (recommended: **Internal testing**).
- You own the release keystore and never lose it.
- Codemagic project connected to this GitHub repository.

## 2) Android Signing Setup

Google Play requires a signed AAB. This repo supports release signing via `android/key.properties`.

### 2.1 Create or recover your keystore

If you already have a production keystore, reuse it.

If not, generate one once:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Save securely:
- keystore file (`.jks`)
- keystore password
- key alias
- key password

### 2.2 Configure Codemagic Android signing variables

In Codemagic, create/update the `google_credentials` environment group with:

- `ANDROID_KEYSTORE_BASE64` (base64 content of `.jks` file)
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

`android_play_store` workflow reconstructs `android/upload-keystore.jks` from base64 and writes `android/key.properties` during build.

To generate base64 locally:

```bash
base64 -w 0 upload-keystore.jks
```

On macOS (BSD base64):

```bash
base64 upload-keystore.jks | tr -d '\n'
```

## 3) Google Play API Service Account

Codemagic needs API credentials to upload to Play.

### 3.1 Create service account JSON

1. Google Cloud Console -> Service Accounts -> create account.
2. Create JSON key.
3. In Play Console:
   - `Setup` -> `API access`
   - Link the Google Cloud project
   - Grant the service account app permissions (release manager style permissions for the target app).

### 3.2 Add credential to Codemagic

In group `google_credentials`, add:

- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` = full JSON content of the service account key

## 4) App Runtime Environment Variables

Still in `google_credentials`, set:

- `SUPABASE_URL` (required)
- `SUPABASE_ANON_KEY` (required)
- `SENTRY_DSN` (optional)
- `SENTRY_ENVIRONMENT` (optional)
- `GYMBLOG_API_URL` (optional)

## 5) Pipeline Behavior (current `codemagic.yaml`)

- `pr_quality_gate` (PR to `main`): analyze + tests.
- `android_release` (push to `main`): builds APK + AAB artifacts only.
- `android_play_store` (tag `v*`): validates secrets, reconstructs signing keystore, creates signed `key.properties`, builds AAB, publishes to Play `internal` track (released to internal testers, not draft).

## 6) First Release Checklist

Before first production publication:

1. In `pubspec.yaml`, set correct:
   - `version: x.y.z+buildNumber`
2. Ensure Play Console required metadata exists:
   - app name
   - short/full description
   - screenshots
   - privacy policy
   - data safety form
   - content rating
3. Ensure package name matches Play app exactly.
4. Confirm service account has required permissions.

## 7) Publish Flow (recommended)

### Internal testing rollout

1. Merge to `main` and verify `android_release` is green.
2. Create a release tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

3. Codemagic triggers `android_play_store`.
4. Verify build success and artifact upload in Codemagic.
5. In Play Console internal track, validate:
   - release notes
   - tester availability
   - install/update behavior

### Production rollout

After internal validation:

1. Promote the tested artifact from internal track to production in Play Console, or
2. Switch Codemagic `track` from `internal` to `production` when you want fully automated production publishing.

## 8) Common Failure Modes

- **Unknown variable group**: ensure `google_credentials` exists in Codemagic project.
- **Missing signing vars**: check `ANDROID_KEYSTORE_*` / `ANDROID_KEY_*` values.
- **`Expecting value: line 1 column 1 (char 0)`** on Play publish: `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` is present but **not valid JSON**. Typical causes:
  - Variable is empty, a placeholder, or only whitespace
  - You pasted a **file path** or **base64** instead of the raw `.json` file contents
  - JSON was truncated when pasting (must include the full key, including `private_key` with `\n` newlines)
  - Wrong credential type (OAuth client secret instead of **service account** key)
  - **Fix**: Codemagic → App → Environment variables → group `google_credentials` → edit `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` → paste entire service account JSON → mark as **Secret** → Save. Re-run the workflow.
- **Invalid service account**: verify `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` JSON and Play API access linkage in Play Console (Users and permissions → invite service account email → App permissions + Releases).
- **Version conflict**: increase Android `versionCode` (`pubspec.yaml` build number).
- **Signing mismatch**: never rotate keystore randomly after first upload.

## 9) Security Notes

- Never commit keystore files or JSON service account keys to git.
- Rotate service account key if compromised.
- Limit service account permissions to minimum needed.

