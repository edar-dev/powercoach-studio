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
- **Screen:** Personal Info Settings  
- **Screen ID:** `0f594d4c05da4c8aa79172ab31ce8790`
- **Screen:** Subscription Settings  
- **Screen ID:** `1224a49f9c5849fcb205e965ebc0b9a4`
- **Screen:** Simplified App Settings  
- **Screen ID:** `8ab8a84172594c1c9911b5762e2a7257`
- **Screen:** Empty Customer List Page  
- **Screen ID:** `3d09f0f5b58f4867990e02be11ffc7d2`
- **Screen:** Customer Creation Page  
- **Screen ID:** `534f6e3664244ba59196220f2909eb46`
- **Screen:** Customer Detail Page  
- **Screen ID:** `7a7f3b47bfa1435381554959ca9b72e7`
- **Screen:** Customer List Page (Populated)  
- **Screen ID:** `92b1ea1864184682b142aa8ffea211f8`

## Asset

Gli screenshot e l’HTML esportati da Stitch vanno in:

- `powercoach-studio/design/stitch-assets/`
  - `simplified-landing.png` / `simplified-landing.html` – Landing
  - `simplified-registration.png` / `simplified-registration.html` – Registration
  - `login.png` / `login.html` – Login
  - `coach-profile.png` / `coach-profile.html` – Updated Coach Profile
  - `personal-info-settings.png` / `personal-info-settings.html` – Personal Info Settings
  - `subscription-settings.png` / `subscription-settings.html` – Subscription Settings
  - `app-settings.png` / `app-settings.html` – Simplified App Settings
  - `empty-customer-list.png` / `empty-customer-list.html` – Empty Customer List Page
  - `customer-creation.png` / `customer-creation.html` – Customer Creation Page
  - `customer-detail.png` / `customer-detail.html` – Customer Detail Page
  - `customer-list-populated.png` / `customer-list-populated.html` – Customer List Page (Populated)

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
# Personal Info Settings, Subscription Settings, App Settings (optional):
$env:STITCH_PERSONAL_INFO_SCREENSHOT_URL = "https://..."
$env:STITCH_PERSONAL_INFO_HTML_URL = "https://..."
$env:STITCH_SUBSCRIPTION_SCREENSHOT_URL = "https://..."
$env:STITCH_SUBSCRIPTION_HTML_URL = "https://..."
$env:STITCH_APP_SETTINGS_SCREENSHOT_URL = "https://..."
$env:STITCH_APP_SETTINGS_HTML_URL = "https://..."
# Customer screens (optional):
$env:STITCH_EMPTY_CUSTOMER_LIST_SCREENSHOT_URL = "https://..."
$env:STITCH_EMPTY_CUSTOMER_LIST_HTML_URL = "https://..."
$env:STITCH_CUSTOMER_CREATION_SCREENSHOT_URL = "https://..."
$env:STITCH_CUSTOMER_CREATION_HTML_URL = "https://..."
$env:STITCH_CUSTOMER_DETAIL_SCREENSHOT_URL = "https://..."
$env:STITCH_CUSTOMER_DETAIL_HTML_URL = "https://..."
$env:STITCH_CUSTOMER_LIST_POPULATED_SCREENSHOT_URL = "https://..."
$env:STITCH_CUSTOMER_LIST_POPULATED_HTML_URL = "https://..."
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
- `lib/features/settings/presentation/screens/personal_info_screen.dart` – Personal Info Settings (nome, email, telefono).
- `lib/features/settings/presentation/screens/subscription_screen.dart` – Subscription Settings (piano corrente, upgrade).
- `lib/features/settings/presentation/screens/settings_screen.dart` – Simplified App Settings (notifiche, lingua, esci).
- `lib/features/customers/presentation/screens/customer_list_screen.dart` – lista clienti (vuota o popolata).
- `lib/features/customers/presentation/screens/customer_creation_screen.dart` – creazione cliente.
- `lib/features/customers/presentation/screens/customer_detail_screen.dart` – dettaglio cliente.  
Dopo aver scaricato screenshot e HTML in `stitch-assets/`, puoi affinare layout e testi confrontando con gli asset.
