param([switch]$Graphical, [switch]$Export, [switch]$M2 = $true, [switch]$M3, [switch]$M4, [string]$EvidenceDirectory, [string[]]$OnlySuites = @(), [switch]$DummyAudio, [string]$BuildDirectory)
$ErrorActionPreference = 'Stop'
$validationRoot = Split-Path $PSScriptRoot -Parent
$godotBinary = Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe'
if ($env:ABYSS_GODOT_EXE) { $godotBinary = $env:ABYSS_GODOT_EXE }
if (-not (Test-Path -LiteralPath $godotBinary)) { throw 'Godot binary missing. Set ABYSS_GODOT_EXE to Godot 4.5 console.' }
$godotBinary = (Resolve-Path -LiteralPath $godotBinary).Path
$validationDirectory = Join-Path $validationRoot 'docs/validation'
if ($EvidenceDirectory) { $validationDirectory = [IO.Path]::GetFullPath($(if ([IO.Path]::IsPathRooted($EvidenceDirectory)) { $EvidenceDirectory } else { Join-Path $validationRoot $EvidenceDirectory })) }
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
    $info.EnvironmentVariables['APPDATA'] = $runtimeData
    # Windows argv quoting for .NET Framework as well as modern PowerShell.
    $info.Arguments = ($arguments | ForEach-Object {
        $quoted = [regex]::Replace([string]$_, '(\\*)"', '$1$1\"')
        $quoted = [regex]::Replace($quoted, '(\\+)$', '$1$1')
        '"' + $quoted + '"'
    }) -join ' ' 
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $timedOut = -not $process.WaitForExit($timeout * 1000)
    if ($timedOut) { $process.Kill(); $process.WaitForExit() }
    $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $validationDirectory "$name.log"), $output)
    $exitCode = $process.ExitCode
    $process.Dispose()
    if ($timedOut) { throw "$name watchdog expired; stdout/stderr and partial evidence retained" }
    if ($exitCode -ne $expectedExit -or $output -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:|Debugger Break)') { throw "$name failed (exit $exitCode):`n$output" }
    Write-Output "$name PASS (exit $exitCode)"
    $output -split "`n" | Where-Object { $_ -match 'SUITE|CONTENT:|AUTOPLAY|GRAPHICAL:|BENCH ' } | Write-Output
}
function New-SwordHarness([string]$filename) {
    $harness = [IO.File]::ReadAllText((Join-Path $validationRoot "tests/$filename.gd"))
    $capture = [IO.File]::ReadAllText((Join-Path $validationRoot 'tests/error_capture.gd'))
    $capture = ($capture -split "\r?\n" | ForEach-Object { "`t" + $_ }) -join "`n"
    $harness = $harness.Replace('extends SceneTree', ("extends SceneTree`n`nclass ErrorCapture:`n" + $capture))
    $harness = $harness.Replace('preload("res://tests/error_capture.gd").new()', 'ErrorCapture.new()')
    $harnessPath = Join-Path $validationDirectory "$filename-external.gd"
    [IO.File]::WriteAllText($harnessPath, $harness)
    return $harnessPath
}
function Invoke-SwordRealtime([string]$kind, [string]$executable = $godotBinary) {
    $harnessPath = New-SwordHarness 'sword_preview_realtime_check'
    $combinations = @(@{hostMode='normal';speed=1})
    if ($kind -ne 'release') { $combinations += @(@{hostMode='dev';speed=1},@{hostMode='dev';speed=2},@{hostMode='dev';speed=4}) }
    foreach ($combination in $combinations) {
        $id = "sword-realtime-$kind-$($combination.hostMode)-$($combination.speed)"
        $target = Join-Path $validationDirectory $id
        if (Test-Path -LiteralPath $target) { throw "Realtime evidence already exists: $target" }
        New-Item -ItemType Directory $target | Out-Null
        [ordered]@{kind=$kind;host=$combination.hostMode;speed=$combination.speed;executable=$executable;executable_sha256=(Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash;fixture_sha256=(Get-FileHash -LiteralPath (Join-Path $validationRoot 'tests/sword_preview_realtime_check.gd') -Algorithm SHA256).Hash;clock='production monotonic';wall_deadline_seconds=180} | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $target 'invocation.json')
        Write-Output "$id START (ten real cycles, native focus, 180-second watchdog)"
        Invoke-Check $id @('--path',$validationRoot,'--log-file',(Join-Path $target 'engine.log'),'--script',$harnessPath,'--','--host',$combination.hostMode,'--speed',[string]$combination.speed,'--kind',$kind,'--output',$target) 0 180 $executable
    }
}
$version = & $godotBinary --version
if ($version.Trim() -ne '4.5.stable.official.876b29033') { throw "Engine pin mismatch: $version" }
Write-Output "ABYSS_GODOT_EXE=$godotBinary; engine=$version"
Invoke-Check 'import' @('--headless','--editor','--import','--path',$validationRoot)
Invoke-Check 'parse-runner' @('--headless','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'parse-engine.log'),'--check-only','--script','res://tests/run_tests.gd')
Invoke-Check 'content' @('--headless','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'content-engine.log'),'--script','res://tests/validate_content.gd')
$suites = @('unit','scene_smoke','integration_m1','replay','full_run','pacing','combat_feedback','combat_audio')
if ($M2) { $suites += @('run_promotion','progression','persistence','abilities','integration_m2') }
if ($M3 -or $M4) { $suites += @('recruitment','integration_m3') }
if ($M4) { $suites += @('integration_m4') }
if ($OnlySuites.Count -gt 0) { $suites = $OnlySuites }
# Protected development feature: even focused milestone/polish runs keep this gate.
if ($suites -notcontains 'debug_panel') { $suites += 'debug_panel' }
foreach ($suite in $suites) {
    Invoke-Check $suite @('--headless','--fixed-fps','60','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory "$suite-engine.log"),'--script','res://tests/run_tests.gd','--','--suite',$suite)
}
Invoke-Check 'reject-unknown-suite' @('--headless','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'negative-engine.log'),'--script','res://tests/run_tests.gd','--','--suite','missing_suite') 2
Invoke-Check 'reject-invalid-seed' @('--headless','--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'negative-engine.log'),'--script','res://tests/run_tests.gd','--','--seed','2147483648') 2
if ($Graphical) {
    $gameplayCaptures = Join-Path $validationDirectory 'gameplay-captures'
    New-Item -ItemType Directory -Force $gameplayCaptures | Out-Null
    $debugCaptures = Join-Path $validationDirectory 'debug-captures'
    New-Item -ItemType Directory -Force $debugCaptures | Out-Null
    Invoke-Check 'run-promotion-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'run-promotion-graphical-engine.log'),'--script','res://tests/run_promotion_graphical_check.gd','--','--captures',$gameplayCaptures)
    Invoke-Check 'pacing-audio-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'pacing-audio-graphical-engine.log'),'--script','res://tests/pacing_audio_graphical_check.gd','--','--captures',$gameplayCaptures)
    $swordCaptures = Join-Path $validationDirectory 'sword-captures'
    New-Item -ItemType Directory -Force $swordCaptures | Out-Null
    Invoke-Check 'sword-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'sword-graphical-engine.log'),'--script','res://tests/sword_identity_graphical_check.gd','--','--captures',$swordCaptures)
    Invoke-Check 'debug-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'debug-graphical-engine.log'),'--script','res://tests/debug_graphical_check.gd','--','--captures',$debugCaptures)
    if ($M4) {
        $m4Captures = Join-Path $validationDirectory 'm4-captures'
        New-Item -ItemType Directory -Force $m4Captures | Out-Null
        Invoke-Check 'm4-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'm4-graphical-engine.log'),'--script','res://tests/m4_graphical_check.gd','--','--captures',$m4Captures)
    }
    Invoke-Check 'graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'graphical-engine.log'),'--script','res://tests/graphical_check.gd','--','--captures',$gameplayCaptures)
    if ($M2) { Invoke-Check 'm2-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'm2-graphical-engine.log'),'--script','res://tests/m2_graphical_check.gd','--','--captures',$gameplayCaptures) }
    if ($M3 -or $M4) { Invoke-Check 'm3-graphical' @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory 'm3-graphical-engine.log'),'--script','res://tests/m3_graphical_check.gd','--','--captures',$gameplayCaptures) }
}
if ($Export) {
    $exportDirectory = Join-Path $validationRoot $(if ($M4) { 'builds/windows/m4' } elseif ($M3) { 'builds/windows/m3' } else { 'builds/windows/m2' })
    if ($BuildDirectory) {
        $exportDirectory = [IO.Path]::GetFullPath($(if ([IO.Path]::IsPathRooted($BuildDirectory)) { $BuildDirectory } else { Join-Path $validationRoot $BuildDirectory }))
        if (Test-Path -LiteralPath $exportDirectory) { throw 'BuildDirectory already exists; use a new directory to preserve prior builds.' }
    }
    New-Item -ItemType Directory -Force $exportDirectory | Out-Null
    Invoke-Check 'export' @('--headless','--path',$validationRoot,'--export-release','Windows Desktop',(Join-Path $exportDirectory 'AbyssExpedition.exe'))
    Invoke-Check 'debug-release-denial' @('--headless','--path',$validationRoot,'--script',(Join-Path $validationRoot 'tests/debug_release_probe.gd')) 0 60 (Join-Path $exportDirectory 'AbyssExpedition.console.exe')
    Invoke-Check 'debug-export' @('--headless','--path',$validationRoot,'--export-debug','Windows Desktop',(Join-Path $exportDirectory 'AbyssExpedition-debug.exe'))
    if ($Graphical) {
        Invoke-Check 'debug-exported-graphical' @('--path',$validationRoot,'--script',(Join-Path $validationRoot 'tests/debug_graphical_check.gd'),'--','--captures',$debugCaptures) 0 60 (Join-Path $exportDirectory 'AbyssExpedition-debug.console.exe')
    }
    if ($Graphical) {
        $promotionHarness = New-SwordHarness 'run_promotion_graphical_check'
        foreach ($kind in @('debug','release')) {
            $exeName = if ($kind -eq 'debug') { 'AbyssExpedition-debug.console.exe' } else { 'AbyssExpedition.console.exe' }
            $promotionCaptures = Join-Path $validationDirectory "promotion-$kind-captures"
            New-Item -ItemType Directory $promotionCaptures | Out-Null
            Invoke-Check "promotion-$kind-graphical" @('--path',$validationRoot,'--script',$promotionHarness,'--','--captures',$promotionCaptures) 0 60 (Join-Path $exportDirectory $exeName)
        }
        $swordExportHarness = New-SwordHarness 'sword_identity_graphical_check'
        foreach ($kind in @('debug','release')) {
            $exeName = if ($kind -eq 'debug') { 'AbyssExpedition-debug.console.exe' } else { 'AbyssExpedition.console.exe' }
            $swordExportCaptures = Join-Path $validationDirectory "sword-$kind-captures"
            New-Item -ItemType Directory $swordExportCaptures | Out-Null
            Invoke-Check "sword-$kind-graphical" @('--path',$validationRoot,'--script',$swordExportHarness,'--','--captures',$swordExportCaptures) 0 60 (Join-Path $exportDirectory $exeName)
        }
    }
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
        $releaseCaptures = Join-Path $validationDirectory "$milestoneId-release-captures"
        New-Item -ItemType Directory -Force $releaseCaptures | Out-Null
        Invoke-Check "$milestoneId-release-graphical" @('--path',$validationRoot,'--log-file',(Join-Path $validationDirectory "$milestoneId-release-graphical-engine.log"),'--script',$harnessPath,'--','--captures',$releaseCaptures) 0 60 (Join-Path $exportDirectory 'AbyssExpedition.console.exe')
    }
}

if ($Export -and $BuildDirectory) {
    $releaseFiles = @(Get-ChildItem -LiteralPath (Join-Path $validationRoot 'scripts'),(Join-Path $validationRoot 'data'),(Join-Path $validationRoot 'scenes'),(Join-Path $validationRoot 'assets') -Recurse -File | Where-Object { $_.Extension -in @('.gd','.tres','.tscn','.wav','.png','.svg','.import') } | ForEach-Object FullName)
    $releaseFiles += Join-Path $validationRoot 'project.godot'
    $releaseFiles += Join-Path $validationRoot 'default_bus_layout.tres'
    $rows = foreach ($path in ($releaseFiles | Sort-Object -Unique)) {
        ([uri]($validationRoot.TrimEnd("\") + "\")).MakeRelativeUri([uri]$path).ToString().Replace('\','/') + ':' + (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
    }
    $sourceHash = ([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes(($rows -join "`n"))))).Replace("-", "").ToLowerInvariant()
    [ordered]@{engine=$version.Trim();source_hash=$sourceHash;release_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $exportDirectory 'AbyssExpedition.exe')).Hash;console_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $exportDirectory 'AbyssExpedition.console.exe')).Hash;benchmark_fixture_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $validationRoot 'tests/performance/benchmark_capture.gd')).Hash;release_denial='executed and passed'} | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $exportDirectory 'pacing-build.json')
}

# Long native-focus checks run last so focus loss still preserves completed
# gameplay graphics, exports and actual-release denial evidence. They remain gates.
if ($Graphical) {
    Invoke-SwordRealtime 'source'
    if ($Export) {
        Invoke-SwordRealtime 'debug' (Join-Path $exportDirectory 'AbyssExpedition-debug.console.exe')
        Invoke-SwordRealtime 'release' (Join-Path $exportDirectory 'AbyssExpedition.console.exe')
    }
}
