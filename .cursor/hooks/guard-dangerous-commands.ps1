# Hook: beforeShellExecution — warn before destructive Flutter/Git commands.
# Returns "ask" permission for commands that are hard to undo.

$input_json = $input | Out-String
try {
    $data = $input_json | ConvertFrom-Json
} catch {
    Write-Output '{"permission":"allow"}'
    exit 0
}

$command = ""
if ($data.command) { $command = $data.command.ToLower() }

$dangerousPatterns = @(
    "flutter clean",
    "git reset --hard",
    "git push --force",
    "git push -f",
    "git rebase",
    "drop table",
    "truncate table",
    "rm -rf",
    "remove-item.*recurse.*force"
)

$isDangerous = $false
$matchedPattern = ""
foreach ($pattern in $dangerousPatterns) {
    if ($command -match $pattern) {
        $isDangerous = $true
        $matchedPattern = $pattern
        break
    }
}

if ($isDangerous) {
    $response = @{
        permission    = "ask"
        user_message  = "This command matches a potentially destructive pattern ('$matchedPattern'). Review carefully before proceeding."
        agent_message = "Flagged as destructive command — user confirmation required."
    } | ConvertTo-Json -Compress
    Write-Output $response
} else {
    Write-Output '{"permission":"allow"}'
}

exit 0
