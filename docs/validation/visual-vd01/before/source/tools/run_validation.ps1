param([switch]$Graphical, [switch]$Export, [switch]$M2 = $true, [switch]$M3, [switch]$M4, [string]$EvidenceDirectory, [string[]]$OnlySuites = @(), [switch]$DummyAudio)
$ErrorActionPreference = 'Stop'
$validationRoot = Split-Path $PSScriptRoot -Parent
$godotBinary = Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe'
if ($env:ABYSS_GODOT_EXE) { $godotBinary = $env:ABYSS_GODOT_EXE }
if (-not (Test-Path -LiteralPath $godotBinary)) { throw 'Godot binary missing. Set ABYSS_GODOT_EXE to Godot 4.5 console.' }
$godotBinary = (Resolve-Path -LiteralPath $godotBinary).Path
$validationDirectory = Join-Path $validationRoot 'docs/validation'
if ($EvidenceDirectory) { $validationDirectory = [IO.Path]::GetFullPath($EvidenceDirectory, $validationRoot) }
$runtimeData = Join-Path $PSScriptRoot 'runtime-appdata'
New-Item -ItemType Directory -Force $validationDirectory,$runtimeData | Out-Null
function Invoke-Check([string]$name, [string[]]$arguments, [int]$expectedExit = 0, [int]$timeout = 60, [string]$executable = $godotBinary) {
    if ($DummyAudio) { $arguments = @('--audio-driver','Dummy') + $arguments }
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $executable
    $info.WorkingDirectory = $validationRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = $runtimeData
    foreach ($argument in $arguments) { $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($timeout * 1000)) { $process.Kill($true); throw "$name watchdog expired" }
    $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $validationDirectory "$name.log"), $output)
    $exitCode = $process.ExitCode
    $process.Dispose()
    if ($exitCode -ne $expectedExit -or $output -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:|Debugger Break)') { throw "$name failed (exit $exitCode):`n$output" }
    Write-Output "$name PASS (exit $exitCode)"
    $output -split "`n" | Where-Object { $_ -match 'SUITE|CONTENT:|AUTOPLAY|GRAPHICAL:|BENCH ' } | Write-Output
}
$version = & $godotBinary --version
if ($version.Trim() -ne '4.5.stable.official.876b29033') { throw "Engine pin mismatch: $version" }
Write-Output "ABYSS_GODOT_EXE=$godotBinary; engine=$version"
Invoke-Check 'import' @('--headless','--editor','--import','--path',$validationRoot)
Invoke-Check 'parse-runner' @('--headless','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'parse-engine.log'),'--check-only','--script','res://tests/run_tests.gd')
Invoke-Check 'content' @('--headless','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'content-engine.log'),'--script','res://tests/validate_content.gd')
$suites = @('unit','scene_smoke','integration_m1','replay','full_run')
if ($M2) { $suites += @('progression','persistence','abilities','integration_m2') }
if ($M3 -or $M4) { $suites += @('recruitment','integration_m3') }
if ($M4) { $suites += @('integration_m4') }
if ($OnlySuites.Count -gt 0) { $suites = $OnlySuites }
foreach ($suite in $suites) {
    Invoke-Check $suite @('--headless','--fixed-fps','60','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory "$suite-engine.log"),'--script','res://tests/run_tests.gd','--','--suite',$suite)
}
Invoke-Check 'reject-unknown-suite' @('--headless','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'negative-engine.log'),'--script','res://tests/run_tests.gd','--','--suite','missing_suite') 2
Invoke-Check 'reject-invalid-seed' @('--headless','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'negative-engine.log'),'--script','res://tests/run_tests.gd','--','--seed','2147483648') 2
if ($Graphical) {
    if ($M4) { Invoke-Check 'm4-graphical' @('--path',$validationRoot,'--script','res://tests/m4_graphical_check.gd') }
    Invoke-Check 'graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'graphical-engine.log'),'--script','res://tests/graphical_check.gd')
    if ($M2) { Invoke-Check 'm2-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'm2-graphical-engine.log'),'--script','res://tests/m2_graphical_check.gd') }
    if ($M3 -or $M4) { Invoke-Check 'm3-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'm3-graphical-engine.log'),'--script','res://tests/m3_graphical_check.gd') }
}
if ($Export) {
    $exportDirectory = Join-Path $validationRoot $(if ($M4) { 'builds/windows/m4' } elseif ($M3) { 'builds/windows/m3' } else { 'builds/windows/m2' })
    New-Item -ItemType Directory -Force $exportDirectory | Out-Null
    Invoke-Check 'export' @('--headless','--path',$validationRoot,'--export-release','Windows Desktop',(Join-Path $exportDirectory 'AbyssExpedition.exe'))
    if ($Graphical -and $M2) {
        $milestoneId = if ($M4) { 'm4' } elseif ($M3) { 'm3' } else { 'm2' }
        $harness = [IO.File]::ReadAllText((Join-Path $validationRoot "tests/${milestoneId}_graphical_check.gd"))
        $capture = [IO.File]::ReadAllText((Join-Path $validationRoot 'tests/error_capture.gd'))
        $capture = ($capture -split "\r?\n" | ForEach-Object { "`t" + $_ }) -join "`n"
        $harness = $harness.Replace('extends SceneTree', ("extends SceneTree`n`nclass ErrorCapture:`n" + $capture))
        $harness = $harness.Replace('preload("res://tests/error_capture.gd").new()', 'ErrorCapture.new()')
        $screenshots = $validationRoot.Replace('\','/') + "/screenshots/$milestoneId-release-"
        $harness = $harness.Replace(('"res://screenshots/' + $milestoneId + '-"'), ('"' + $screenshots + '"'))
        $harnessPath = Join-Path $PSScriptRoot "${milestoneId}_release_graphical.gd"
        [IO.File]::WriteAllText($harnessPath, $harness)
        Invoke-Check "$milestoneId-release-graphical" @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory "$milestoneId-release-graphical-engine.log"),'--script',$harnessPath) 0 60 (Join-Path $exportDirectory 'AbyssExpedition.console.exe')
    }
}
