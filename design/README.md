# PowerCoach Studio – Design (Stitch)

La landing dell’app Flutter è allineata al prototipo **Google Stitch “Landing Page”**.

## Riferimenti

- **Progetto Stitch:** Landing Page  
- **Project ID:** `13531110169329089006`  
- **Screen:** Simplified Startup Landing Page  
- **Screen ID:** `0b414c91bc8d406ea47ac2570d7b51df`
- **Screen:** Simplified Registration Page  
- **Screen ID:** `76b61a47b6324d31bfd4957cd921aaee`
- **Screen:** Login Page  
- **Screen ID:** `3e212f412ed849a9b6bcfc0772cf15fd`
- **Screen:** Updated Coach Profile  
- **Screen ID:** `5863bd21319d467b828ad322f8670305`

## Asset

Gli screenshot e l’HTML esportati da Stitch vanno in:

- `powercoach-studio/design/stitch-assets/`
  - `simplified-landing.png` / `simplified-landing.html` – Landing
  - `simplified-registration.png` / `simplified-registration.html` – Registration
  - `login.png` / `login.html` – Login
  - `coach-profile.png` / `coach-profile.html` – Updated Coach Profile

## Come ottenere gli URL

1. **Da Stitch (UI):** apri il progetto su [Stitch](https://stitch.withgoogle.com), seleziona lo screen “Simplified Startup Landing Page” e usa le opzioni di download/export per copiare gli URL di screenshot e HTML.
2. **Da Stitch MCP:** se usi il server MCP Stitch, chiama `get_screen` con:
   - `projectId`: `13531110169329089006`
   - `screenId`: `0b414c91bc8d406ea47ac2570d7b51df` (Landing), `76b61a47b6324d31bfd4957cd921aaee` (Registration), `3e212f412ed849a9b6bcfc0772cf15fd` (Login), `5863bd21319d467b828ad322f8670305` (Updated Coach Profile)  
   Dalla risposta usa `screenshot.downloadUrl` e `htmlCode.downloadUrl`.

## Script di download

Dopo aver ottenuto gli URL, imposta le variabili d’ambiente e lancia lo script:

```powershell
$env:STITCH_SIMPLIFIED_LANDING_SCREENSHOT_URL = "<screenshot-download-URL>"
$env:STITCH_SIMPLIFIED_LANDING_HTML_URL = "<html-download-URL>"
.\powercoach-studio\scripts\download-stitch-assets.ps1
```

Dalla root del repo:

```powershell
cd d:\source\Gym\gym-blog
$env:STITCH_SIMPLIFIED_LANDING_SCREENSHOT_URL = "https://..."
$env:STITCH_SIMPLIFIED_LANDING_HTML_URL = "https://..."
# Registration (optional):
$env:STITCH_REGISTRATION_SCREENSHOT_URL = "https://..."
$env:STITCH_REGISTRATION_HTML_URL = "https://..."
# Login (optional):
$env:STITCH_LOGIN_SCREENSHOT_URL = "https://..."
$env:STITCH_LOGIN_HTML_URL = "https://..."
# Updated Coach Profile (optional):
$env:STITCH_COACH_PROFILE_SCREENSHOT_URL = "https://..."
$env:STITCH_COACH_PROFILE_HTML_URL = "https://..."
.\powercoach-studio\scripts\download-stitch-assets.ps1
```

In alternativa puoi scaricare a mano con `curl -L`:

```bash
curl -L -o powercoach-studio/design/stitch-assets/simplified-landing.png "<screenshot-URL>"
curl -L -o powercoach-studio/design/stitch-assets/simplified-landing.html "<html-URL>"
```

## Implementazione Flutter

- `lib/features/landing/presentation/screens/landing_screen.dart` – landing (hero, titolo, CTA).
- `lib/features/auth/presentation/screens/registration_screen.dart` – registrazione (form email/password, Supabase Auth).
- `lib/features/auth/presentation/screens/login_screen.dart` – login (form email/password, Supabase Auth).
- `lib/features/auth/presentation/screens/profile_screen.dart` – profilo coach (form nome, email, telefono, bio, avatar; lettura/salvataggio da Supabase `profiles`).  
Dopo aver scaricato screenshot e HTML in `stitch-assets/`, puoi affinare layout e testi confrontando con gli asset.
