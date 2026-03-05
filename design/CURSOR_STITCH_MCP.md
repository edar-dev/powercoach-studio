# Abilitare Stitch MCP in Cursor

Per usare l’MCP di Stitch da Cursor (e far sì che l’agente possa chiamare `get_screen`, `get_screen_image`, `get_screen_code`), aggiungi il server Stitch alla configurazione MCP.

## 1. Configurare il server Stitch

1. Apri **Cursor** → **Settings** (Ctrl+,) → **Cursor Settings** → **MCP** (o **Features** → **MCP**).
2. Se esiste già un file di config MCP (es. `~/.cursor/mcp.json` o quello indicato in Cursor), aprilo; altrimenti aggiungi un server dalla UI.
3. Aggiungi il blocco del server `stitch`:

```json
{
  "mcpServers": {
    "stitch": {
      "command": "npx",
      "args": ["@_davideast/stitch-mcp", "proxy"]
    }
  }
}
```

Se usi già gcloud e vuoi usare quel progetto/credenziali:

```json
{
  "mcpServers": {
    "stitch": {
      "command": "npx",
      "args": ["@_davideast/stitch-mcp", "proxy"],
      "env": {
        "STITCH_USE_SYSTEM_GCLOUD": "1"
      }
    }
  }
}
```

4. Salva e **riavvia Cursor** (o ricarica la finestra) così il server MCP viene avviato.

## 2. Autenticazione (prima volta)

Prima di usare l’MCP (o lo script CLI) esegui una sola volta:

```bash
npx @_davideast/stitch-mcp init
```

Segui il wizard (gcloud, OAuth, progetto Google Cloud). In alternativa puoi usare una API key:

```bash
# Opzionale: evita OAuth
set STITCH_API_KEY=your-api-key
```

## 3. Verifica

- Da terminale: `npx @_davideast/stitch-mcp doctor`
- In Cursor: dopo il restart, l’agente userà il server **`user-stitch`** (nome nella lista MCP). Tool disponibili: `get_screen`, `list_screens`, `get_screen_image`, `get_screen_code`, ecc. con `projectId` e `screenId` del progetto “Landing Page”.

## Riferimento progetto

- **Project:** Landing Page  
- **Project ID:** `13531110169329089006`  
- Screen ID: vedi `design/STITCH_SCREENS.md`.
