# Fetch Stitch project "Landing Page" screens via @_davideast/stitch-mcp CLI.
# Uses: get_screen_image, get_screen_code (requires auth: npx @_davideast/stitch-mcp init)
# Run from repo root: .\powercoach-studio\scripts\fetch-stitch-via-mcp-cli.ps1

$ErrorActionPreference = 'Stop'
$ProjectRoot = if ($PSScriptRoot) {
    $scripts = Split-Path $PSScriptRoot -Parent
    Split-Path $scripts -Parent
} else { $env:PWD }
$StudioRoot = Join-Path $ProjectRoot 'powercoach-studio'
$DesignRoot = Join-Path $StudioRoot 'design'
$AssetsRoot = Join-Path $DesignRoot 'stitch-assets'

$ProjectId = '13531110169329089006'
$Screens = @(
    @{ Name = 'Simplified Startup Landing Page'; Id = '0b414c91bc8d406ea47ac2570d7b51df'; File = 'simplified-landing' },
    @{ Name = 'Personal Info Settings';         Id = '0f594d4c05da4c8aa79172ab31ce8790'; File = 'personal-info-settings' },
    @{ Name = 'Subscription Settings';          Id = '1224a49f9c5849fcb205e965ebc0b9a4'; File = 'subscription-settings' },
    @{ Name = 'Login Page';                     Id = '3e212f412ed849a9b6bcfc0772cf15fd'; File = 'login' },
    @{ Name = 'Updated Coach Profile';          Id = '5863bd21319d467b828ad322f8670305'; File = 'coach-profile' },
    @{ Name = 'Simplified Registration Page';   Id = '76b61a47b6324d31bfd4957cd921aaee'; File = 'simplified-registration' },
    @{ Name = 'Simplified App Settings';        Id = '8ab8a84172594c1c9911b5762e2a7257'; File = 'app-settings' }
)

if (-not (Test-Path $AssetsRoot)) { New-Item -ItemType Directory -Path $AssetsRoot -Force | Out-Null }

function Invoke-StitchTool {
    param ([string]$ToolName, [string]$ScreenId)
    # Build JSON by hand (camelCase required by Stitch API); pass as separate arg to avoid quote stripping
    $inputJson = '{"projectId":"' + $ProjectId + '","screenId":"' + $ScreenId + '"}'
    try {
        $out = & npx -y @_davideast/stitch-mcp tool $ToolName '-d' $inputJson 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning ($out | Out-String)
            return $null
        }
        return ($out | Out-String)
    } catch {
        Write-Warning "Tool $ToolName screen $ScreenId : $_"
        return $null
    }
}

function Save-ToolOutput {
    param ([string]$Raw, [string]$OutPath, [string]$Kind)
    if (-not $Raw -or $Raw.Trim().Length -eq 0) { return $false }
    $trimmed = $Raw.Trim()
    # JSON with content/base64/data field
    if ($trimmed.StartsWith('{')) {
        try {
            $obj = $trimmed | ConvertFrom-Json
            $content = $obj.content
            if (-not $content) { $content = $obj.base64 }
            if (-not $content) { $content = $obj.data }
            if ($content) {
                if ($Kind -eq 'image') {
                    [System.Convert]::FromBase64String($content) | Set-Content -Path $OutPath -Encoding Byte
                } else {
                    [System.IO.File]::WriteAllText($OutPath, $content, [System.Text.UTF8Encoding]::new($false))
                }
                return $true
            }
        } catch { }
    }
    # Raw base64 (image)
    if ($Kind -eq 'image' -and $trimmed.Length -gt 100) {
        try {
            [System.Convert]::FromBase64String($trimmed) | Set-Content -Path $OutPath -Encoding Byte
            return $true
        } catch { }
    }
    # Raw HTML/text
    [System.IO.File]::WriteAllText($OutPath, $trimmed, [System.Text.UTF8Encoding]::new($false))
    return $true
}

$env:STITCH_PROJECT_ID = $ProjectId
$countOk = 0
foreach ($s in $Screens) {
    Write-Host "Fetching: $($s.Name) ($($s.File))..."
    $imgPath = Join-Path $AssetsRoot ($s.File + '.png')
    $htmlPath = Join-Path $AssetsRoot ($s.File + '.html')
    $imgRaw = Invoke-StitchTool -ToolName 'get_screen_image' -ScreenId $s.Id
    if ($imgRaw -and (Save-ToolOutput -Raw $imgRaw -OutPath $imgPath -Kind 'image')) { $countOk++; Write-Host "  -> $imgPath" }
    $codeRaw = Invoke-StitchTool -ToolName 'get_screen_code' -ScreenId $s.Id
    if ($codeRaw -and (Save-ToolOutput -Raw $codeRaw -OutPath $htmlPath -Kind 'html')) { $countOk++; Write-Host "  -> $htmlPath" }
}
Write-Host "Done. Saved $countOk file(s) to $AssetsRoot"
if ($countOk -eq 0) {
    Write-Host "Run once: npx @_davideast/stitch-mcp init"
}
