# PowerCoach Studio – Design (Stitch)

La landing dell’app Flutter è allineata al prototipo **Google Stitch “Landing Page”**.

## Riferimenti

- **Progetto Stitch:** Landing Page  
- **Project ID:** `13531110169329089006`  
- **Screen:** Simplified Startup Landing Page  
- **Screen ID:** `0b414c91bc8d406ea47ac2570d7b51df`

## Asset

Gli screenshot e l’HTML esportati da Stitch vanno in:

- `powercoach-studio/design/stitch-assets/`
  - `simplified-landing.png` – screenshot dello screen
  - `simplified-landing.html` – HTML/codice esportato

## Come ottenere gli URL

1. **Da Stitch (UI):** apri il progetto su [Stitch](https://stitch.withgoogle.com), seleziona lo screen “Simplified Startup Landing Page” e usa le opzioni di download/export per copiare gli URL di screenshot e HTML.
2. **Da Stitch MCP:** se usi il server MCP Stitch, chiama `get_screen` con:
   - `projectId`: `13531110169329089006`
   - `screenId`: `0b414c91bc8d406ea47ac2570d7b51df`  
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
.\powercoach-studio\scripts\download-stitch-assets.ps1
```

In alternativa puoi scaricare a mano con `curl -L`:

```bash
curl -L -o powercoach-studio/design/stitch-assets/simplified-landing.png "<screenshot-URL>"
curl -L -o powercoach-studio/design/stitch-assets/simplified-landing.html "<html-URL>"
```

## Implementazione Flutter

La schermata `lib/features/landing/presentation/screens/landing_screen.dart` replica il layout del prototipo (hero, titolo, sottotitolo, CTA). Dopo aver scaricato screenshot e HTML in `stitch-assets/`, puoi affinare layout, colori e testi confrontando con gli asset.
