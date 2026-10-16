$ErrorActionPreference = 'Stop'
$verificationRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$verificationFiles = @(
    'README.md',
    'docs/IMPLEMENTATION_OVERVIEW.md',
    'docs/game-development-dashboard.html',
    'docs/development.md',
    'docs/benchmarks/m4.md',
    'docs/validation/m4-gate.md',
    'docs/validation/debug-panel.md',
    'docs/validation/verification-2026-10-15.md',
    'specs/001-abyss-expedition-mvp/tasks.md'
)
$verificationFailures = [Collections.Generic.List[string]]::new()
$verificationResults = @()
foreach ($verificationFile in $verificationFiles) {
    $verificationPath = Join-Path $verificationRoot $verificationFile
    $verificationContent = [IO.File]::ReadAllText($verificationPath)
    $verificationHtml = $verificationFile.EndsWith('.html')
    $verificationPattern = if ($verificationHtml) { '(?:href|src)\s*=\s*"(?<target>[^"]+)"' } else { '\]\((?<target>[^)\r\n]+)\)' }
    $verificationLinks = [regex]::Matches($verificationContent, $verificationPattern)
    $verificationCount = 0
    foreach ($verificationLink in $verificationLinks) {
        $verificationTarget = $verificationLink.Groups['target'].Value
        if ($verificationTarget -match '^(https?:|mailto:|app:|codex:)') { continue }
        if ($verificationTarget.StartsWith('#')) {
            if ($verificationHtml -and -not $verificationContent.Contains(('id="' + $verificationTarget.Substring(1) + '"'))) {
                $verificationFailures.Add("$verificationFile : missing fragment $verificationTarget")
            }
            continue
        }
        $verificationTarget = ($verificationTarget -split '#',2)[0]
        $verificationResolved = [IO.Path]::GetFullPath((Join-Path (Split-Path $verificationPath -Parent) $verificationTarget))
        $verificationCount += 1
        if (-not (Test-Path -LiteralPath $verificationResolved)) {
            $verificationFailures.Add("$verificationFile : missing $verificationTarget")
        }
    }
    if ($verificationHtml) {
        foreach ($verificationImage in [regex]::Matches($verificationContent, '<img\b[^>]*>')) {
            if ($verificationImage.Value -notmatch 'alt="[^"]+"') { $verificationFailures.Add('Image missing nonempty alt') }
        }
        if ($verificationContent -match '(?:src|href)\s*=\s*["''](?:https?:)?//') {
            $verificationFailures.Add('Dashboard has a remote dependency')
        }
        $verificationIds = [regex]::Matches($verificationContent, '\bid="(?<id>[^"]+)"') | ForEach-Object { $_.Groups['id'].Value }
        if (($verificationIds | Sort-Object -Unique).Count -ne $verificationIds.Count) { $verificationFailures.Add('Dashboard has duplicate IDs') }
    }
    $verificationResults += [ordered]@{ file = $verificationFile; local_targets_checked = $verificationCount }
}
$verificationSummary = [ordered]@{ files = $verificationResults; failures = @($verificationFailures); failure_count = $verificationFailures.Count }
$verificationSummary | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 (Join-Path $PSScriptRoot 'documentation-checks.json')
$verificationSummary | ConvertTo-Json -Depth 5
if ($verificationFailures.Count -gt 0) { exit 1 }
exit 0
