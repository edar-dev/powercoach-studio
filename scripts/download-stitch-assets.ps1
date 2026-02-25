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

# Simplified Startup Landing Page (screen ID 0b414c91bc8d406ea47ac2570d7b51df)
$LandingScreenshotUrl = $env:STITCH_SIMPLIFIED_LANDING_SCREENSHOT_URL
$LandingHtmlUrl = $env:STITCH_SIMPLIFIED_LANDING_HTML_URL

# Simplified Registration Page (screen ID 76b61a47b6324d31bfd4957cd921aaee)
$RegistrationScreenshotUrl = $env:STITCH_REGISTRATION_SCREENSHOT_URL
$RegistrationHtmlUrl = $env:STITCH_REGISTRATION_HTML_URL

# Login Page (screen ID 3e212f412ed849a9b6bcfc0772cf15fd)
$LoginScreenshotUrl = $env:STITCH_LOGIN_SCREENSHOT_URL
$LoginHtmlUrl = $env:STITCH_LOGIN_HTML_URL

# Updated Coach Profile (screen ID 5863bd21319d467b828ad322f8670305)
$CoachProfileScreenshotUrl = $env:STITCH_COACH_PROFILE_SCREENSHOT_URL
$CoachProfileHtmlUrl = $env:STITCH_COACH_PROFILE_HTML_URL

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

$ok = 0
if ($LandingScreenshotUrl -and $LandingHtmlUrl) {
    if (Download-File -Url $LandingScreenshotUrl -OutPath (Join-Path $AssetsRoot 'simplified-landing.png')) { $ok++ }
    if (Download-File -Url $LandingHtmlUrl -OutPath (Join-Path $AssetsRoot 'simplified-landing.html')) { $ok++ }
} else {
    Write-Host "Landing: set STITCH_SIMPLIFIED_LANDING_SCREENSHOT_URL and STITCH_SIMPLIFIED_LANDING_HTML_URL to download."
}
if ($RegistrationScreenshotUrl -and $RegistrationHtmlUrl) {
    if (Download-File -Url $RegistrationScreenshotUrl -OutPath (Join-Path $AssetsRoot 'simplified-registration.png')) { $ok++ }
    if (Download-File -Url $RegistrationHtmlUrl -OutPath (Join-Path $AssetsRoot 'simplified-registration.html')) { $ok++ }
} else {
    Write-Host "Registration: set STITCH_REGISTRATION_SCREENSHOT_URL and STITCH_REGISTRATION_HTML_URL to download."
}
if ($LoginScreenshotUrl -and $LoginHtmlUrl) {
    if (Download-File -Url $LoginScreenshotUrl -OutPath (Join-Path $AssetsRoot 'login.png')) { $ok++ }
    if (Download-File -Url $LoginHtmlUrl -OutPath (Join-Path $AssetsRoot 'login.html')) { $ok++ }
} else {
    Write-Host "Login: set STITCH_LOGIN_SCREENSHOT_URL and STITCH_LOGIN_HTML_URL to download."
}
if ($CoachProfileScreenshotUrl -and $CoachProfileHtmlUrl) {
    if (Download-File -Url $CoachProfileScreenshotUrl -OutPath (Join-Path $AssetsRoot 'coach-profile.png')) { $ok++ }
    if (Download-File -Url $CoachProfileHtmlUrl -OutPath (Join-Path $AssetsRoot 'coach-profile.html')) { $ok++ }
} else {
    Write-Host "Updated Coach Profile: set STITCH_COACH_PROFILE_SCREENSHOT_URL and STITCH_COACH_PROFILE_HTML_URL to download."
}
if ($ok -eq 0) {
    Write-Host "See powercoach-studio/design/README.md for how to obtain URLs from Stitch."
}
Write-Host "Done. Downloaded $ok file(s) to $AssetsRoot"
