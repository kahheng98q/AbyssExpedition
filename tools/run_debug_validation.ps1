param([switch]$SkipRegression, [string]$BuildDirectory = 'builds/windows/debug-panel', [string]$EvidenceDirectory, [switch]$DummyAudio)
$ErrorActionPreference = 'Stop'
$debugValidationRoot = Split-Path $PSScriptRoot -Parent
$debugEvidence = if ($EvidenceDirectory) { [IO.Path]::GetFullPath($EvidenceDirectory,$debugValidationRoot) } else { Join-Path $debugValidationRoot 'docs/validation' }
New-Item -ItemType Directory -Force $debugEvidence | Out-Null
$debugEngine = Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe'
function Invoke-DebugCheck([string]$name, [string[]]$arguments, [string]$binary = $debugEngine) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $binary
    $info.WorkingDirectory = $debugValidationRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = Join-Path $PSScriptRoot 'runtime-appdata'
    if ($DummyAudio) { $arguments = @('--audio-driver','Dummy') + $arguments }
    foreach ($argument in $arguments) { $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit(60000)) { $process.Kill($true); throw "$name watchdog expired" }
    $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $debugEvidence "$name.log"), $output)
    $code = $process.ExitCode
    $process.Dispose()
    if ($code -ne 0 -or $output -match '(?m)^(ERROR:|SCRIPT ERROR|FAIL:)') { throw "$name failed: $output" }
    Write-Output "$name PASS"
    $output -split "`n" | Where-Object { $_ -match 'SUITE|DEBUG GRAPHICAL|DEBUG RELEASE' } | Write-Output
}
if (-not $SkipRegression) {
    & (Join-Path $PSScriptRoot 'run_validation.ps1') -M2 -Graphical
}
Invoke-DebugCheck 'debug-panel' @('--headless','--path',$debugValidationRoot,'--log-file',(Join-Path $debugEvidence 'debug-panel-engine.log'),'--script','res://tests/run_tests.gd','--','--suite','debug_panel')
$captures = if ($EvidenceDirectory) { Join-Path $debugEvidence 'captures/source' } else { Join-Path $debugValidationRoot 'screenshots' }
$exportCaptures = if ($EvidenceDirectory) { Join-Path $debugEvidence 'captures/exported' } else { $captures }
New-Item -ItemType Directory -Force $captures,$exportCaptures | Out-Null
Invoke-DebugCheck 'debug-graphical' @('--path',$debugValidationRoot,'--log-file',(Join-Path $debugEvidence 'debug-graphical-engine.log'),'--script','res://tests/debug_graphical_check.gd','--','--captures',$captures)
$destination = Join-Path $debugValidationRoot $BuildDirectory
New-Item -ItemType Directory -Force $destination | Out-Null
Invoke-DebugCheck 'debug-export' @('--headless','--path',$debugValidationRoot,'--export-debug','Windows Desktop',(Join-Path $destination 'AbyssExpedition-debug.exe'))
Invoke-DebugCheck 'debug-release-export' @('--headless','--path',$debugValidationRoot,'--export-release','Windows Desktop',(Join-Path $destination 'AbyssExpedition.exe'))
$graphicalProbe = Join-Path $debugValidationRoot 'tests/debug_graphical_check.gd'
Invoke-DebugCheck 'debug-exported-graphical' @('--path',$debugValidationRoot,'--log-file',(Join-Path $debugEvidence 'debug-exported-graphical-engine.log'),'--script',$graphicalProbe,'--','--captures',$exportCaptures) (Join-Path $destination 'AbyssExpedition-debug.console.exe')
$releaseProbe = Join-Path $debugValidationRoot 'tests/debug_release_probe.gd'
Invoke-DebugCheck 'debug-release-denial' @('--headless','--path',$debugValidationRoot,'--log-file',(Join-Path $debugEvidence 'debug-release-denial-engine.log'),'--script',$releaseProbe) (Join-Path $destination 'AbyssExpedition.console.exe')
