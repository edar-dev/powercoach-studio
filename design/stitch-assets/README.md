# Asset Stitch per il confronto

In questa cartella vanno screenshot (`.png`) e HTML (`.html`) esportati da Stitch per confrontarli con le schermate Flutter.

## Come scaricare i file

### 1. Ottieni gli URL da Stitch

- **Da Stitch (UI):** apri [stitch.withgoogle.com](https://stitch.withgoogle.com), progetto **Landing Page** (ID `13531110169329089006`). Per ogni screen apri il menu e copia l’URL di download dello **screenshot** e dell’**export HTML**.
- **Da Stitch MCP:** se usi il server MCP Stitch, chiama `get_screen` con `projectId: 13531110169329089006` e lo `screenId` (vedi sotto). Dalla risposta usa `screenshot.downloadUrl` e `htmlCode.downloadUrl`.

### 2. Usa il file degli URL

1. Copia il file di esempio nella stessa cartella `design`:
   ```powershell
   Copy-Item design\stitch-urls.example.json design\stitch-urls.json
   ```
2. Apri `design/stitch-urls.json` e incolla gli URL nelle chiavi corrispondenti (lascia vuote le coppie che non usi).
3. Dalla root del repo lancia lo script:
   ```powershell
   .\powercoach-studio\scripts\download-stitch-assets.ps1
   ```
   I file verranno scaricati qui con nomi tipo `simplified-landing.png`, `simplified-landing.html`, `login.png`, ecc.

### 3. Alternativa: variabili d’ambiente

Puoi anche impostare le variabili d’ambiente e lanciare lo script (vedi `design/README.md`).

---

## Screen ID di riferimento (8 schermi)

| Screen                      | Screen ID        | File scaricati                    |
|----------------------------|------------------|-----------------------------------|
| Simplified Startup Landing | 0b414c91bc8d406ea47ac2570d7b51df | simplified-landing.png / .html   |
| Personal Info Settings     | 0f594d4c05da4c8aa79172ab31ce8790 | personal-info-settings.png / .html |
| Subscription Settings      | 1224a49f9c5849fcb205e965ebc0b9a4 | subscription-settings.png / .html |
| Forgot Password            | 3563377ad3864dfca42385fcd5ea0840 | forgot-password.png / .html       |
| Login Page                 | 3e212f412ed849a9b6bcfc0772cf15fd | login.png / .html                 |
| Updated Coach Profile      | 5863bd21319d467b828ad322f8670305 | coach-profile.png / .html        |
| Simplified Registration    | 76b61a47b6324d31bfd4957cd921aaee | simplified-registration.png / .html |
| Simplified App Settings    | 8ab8a84172594c1c9911b5762e2a7257 | app-settings.png / .html         |

**Progetto PDF (Workout export):** Project ID `15732533611981325178`

| Screen           | Screen ID        | File scaricati                          |
|------------------|------------------|-----------------------------------------|
| Generated Screen | 80e27a86da484d75b1dc9481a2d61b1c | generated-pdf-screen.png / .html |

`stitch-urls.json` non va committato se contiene URL con token; usa `stitch-urls.example.json` come template.
