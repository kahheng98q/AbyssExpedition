param([switch]$SkipExport)
$ErrorActionPreference = 'Stop'
$qualityRoot = Split-Path $PSScriptRoot -Parent
$qualityEvidence = Join-Path $qualityRoot 'docs/validation/quality-20261018'
$qualityShots = Join-Path $qualityRoot 'screenshots/quality-20261018'
$qualityHarness = Join-Path $PSScriptRoot 'quality-harness'
$qualityBuild = Join-Path $qualityRoot 'builds/windows/quality-20261018'
$qualityEngine = Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe'
New-Item -ItemType Directory -Force $qualityEvidence,$qualityShots,$qualityHarness,$qualityBuild | Out-Null
function Invoke-Quality([string]$name, [string]$binary, [string[]]$arguments, [int]$timeout=90) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $binary
    $info.WorkingDirectory = $qualityRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = Join-Path $PSScriptRoot 'runtime-quality'
    foreach ($arg in (@('--path',$qualityRoot,'--audio-driver','Dummy','--log-file',(Join-Path $qualityEvidence "$name-engine.log")) + $arguments)) { $info.ArgumentList.Add($arg) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($timeout*1000)) { $process.Kill($true); throw "$name watchdog expired" }
    $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $qualityEvidence "$name.log"), $output)
    $code = $process.ExitCode
    $process.Dispose()
    if ($code -ne 0 -or $output -match '(?m)^(ERROR:|SCRIPT ERROR|FAIL:)') { throw "$name failed: $output" }
    Write-Output "$name PASS"
    $output -split "`n" | Where-Object { $_ -match 'GRAPHICAL|QUALITY STATE|QUALITY CAPTURE|DEBUG RELEASE|SUITE' } | Write-Output
}
Invoke-Quality 'final-feedback' $qualityEngine @('--headless','--fixed-fps','60','--script','res://tests/run_tests.gd','--','--suite','combat_feedback')
Invoke-Quality 'final-debug-native' $qualityEngine @('--headless','--fixed-fps','60','--script','res://tests/run_tests.gd','--','--suite','debug_panel')
Invoke-Quality 'after' $qualityEngine @('--fixed-fps','60','--script','res://tests/quality_capture.gd','--','after')
Invoke-Quality 'gallery-final' $qualityEngine @('--script','res://tests/quality_gallery.gd')
$errorSource = [IO.File]::ReadAllText((Join-Path $qualityRoot 'tests/error_capture.gd'))
$errorSource = ($errorSource -split "\r?\n" | ForEach-Object { "`t" + $_ }) -join "`n"
foreach ($id in @('m1','m2','m3','m4')) {
    $sourceFile = if ($id -eq 'm1') { 'tests/graphical_check.gd' } else { "tests/${id}_graphical_check.gd" }
    $source = [IO.File]::ReadAllText((Join-Path $qualityRoot $sourceFile))
    $source = $source.Replace('res://screenshots/',($qualityShots.Replace('\','/') + '/source-'))
    $path = Join-Path $qualityHarness "$id-source.gd"
    [IO.File]::WriteAllText($path,$source)
    Invoke-Quality "$id-source" $qualityEngine @('--script',$path)
    if ($id -ne 'm1') {
        $release = $source.Replace('/source-','/release-')
        $release = $release.Replace('extends SceneTree',("extends SceneTree`n`nclass ErrorCapture:`n" + $errorSource))
        $release = $release.Replace('preload("res://tests/error_capture.gd").new()','ErrorCapture.new()')
        [IO.File]::WriteAllText((Join-Path $qualityHarness "$id-release.gd"),$release)
    }
}
Invoke-Quality 'debug-source' $qualityEngine @('--script','res://tests/debug_graphical_check.gd','--','--captures',$qualityShots)
if (-not $SkipExport) {
    Invoke-Quality 'export' $qualityEngine @('--headless','--export-release','Windows Desktop',(Join-Path $qualityBuild 'AbyssExpedition.exe'))
    $releaseBinary = Join-Path $qualityBuild 'AbyssExpedition.console.exe'
    foreach ($id in @('m2','m3','m4')) {
        Invoke-Quality "$id-release" $releaseBinary @('--script',(Join-Path $qualityHarness "$id-release.gd"))
    }
    Invoke-Quality 'debug-release-denial' $releaseBinary @('--headless','--script','res://tests/debug_release_probe.gd')
    Get-FileHash -LiteralPath (Join-Path $qualityBuild 'AbyssExpedition.exe') -Algorithm SHA256 | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $qualityEvidence 'build-sha256.json')
}
