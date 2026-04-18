# Hook: afterFileEdit — remind the agent to run build_runner when Drift table files change.
# Reads JSON from stdin, checks the edited file path, injects additional_context if needed.

$input_json = $input | Out-String
try {
    $data = $input_json | ConvertFrom-Json
} catch {
    Write-Output '{}'
    exit 0
}

$filePath = ""
if ($data.tool_input) {
    if ($data.tool_input.path) { $filePath = $data.tool_input.path }
}

$driftPatterns = @(
    "app_database.dart",
    "lib/core/storage/",
    "lib\core\storage\"
)

$isDriftFile = $false
foreach ($pattern in $driftPatterns) {
    if ($filePath -like "*$pattern*") {
        $isDriftFile = $true
        break
    }
}

if ($isDriftFile) {
    $response = @{
        additional_context = "IMPORTANT: You just edited a Drift database file. Remember to regenerate the code before running the app: ``dart run build_runner build --delete-conflicting-outputs``"
    } | ConvertTo-Json -Compress
    Write-Output $response
} else {
    Write-Output '{}'
}

exit 0
