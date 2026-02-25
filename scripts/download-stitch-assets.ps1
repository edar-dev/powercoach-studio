# Download Stitch project "Landing Page" (ID 13531110169329089006) screenshots and HTML.
# Screen: "Simplified Startup Landing Page" (ID 0b414c91bc8d406ea47ac2570d7b51df).
# Run from repo root or powercoach-studio: .\scripts\download-stitch-assets.ps1
# Requires: PowerShell 5.1+ (Invoke-WebRequest) or curl.exe on PATH.
#
# To get URLs: open the project in Stitch (stitch.withgoogle.com), select the screen,
# and copy the screenshot download URL and HTML export URL; or use Stitch MCP get_screen
# with projectId 13531110169329089006 and screenId 0b414c91bc8d406ea47ac2570d7b51df.
# Then set $ScreenshotUrl and $HtmlUrl below (or use design/stitch-urls.json if added).

$ErrorActionPreference = 'Stop'
$ProjectRoot = if ($PSScriptRoot) { Split-Path (Split-Path $PSScriptRoot -Parent) -Parent } else { $env:PWD }
$StudioRoot = Join-Path $ProjectRoot 'powercoach-studio'
$DesignRoot = Join-Path $StudioRoot 'design'
$AssetsRoot = Join-Path $DesignRoot 'stitch-assets'

foreach ($d in @($DesignRoot, $AssetsRoot)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# Simplified Startup Landing Page
# Replace with actual URLs from Stitch UI or MCP get_screen when available.
$ScreenshotUrl = $env:STITCH_SIMPLIFIED_LANDING_SCREENSHOT_URL  # optional env override
$HtmlUrl = $env:STITCH_SIMPLIFIED_LANDING_HTML_URL              # optional env override

if (-not $ScreenshotUrl -or -not $HtmlUrl) {
    Write-Host "Skipping download: STITCH_SIMPLIFIED_LANDING_SCREENSHOT_URL and/or STITCH_SIMPLIFIED_LANDING_HTML_URL not set."
    Write-Host "See powercoach-studio/design/README.md for how to obtain URLs from Stitch."
    exit 0
}

function Download-File {
    param ([string]$Url, [string]$OutPath)
    if (-not $Url) { return $false }
    try {
        if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
            & curl.exe -L -s -o $OutPath -- $Url
        } else {
            Invoke-WebRequest -Uri $Url -OutFile $OutPath -UseBasicParsing -MaximumRedirection 10
        }
        return $true
    } catch {
        Write-Warning "Download failed: $Url -> $OutPath : $_"
        return $false
    }
}

$pngPath = Join-Path $AssetsRoot 'simplified-landing.png'
$htmlPath = Join-Path $AssetsRoot 'simplified-landing.html'
$ok = 0
if (Download-File -Url $ScreenshotUrl -OutPath $pngPath) { $ok++ }
if (Download-File -Url $HtmlUrl -OutPath $htmlPath) { $ok++ }
Write-Host "Done. Downloaded $ok file(s) to $AssetsRoot"
