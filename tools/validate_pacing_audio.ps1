[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Record','Replay','Audio','Benchmark')][string]$Mode,
    [Parameter(Mandatory)][string]$EvidenceDirectory,
    [string]$InputDirectory,
    [string]$ReleaseExecutable,
    [ValidateSet('Integrated','US1','US2')][string]$FixtureMode = 'Integrated',
    [switch]$Graphical,
    [switch]$Diagnostic
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$taskEngine = Join-Path $taskRoot 'tools/godot-4.5/Godot_v4.5-stable_win64_console.exe'
$taskEvidence = [IO.Path]::GetFullPath($EvidenceDirectory, $taskRoot)
if (Test-Path -LiteralPath $taskEvidence) { throw 'Evidence directory already exists; preserve it and choose a new run-id.' }

if ($ReleaseExecutable -and $Mode -ne 'Benchmark') { throw '-ReleaseExecutable is only valid for Benchmark.' }
if ($Mode -eq 'Replay' -and -not $InputDirectory) { throw 'Replay requires -InputDirectory.' }
if ($Mode -eq 'Record' -and $InputDirectory) { throw 'Record does not accept -InputDirectory.' }
if ($Diagnostic -and $Mode -ne 'Benchmark') { throw '-Diagnostic is only valid for Benchmark.' }
$taskVersion = (& $taskEngine --version).Trim()
if ($taskVersion -ne '4.5.stable.official.876b29033') { throw "Engine pin mismatch: $taskVersion" }
function Get-TreeDigest([string[]]$paths) {
    $rows = foreach ($path in ($paths | Sort-Object -Unique)) {
        $relative = [IO.Path]::GetRelativePath($taskRoot, $path).Replace('\','/')
        $relative + ':' + (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes(($rows -join "`n"))
    [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}
$sourceFiles = @(Get-ChildItem -LiteralPath (Join-Path $taskRoot 'scripts'),(Join-Path $taskRoot 'data'),(Join-Path $taskRoot 'scenes'),(Join-Path $taskRoot 'assets') -Recurse -File | Where-Object { $_.Extension -in @('.gd','.tres','.tscn','.wav','.png','.svg','.import') } | ForEach-Object FullName)
$sourceFiles += Join-Path $taskRoot 'project.godot'
if (Test-Path (Join-Path $taskRoot 'default_bus_layout.tres')) { $sourceFiles += Join-Path $taskRoot 'default_bus_layout.tres' }
$buildHash = Get-TreeDigest $sourceFiles
$fixtureHash = Get-TreeDigest @((Join-Path $taskRoot 'tests/fixtures/pacing_session.gd'), (Join-Path $taskRoot 'tests/fixtures/pacing_observer.gd'))
function Invoke-PacingProcess([string]$executable, [string[]]$arguments, [string]$label, [int]$timeout = 60) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $executable
    $info.WorkingDirectory = $taskRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = Join-Path $taskRoot ('tools/runtime-pacing/' + (Split-Path $taskEvidence -Leaf) + '/' + $label)
    $info.Environment['ABYSS_PACING_BUILD_HASH'] = $buildHash
    $info.Environment['ABYSS_PACING_BENCHMARK_HASH'] = if ($Mode -eq 'Benchmark') { $releaseManifest.benchmark_fixture_sha256.ToLowerInvariant() } else { '' }
    foreach ($argument in $arguments) { $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if ($Mode -eq 'Benchmark') {
        $observation = [Collections.Generic.List[object]]::new()
        $observedCpu = @{}
        $monitorClock = [Diagnostics.Stopwatch]::StartNew()
        $powerBefore = (& powercfg /getactivescheme 2>&1 | Out-String).Trim()
        $powerObserved = $powerBefore
        $powerStable = $true
        $nextPowerSample = 10.0
        while (-not $process.HasExited -and $monitorClock.Elapsed.TotalSeconds -lt $timeout) {
            $cpuRows = @(Get-Process | ForEach-Object {
                $cpu = $_.CPU
                if ($null -ne $cpu) {
                    $delta = if ($observedCpu.ContainsKey($_.Id)) { [Math]::Max(0,$cpu-$observedCpu[$_.Id]) } else { 0 }
                    $observedCpu[$_.Id] = $cpu
                    if ($_.Id -ne $process.Id -and $_.Id -ne $PID) { [pscustomobject]@{process=$_.ProcessName;cpu_delta_seconds=$delta;working_set_bytes=$_.WorkingSet64} }
                }
            } | Sort-Object cpu_delta_seconds -Descending | Select-Object -First 8)
            if ($monitorClock.Elapsed.TotalSeconds -ge $nextPowerSample) {
                $powerObserved = (& powercfg /getactivescheme 2>&1 | Out-String).Trim()
                $powerStable = $powerStable -and $powerObserved -eq $powerBefore
                $nextPowerSample += 10.0
            }
            $observation.Add([ordered]@{elapsed_seconds=$monitorClock.Elapsed.TotalSeconds;power_scheme=$powerObserved;background_top_cpu=$cpuRows})
            [void]$process.WaitForExit(1000)
        }
        if (-not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $powerAfter = (& powercfg /getactivescheme 2>&1 | Out-String).Trim()
        [ordered]@{power_before=$powerBefore;power_after=$powerAfter;power_unchanged=($powerStable -and $powerBefore -eq $powerAfter);sampling='approximately 1s process CPU deltas/working sets and 10s power scheme; not GPU or external power monitoring';samples=@($observation.ToArray())} | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 (Join-Path $taskEvidence ($label+'-environment.json'))
    } elseif (-not $process.WaitForExit($timeout * 1000)) { $process.Kill($true); $process.WaitForExit() }
    $log = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $taskEvidence ($label + '.log')), $log)
    $code = $process.ExitCode
    $process.Dispose()
    if ($code -ne 0 -or $log -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:|Debugger Break)') { throw "$label failed; see retained logs (exit $code)." }
    Write-Output "$label PASS"
}
function Invoke-PacingGraphical {
    $captures = Join-Path $taskEvidence 'captures'
    New-Item -ItemType Directory -Path $captures | Out-Null
    Invoke-PacingProcess $taskEngine @('--path',$taskRoot,'--log-file',(Join-Path $taskEvidence 'pacing-graphics-engine.log'),'--script','res://tests/pacing_audio_graphical_check.gd','--','--captures',$captures) 'pacing-graphics' 60
}
if ($Mode -eq 'Benchmark') {
    if ($Graphical) { throw 'Benchmark must run alone; do graphical checks separately.' }
    if (-not $ReleaseExecutable -or -not [IO.Path]::IsPathFullyQualified($ReleaseExecutable) -or -not $ReleaseExecutable.EndsWith('.console.exe') -or -not (Test-Path -LiteralPath $ReleaseExecutable)) { throw 'Benchmark requires the absolute current Release console executable path.' }
    if ($InputDirectory -or $FixtureMode -ne 'Integrated') { throw 'Benchmark does not accept natural input traces/legacy fixtures.' }
    $releasePath = $ReleaseExecutable.Substring(0,$ReleaseExecutable.Length-12) + '.exe'
    $releaseManifestPath = Join-Path (Split-Path $ReleaseExecutable -Parent) 'pacing-build.json'
    if (-not (Test-Path -LiteralPath $releaseManifestPath)) { throw 'Missing new-build manifest; export current source using run_validation -BuildDirectory.' }
    $releaseManifest = Get-Content -Raw -LiteralPath $releaseManifestPath | ConvertFrom-Json
    $benchmarkFixture = Join-Path $taskRoot 'tests/performance/benchmark_capture.gd'
    if ($releaseManifest.source_hash -ne $buildHash -or $releaseManifest.engine -ne $taskVersion -or $releaseManifest.release_sha256 -ne (Get-FileHash -Algorithm SHA256 -LiteralPath $releasePath).Hash -or $releaseManifest.console_sha256 -ne (Get-FileHash -Algorithm SHA256 -LiteralPath $ReleaseExecutable).Hash -or $releaseManifest.benchmark_fixture_sha256 -ne (Get-FileHash -Algorithm SHA256 -LiteralPath $benchmarkFixture).Hash -or $releaseManifest.release_denial -ne 'executed and passed') { throw 'Release/source/fixture hash mismatch; fresh export required.' }
    New-Item -ItemType Directory -Path $taskEvidence | Out-Null
    $powerMode = (& powercfg /getactivescheme 2>&1 | Out-String).Trim()
    [ordered]@{mode='Benchmark';seed=101;build_hash=$buildHash;release_sha256=$releaseManifest.release_sha256;fixture_sha256=$releaseManifest.benchmark_fixture_sha256;power_mode=$powerMode;foreground='per-render-frame Window.has_focus observations in each summary';background_load='approximately 1s process CPU delta/working-set observations in per-run environment.json; no independent GPU observation';diagnostic=[bool]$Diagnostic;normalization_applied=$false} | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $taskEvidence 'host.json')
    $fixtureText = [IO.File]::ReadAllText($benchmarkFixture)
    $indented = ($fixtureText -split "\r?\n" | ForEach-Object { "`t" + $_ }) -join "`n"
    $bootstrap = "extends SceneTree`nclass Benchmark:`n$indented`nfunc _initialize() -> void:`n`tcall_deferred(`"start_capture`")`nfunc start_capture() -> void:`n`troot.add_child(Benchmark.new())`n"
    $harness = Join-Path $taskEvidence 'benchmark.gd'
    [IO.File]::WriteAllText($harness,$bootstrap)
    $valid = $true
    $summaries = @()
    foreach ($audioMode in @('enabled','disabled')) {
        $captureDirectory = Join-Path $taskEvidence $audioMode
        New-Item -ItemType Directory -Path $captureDirectory | Out-Null
        try {
            $benchmarkArgs = @('--path',$taskRoot,'--log-file',(Join-Path $captureDirectory 'engine.log'),'--script',$harness,'--','--m4','--seed','101','--output',$captureDirectory,'--pacing-audio',$audioMode)
            if ($Diagnostic) { $benchmarkArgs += '--diagnostic' }
            Invoke-PacingProcess $ReleaseExecutable $benchmarkArgs ('benchmark-'+$audioMode) 240
        } catch { $valid=$false; Write-Output $_.Exception.Message }
        $summaryPath = Join-Path $captureDirectory 'm4-101.json'
        if (Test-Path -LiteralPath $summaryPath) {
            $summary = Get-Content -Raw -LiteralPath $summaryPath | ConvertFrom-Json
            $summaries += $summary
            if (-not $summary.capture_valid -or $summary.debug_build -or $summary.audio_mode -ne $audioMode) { $valid=$false }
        } else { $valid=$false }
    }
    . (Join-Path $PSScriptRoot 'pacing_benchmark_contract.ps1')
    $comparison = Get-PacingBenchmarkComparison $summaries $buildHash $releaseManifest.benchmark_fixture_sha256.ToLowerInvariant() -Diagnostic:$Diagnostic
    $comparison.capture_valid = $comparison.capture_valid -and $valid
    $comparison.sc007_sample_pass = $comparison.sc007_sample_pass -and $valid
    $environmentObserved = $summaries.Count -eq 2 -and @($summaries | Where-Object { -not $_.focus_observation.fully_focused }).Count -eq 0
    $observedPowerScheme = $null
    foreach ($audioMode in @('enabled','disabled')) {
        $observationPath = Join-Path $taskEvidence ('benchmark-'+$audioMode+'-environment.json')
        $observationData = if(Test-Path $observationPath){Get-Content -Raw $observationPath | ConvertFrom-Json}else{$null}
        $environmentObserved = $environmentObserved -and $null -ne $observationData -and $observationData.power_unchanged -and $observationData.samples.Count -ge 120
        if ($null -ne $observationData) {
            if ($null -eq $observedPowerScheme) { $observedPowerScheme = $observationData.power_before }
            else { $environmentObserved = $environmentObserved -and $observedPowerScheme -eq $observationData.power_before }
        }
    }
    $comparison | Add-Member -NotePropertyName environment_observed -NotePropertyValue $environmentObserved
    $comparison.sc007_sample_pass = $comparison.sc007_sample_pass -and $environmentObserved
    $comparison | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 (Join-Path $taskEvidence 'comparison.json')
    if (-not $comparison.capture_valid -or -not $comparison.enabled_budget_pass) { throw 'Audio performance comparison failed; raw samples retained.' }
    Write-Output 'Current Release audio comparison captured; check hardware/environment limitations before SC007 acceptance.'
    return
}
if ($Mode -eq 'Audio') {
    if ($InputDirectory -or $FixtureMode -ne 'Integrated') { throw 'Audio does not accept input traces or legacy fixtures.' }
    New-Item -ItemType Directory -Path $taskEvidence | Out-Null
    [ordered]@{mode='Audio';build_hash=$buildHash;fixture_hash=$fixtureHash;audio_fixture_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $taskRoot 'tests/fixtures/audio_capture.gd')).Hash;loopback_fixture_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $taskRoot 'tools/capture_loopback.ps1')).Hash;engine=$taskVersion;loopback='WASAPI shared render endpoint; raw native samples';listening_acceptance='not executed'} | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $taskEvidence 'host.json')
    $captureInfo = [Diagnostics.ProcessStartInfo]::new()
    $captureInfo.FileName = (Get-Process -Id $PID).Path
    $captureInfo.WorkingDirectory = $taskRoot
    $captureInfo.UseShellExecute = $false
    $captureInfo.CreateNoWindow = $true
    $captureInfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $captureInfo.RedirectStandardOutput = $true
    $captureInfo.RedirectStandardError = $true
    foreach ($argument in @('-NoProfile','-File',(Join-Path $taskRoot 'tools/capture_loopback.ps1'),'-OutputDirectory',$taskEvidence,'-Seconds','35')) { $captureInfo.ArgumentList.Add($argument) }
    $captureProcess = [Diagnostics.Process]::new()
    $captureProcess.StartInfo = $captureInfo
    [void]$captureProcess.Start()
    $captureOut = $captureProcess.StandardOutput.ReadToEndAsync()
    $captureErr = $captureProcess.StandardError.ReadToEndAsync()
    try {
        $readyPath = Join-Path $taskEvidence 'capture-ready.json'
        $deadline = [DateTime]::UtcNow.AddSeconds(15)
        while (-not (Test-Path -LiteralPath $readyPath) -and -not $captureProcess.HasExited -and [DateTime]::UtcNow -lt $deadline) { [Threading.Thread]::Sleep(50) }
        if (-not (Test-Path -LiteralPath $readyPath)) { throw 'Real loopback recorder unavailable; Audio blocked. No Dummy fallback.' }
        Invoke-PacingProcess $taskEngine @('--path',$taskRoot,'--log-file',(Join-Path $taskEvidence 'scenarios-engine.log'),'--script','res://tests/fixtures/audio_capture.gd','--','--output',$taskEvidence) 'scenarios' 45
        if (-not $captureProcess.WaitForExit(45000)) { $captureProcess.Kill($true); throw 'Loopback watchdog expired.' }
        if ($captureProcess.ExitCode -ne 0) { throw 'Loopback recording failed; raw outputs retained.' }
        $recording = Get-Content -Raw -LiteralPath (Join-Path $taskEvidence 'loopback.json') | ConvertFrom-Json
        if (-not $recording.valid -or $recording.clipped_samples -ne 0 -or $recording.frames / $recording.sample_rate -lt 34) { throw 'Invalid/clipped/incomplete real recording; no SC004 pass.' }
        $scenarioResult = Get-Content -Raw -LiteralPath (Join-Path $taskEvidence 'audio-events.json') | ConvertFrom-Json
        if ($scenarioResult.driver -eq 'Dummy' -or $scenarioResult.peak_voices -ne 8 -or $scenarioResult.failures.Count -gt 0) { throw 'Invalid audio scenario facts.' }
        foreach ($case in @(@{Hero='aren';Cue='attack_arc'},@{Hero='lia';Cue='attack_straight'},@{Hero='milo';Cue='attack_homing'})) {
            if (@($scenarioResult.events | Where-Object { $_.scenario -eq ('normal-'+$case.Hero) -and $_.kind -eq 'cue_started' -and $_.fact.cue -eq $case.Cue }).Count -eq 0) { throw "No actual playback submitted for $($case.Hero)." }
        }
        Write-Output 'Real raw loopback captured without detected clipping. Human identification/listening remains open.'
    } finally {
        if (-not $captureProcess.HasExited) { $captureProcess.Kill($true); $captureProcess.WaitForExit() }
        [IO.File]::WriteAllText((Join-Path $taskEvidence 'loopback.log'),$captureOut.GetAwaiter().GetResult()+$captureErr.GetAwaiter().GetResult())
        $captureProcess.Dispose()
    }
    if ($Graphical) { Invoke-PacingGraphical }
    return
}
$samples = @(foreach ($hero in @('aren','lia','milo')) { foreach ($seed in @(101,202,303)) { [ordered]@{id="$hero-$seed";hero=$hero;seed=$seed} } })
$manifest = [ordered]@{format='pacing-sessions-v1';engine=$taskVersion;engine_hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $taskEngine).Hash;build_hash=$buildHash;fixture_hash=$fixtureHash;mode=$Mode;fixture_mode=$FixtureMode;samples=@()}
if ($Mode -eq 'Replay') {
    $taskInput = [IO.Path]::GetFullPath($InputDirectory, $taskRoot)
    $frozenManifest = Get-Content -Raw -LiteralPath (Join-Path $taskInput 'manifest.json') | ConvertFrom-Json
    if ($frozenManifest.format -ne 'pacing-sessions-v1' -or $frozenManifest.mode -ne 'Record' -or $frozenManifest.fixture_mode -ne $FixtureMode -or $frozenManifest.engine_hash -ne $manifest.engine_hash -or $frozenManifest.engine -ne $taskVersion -or $frozenManifest.build_hash -ne $buildHash -or $frozenManifest.fixture_hash -ne $fixtureHash -or $frozenManifest.samples.Count -ne 9) { throw 'Frozen manifest version/hash/sample count mismatch; record a complete new group.' }
    for ($i=0; $i -lt 9; $i++) {
        $sample = $samples[$i]
        $frozenSample = $frozenManifest.samples[$i]
        $samplePath = Join-Path $taskInput ($sample.id + '.json')
        if ($frozenSample.id -ne $sample.id -or $frozenSample.sha256 -ne (Get-FileHash -Algorithm SHA256 -LiteralPath $samplePath).Hash) { throw "Missing/changed/reordered sample: $($sample.id)" }
        $result = Get-Content -Raw -LiteralPath $samplePath | ConvertFrom-Json
        if ($result.metadata.session_id -ne $sample.id -or $result.metadata.hero -ne $sample.hero -or $result.metadata.seed -ne $sample.seed -or @($result.trace.spawns | Where-Object result -eq 'activated').Count -eq 0) { throw "Invalid frozen session $($sample.id)" }
    }
}
New-Item -ItemType Directory -Path $taskEvidence | Out-Null
$failed = $false
foreach ($sample in $samples) {
  foreach ($audioMode in $(if ($Mode -eq 'Replay') { @('enabled','disabled') } else { @('disabled') })) {
    $sampleLabel = $sample.id + $(if ($Mode -eq 'Replay') { '-' + $audioMode } else { '' })
    $sampleOutput = Join-Path $taskEvidence ($sampleLabel + '.json')
    $runtime = Join-Path $taskRoot ('tools/runtime-pacing/' + (Split-Path $taskEvidence -Leaf) + '/' + $sampleLabel + '-' + $Mode)
    if (Test-Path -LiteralPath $runtime) { throw "Runtime directory exists; choose a new run-id: $runtime" }
    New-Item -ItemType Directory -Path $runtime -Force | Out-Null
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $taskEngine
    $info.WorkingDirectory = $taskRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = $runtime
    $info.Environment['ABYSS_PACING_BUILD_HASH'] = $buildHash
    $info.Environment['ABYSS_PACING_FIXTURE_HASH'] = $fixtureHash
    $arguments = @('--path',$taskRoot,'--log-file',(Join-Path $taskEvidence ($sampleLabel + '-engine.log')),'--script','res://tests/fixtures/pacing_session.gd','--','--mode',$Mode,'--hero',$sample.hero,'--seed',[string]$sample.seed,'--output',$sampleOutput,'--fixture',$FixtureMode,'--audio',$audioMode)
    if ($Mode -eq 'Replay') { $arguments = @('--headless','--fixed-fps','60') + $arguments + @('--input',(Join-Path $taskInput ($sample.id + '.json'))) }
    foreach ($argument in $arguments) { $info.ArgumentList.Add($argument) }
    Write-Output "$Mode $sampleLabel"
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($(if ($Mode -eq 'Record') { 960000 } else { 240000 }))) { $process.Kill($true); $failed = $true }
    $log = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $taskEvidence ($sampleLabel + '.log')), $log)
    $exitCode = $process.ExitCode
    $process.Dispose()
    if ($exitCode -ne 0 -or $log -match '(?m)^(SCRIPT ERROR|ERROR:|Debugger Break)' -or -not (Test-Path -LiteralPath $sampleOutput)) { $failed = $true }
    if (Test-Path -LiteralPath $sampleOutput) {
        $sessionResult = Get-Content -Raw -LiteralPath $sampleOutput | ConvertFrom-Json
        if ($sessionResult.metadata.session_id -ne $sample.id -or $sessionResult.metadata.seed -ne $sample.seed -or $sessionResult.failures.Count -gt 0 -or @($sessionResult.trace.spawns | Where-Object result -eq 'activated').Count -eq 0) { $failed = $true }
    }
    $manifest.samples += [ordered]@{id=$sampleLabel;exit=$exitCode;sha256=$(if (Test-Path -LiteralPath $sampleOutput) {(Get-FileHash -Algorithm SHA256 -LiteralPath $sampleOutput).Hash} else {''})}
    $manifest | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 (Join-Path $taskEvidence 'manifest.json')
  }
}
if ($Graphical) { Invoke-PacingGraphical }
if ($failed) { throw 'One or more sessions failed; all outputs retained. No acceptance pass.' }
Write-Output 'All sessions passed the implemented checks; Replay ran nine audio pairs.'
