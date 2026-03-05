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

# Load URLs from design/stitch-urls.json if present (per confronto con prototipo Stitch)
$urlsFile = Join-Path $DesignRoot 'stitch-urls.json'
if (Test-Path $urlsFile) {
    try {
        $urls = Get-Content $urlsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $urls.PSObject.Properties | ForEach-Object {
            if ($_.Value -and [string]::IsNullOrWhiteSpace($_.Value) -eq $false) {
                Set-Item -Path "env:$($_.Name)" -Value $_.Value.Trim()
            }
        }
        Write-Host "Loaded URLs from stitch-urls.json"
    } catch {
        Write-Warning "Could not load stitch-urls.json: $_"
    }
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

# Personal Info Settings (screen ID 0f594d4c05da4c8aa79172ab31ce8790)
$PersonalInfoScreenshotUrl = $env:STITCH_PERSONAL_INFO_SCREENSHOT_URL
$PersonalInfoHtmlUrl = $env:STITCH_PERSONAL_INFO_HTML_URL

# Subscription Settings (screen ID 1224a49f9c5849fcb205e965ebc0b9a4)
$SubscriptionScreenshotUrl = $env:STITCH_SUBSCRIPTION_SCREENSHOT_URL
$SubscriptionHtmlUrl = $env:STITCH_SUBSCRIPTION_HTML_URL

# Simplified App Settings (screen ID 8ab8a84172594c1c9911b5762e2a7257)
$AppSettingsScreenshotUrl = $env:STITCH_APP_SETTINGS_SCREENSHOT_URL
$AppSettingsHtmlUrl = $env:STITCH_APP_SETTINGS_HTML_URL

# Empty Customer List Page (screen ID 3d09f0f5b58f4867990e02be11ffc7d2)
$EmptyCustomerListScreenshotUrl = $env:STITCH_EMPTY_CUSTOMER_LIST_SCREENSHOT_URL
$EmptyCustomerListHtmlUrl = $env:STITCH_EMPTY_CUSTOMER_LIST_HTML_URL

# Customer Creation Page (screen ID 534f6e3664244ba59196220f2909eb46)
$CustomerCreationScreenshotUrl = $env:STITCH_CUSTOMER_CREATION_SCREENSHOT_URL
$CustomerCreationHtmlUrl = $env:STITCH_CUSTOMER_CREATION_HTML_URL

# Customer Detail Page (screen ID 7a7f3b47bfa1435381554959ca9b72e7)
$CustomerDetailScreenshotUrl = $env:STITCH_CUSTOMER_DETAIL_SCREENSHOT_URL
$CustomerDetailHtmlUrl = $env:STITCH_CUSTOMER_DETAIL_HTML_URL

# Customer List Page (Populated) (screen ID 92b1ea1864184682b142aa8ffea211f8)
$CustomerListPopulatedScreenshotUrl = $env:STITCH_CUSTOMER_LIST_POPULATED_SCREENSHOT_URL
$CustomerListPopulatedHtmlUrl = $env:STITCH_CUSTOMER_LIST_POPULATED_HTML_URL

# Coach Dashboard (screen ID 285387f9d39c459a989d6060a1c486b0)
$CoachDashboardScreenshotUrl = $env:STITCH_COACH_DASHBOARD_SCREENSHOT_URL
$CoachDashboardHtmlUrl = $env:STITCH_COACH_DASHBOARD_HTML_URL

# Coach Dashboard alt (screen ID bdda2a99124441a98b3ce224cb25a240)
$CoachDashboard2ScreenshotUrl = $env:STITCH_COACH_DASHBOARD_2_SCREENSHOT_URL
$CoachDashboard2HtmlUrl = $env:STITCH_COACH_DASHBOARD_2_HTML_URL

# Forgot Password (screen ID 3563377ad3864dfca42385fcd5ea0840)
$ForgotPasswordScreenshotUrl = $env:STITCH_FORGOT_PASSWORD_SCREENSHOT_URL
$ForgotPasswordHtmlUrl = $env:STITCH_FORGOT_PASSWORD_HTML_URL

# Forgot Password alt (screen ID ca0f426fda0344b1abcb477319f36080)
$ForgotPassword2ScreenshotUrl = $env:STITCH_FORGOT_PASSWORD_2_SCREENSHOT_URL
$ForgotPassword2HtmlUrl = $env:STITCH_FORGOT_PASSWORD_2_HTML_URL

# Workout Builder (screen ID 3511e408240c40e293d5cbc768272806)
$WorkoutBuilderScreenshotUrl = $env:STITCH_WORKOUT_BUILDER_SCREENSHOT_URL
$WorkoutBuilderHtmlUrl = $env:STITCH_WORKOUT_BUILDER_HTML_URL

# Workout Builder - Intuitive Super Set Linking (screen ID 7ce630e5879044e7bdc10852d9b5adb1)
$IntuitiveSupersetScreenshotUrl = $env:STITCH_INTUITIVE_SUPERSET_SCREENSHOT_URL
$IntuitiveSupersetHtmlUrl = $env:STITCH_INTUITIVE_SUPERSET_HTML_URL

# Programs Library (screen ID 319b1461dde3426fb5798fef7fa1945d)
$ProgramsLibraryScreenshotUrl = $env:STITCH_PROGRAMS_LIBRARY_SCREENSHOT_URL
$ProgramsLibraryHtmlUrl = $env:STITCH_PROGRAMS_LIBRARY_HTML_URL

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
if ($PersonalInfoScreenshotUrl -and $PersonalInfoHtmlUrl) {
    if (Download-File -Url $PersonalInfoScreenshotUrl -OutPath (Join-Path $AssetsRoot 'personal-info-settings.png')) { $ok++ }
    if (Download-File -Url $PersonalInfoHtmlUrl -OutPath (Join-Path $AssetsRoot 'personal-info-settings.html')) { $ok++ }
} else { Write-Host "Personal Info Settings: set STITCH_PERSONAL_INFO_SCREENSHOT_URL and STITCH_PERSONAL_INFO_HTML_URL." }
if ($SubscriptionScreenshotUrl -and $SubscriptionHtmlUrl) {
    if (Download-File -Url $SubscriptionScreenshotUrl -OutPath (Join-Path $AssetsRoot 'subscription-settings.png')) { $ok++ }
    if (Download-File -Url $SubscriptionHtmlUrl -OutPath (Join-Path $AssetsRoot 'subscription-settings.html')) { $ok++ }
} else { Write-Host "Subscription Settings: set STITCH_SUBSCRIPTION_SCREENSHOT_URL and STITCH_SUBSCRIPTION_HTML_URL." }
if ($AppSettingsScreenshotUrl -and $AppSettingsHtmlUrl) {
    if (Download-File -Url $AppSettingsScreenshotUrl -OutPath (Join-Path $AssetsRoot 'app-settings.png')) { $ok++ }
    if (Download-File -Url $AppSettingsHtmlUrl -OutPath (Join-Path $AssetsRoot 'app-settings.html')) { $ok++ }
} else { Write-Host "Simplified App Settings: set STITCH_APP_SETTINGS_SCREENSHOT_URL and STITCH_APP_SETTINGS_HTML_URL." }
if ($EmptyCustomerListScreenshotUrl -and $EmptyCustomerListHtmlUrl) {
    if (Download-File -Url $EmptyCustomerListScreenshotUrl -OutPath (Join-Path $AssetsRoot 'empty-customer-list.png')) { $ok++ }
    if (Download-File -Url $EmptyCustomerListHtmlUrl -OutPath (Join-Path $AssetsRoot 'empty-customer-list.html')) { $ok++ }
} else { Write-Host "Empty Customer List: set STITCH_EMPTY_CUSTOMER_LIST_SCREENSHOT_URL and STITCH_EMPTY_CUSTOMER_LIST_HTML_URL." }
if ($CustomerCreationScreenshotUrl -and $CustomerCreationHtmlUrl) {
    if (Download-File -Url $CustomerCreationScreenshotUrl -OutPath (Join-Path $AssetsRoot 'customer-creation.png')) { $ok++ }
    if (Download-File -Url $CustomerCreationHtmlUrl -OutPath (Join-Path $AssetsRoot 'customer-creation.html')) { $ok++ }
} else { Write-Host "Customer Creation: set STITCH_CUSTOMER_CREATION_SCREENSHOT_URL and STITCH_CUSTOMER_CREATION_HTML_URL." }
if ($CustomerDetailScreenshotUrl -and $CustomerDetailHtmlUrl) {
    if (Download-File -Url $CustomerDetailScreenshotUrl -OutPath (Join-Path $AssetsRoot 'customer-detail.png')) { $ok++ }
    if (Download-File -Url $CustomerDetailHtmlUrl -OutPath (Join-Path $AssetsRoot 'customer-detail.html')) { $ok++ }
} else { Write-Host "Customer Detail: set STITCH_CUSTOMER_DETAIL_SCREENSHOT_URL and STITCH_CUSTOMER_DETAIL_HTML_URL." }
if ($CustomerListPopulatedScreenshotUrl -and $CustomerListPopulatedHtmlUrl) {
    if (Download-File -Url $CustomerListPopulatedScreenshotUrl -OutPath (Join-Path $AssetsRoot 'customer-list-populated.png')) { $ok++ }
    if (Download-File -Url $CustomerListPopulatedHtmlUrl -OutPath (Join-Path $AssetsRoot 'customer-list-populated.html')) { $ok++ }
} else { Write-Host "Customer List Populated: set STITCH_CUSTOMER_LIST_POPULATED_SCREENSHOT_URL and STITCH_CUSTOMER_LIST_POPULATED_HTML_URL." }
if ($CoachDashboardScreenshotUrl -and $CoachDashboardHtmlUrl) {
    if (Download-File -Url $CoachDashboardScreenshotUrl -OutPath (Join-Path $AssetsRoot 'coach-dashboard.png')) { $ok++ }
    if (Download-File -Url $CoachDashboardHtmlUrl -OutPath (Join-Path $AssetsRoot 'coach-dashboard.html')) { $ok++ }
} else { Write-Host "Coach Dashboard: set STITCH_COACH_DASHBOARD_SCREENSHOT_URL and STITCH_COACH_DASHBOARD_HTML_URL." }
if ($CoachDashboard2ScreenshotUrl -and $CoachDashboard2HtmlUrl) {
    if (Download-File -Url $CoachDashboard2ScreenshotUrl -OutPath (Join-Path $AssetsRoot 'coach-dashboard-2.png')) { $ok++ }
    if (Download-File -Url $CoachDashboard2HtmlUrl -OutPath (Join-Path $AssetsRoot 'coach-dashboard-2.html')) { $ok++ }
} else { Write-Host "Coach Dashboard 2: set STITCH_COACH_DASHBOARD_2_SCREENSHOT_URL and STITCH_COACH_DASHBOARD_2_HTML_URL." }
if ($IntuitiveSupersetScreenshotUrl -and $IntuitiveSupersetHtmlUrl) {
    if (Download-File -Url $IntuitiveSupersetScreenshotUrl -OutPath (Join-Path $AssetsRoot 'workout-builder-intuitive-superset.png')) { $ok++ }
    if (Download-File -Url $IntuitiveSupersetHtmlUrl -OutPath (Join-Path $AssetsRoot 'workout-builder-intuitive-superset.html')) { $ok++ }
} else { Write-Host "Intuitive Super Set: set STITCH_INTUITIVE_SUPERSET_SCREENSHOT_URL and STITCH_INTUITIVE_SUPERSET_HTML_URL." }
if ($ForgotPasswordScreenshotUrl -and $ForgotPasswordHtmlUrl) {
    if (Download-File -Url $ForgotPasswordScreenshotUrl -OutPath (Join-Path $AssetsRoot 'forgot-password.png')) { $ok++ }
    if (Download-File -Url $ForgotPasswordHtmlUrl -OutPath (Join-Path $AssetsRoot 'forgot-password.html')) { $ok++ }
} else { Write-Host "Forgot Password: set STITCH_FORGOT_PASSWORD_SCREENSHOT_URL and STITCH_FORGOT_PASSWORD_HTML_URL." }
if ($ForgotPassword2ScreenshotUrl -and $ForgotPassword2HtmlUrl) {
    if (Download-File -Url $ForgotPassword2ScreenshotUrl -OutPath (Join-Path $AssetsRoot 'forgot-password-2.png')) { $ok++ }
    if (Download-File -Url $ForgotPassword2HtmlUrl -OutPath (Join-Path $AssetsRoot 'forgot-password-2.html')) { $ok++ }
} else { Write-Host "Forgot Password 2: set STITCH_FORGOT_PASSWORD_2_SCREENSHOT_URL and STITCH_FORGOT_PASSWORD_2_HTML_URL." }
if ($WorkoutBuilderScreenshotUrl -and $WorkoutBuilderHtmlUrl) {
    if (Download-File -Url $WorkoutBuilderScreenshotUrl -OutPath (Join-Path $AssetsRoot 'workout-builder.png')) { $ok++ }
    if (Download-File -Url $WorkoutBuilderHtmlUrl -OutPath (Join-Path $AssetsRoot 'workout-builder.html')) { $ok++ }
} else { Write-Host "Workout Builder: set STITCH_WORKOUT_BUILDER_SCREENSHOT_URL and STITCH_WORKOUT_BUILDER_HTML_URL." }
if ($ProgramsLibraryScreenshotUrl -and $ProgramsLibraryHtmlUrl) {
    if (Download-File -Url $ProgramsLibraryScreenshotUrl -OutPath (Join-Path $AssetsRoot 'programs-library.png')) { $ok++ }
    if (Download-File -Url $ProgramsLibraryHtmlUrl -OutPath (Join-Path $AssetsRoot 'programs-library.html')) { $ok++ }
} else { Write-Host "Programs Library: set STITCH_PROGRAMS_LIBRARY_SCREENSHOT_URL and STITCH_PROGRAMS_LIBRARY_HTML_URL." }
if ($ok -eq 0) {
    Write-Host "See powercoach-studio/design/README.md for how to obtain URLs from Stitch."
}
Write-Host "Done. Downloaded $ok file(s) to $AssetsRoot"
