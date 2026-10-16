param(
    [switch]$Smoke,
    [switch]$Release,
    [switch]$UseTemplate,
    [switch]$VSync,
    [ValidateSet('m2','m4')][string]$Milestone = 'm4',
    [string]$EvidenceDirectory
)
$ErrorActionPreference = 'Stop'
$benchmarkRoot = Split-Path $PSScriptRoot -Parent
$benchmarkEngine = Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe'
$benchmarkSourceEngine = Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64.exe'
if ((& $benchmarkEngine --version).Trim() -ne '4.5.stable.official.876b29033') { throw 'Benchmark requires pinned Godot 4.5.' }
if (-not $EvidenceDirectory) {
    $EvidenceDirectory = Join-Path $benchmarkRoot ('docs/validation/benchmark-' + $Milestone + '-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0,6))
}
$benchmarkOutput = [IO.Path]::GetFullPath($EvidenceDirectory, $benchmarkRoot)
New-Item -ItemType Directory -Force -Path $benchmarkOutput | Out-Null
foreach ($seed in @(101,202,303)) {
    if (Test-Path -LiteralPath (Join-Path $benchmarkOutput "$Milestone-$seed.json")) { throw 'Capture already exists; use a new EvidenceDirectory to preserve history.' }
}
if ($UseTemplate) { $Release = $true }
$releasePack = Join-Path $benchmarkRoot 'builds/windows/m4/AbyssExpedition.exe'
$benchmarkBinary = if ($UseTemplate) { Join-Path $PSScriptRoot 'godot-4.5-templates/templates/windows_release_x86_64.exe' } elseif ($Release) { $releasePack } else { $benchmarkSourceEngine }
if (-not (Test-Path -LiteralPath $benchmarkBinary)) { throw 'Export the current M4 release before running release diagnostics.' }
$fixtureSource = [IO.File]::ReadAllText((Join-Path $benchmarkRoot 'tests/performance/benchmark_capture.gd'))
# A development-only external SceneTree script; no benchmark entry point is shipped.
$nestedSource = ($fixtureSource -split "\r?\n" | ForEach-Object { "`t" + $_ }) -join "`n"
$bootstrap = "extends SceneTree`n`nclass Benchmark:`n" + $nestedSource + "`n`nfunc _initialize() -> void:`n`troot.add_child(Benchmark.new())`n"
$scriptPath = Join-Path $benchmarkOutput 'benchmark-diagnostic.gd'
[IO.File]::WriteAllText($scriptPath, $bootstrap)
$metadata = [ordered]@{
    mode = $(if ($UseTemplate) { 'release_template_with_exported_pack' } elseif ($Release) { 'release_executable' } else { 'source' })
    milestone = $Milestone
    smoke = [bool]$Smoke
    acceptance = $false
    build_path = $benchmarkBinary
    build_sha256 = (Get-FileHash -LiteralPath $benchmarkBinary -Algorithm SHA256).Hash
    pack_sha256 = $(if ($Release) { (Get-FileHash -LiteralPath $releasePack -Algorithm SHA256).Hash } else { $null })
    fixture_sha256 = (Get-FileHash -LiteralPath (Join-Path $benchmarkRoot 'tests/performance/benchmark_capture.gd') -Algorithm SHA256).Hash
    os = [Environment]::OSVersion.VersionString
    processor = $env:PROCESSOR_IDENTIFIER
    ram_bytes = $null
    graphics = $null
    power_scheme = $null
    effective_power_mode = 'not independently observed'
    hardware_query_errors = @()
    profiler = 'Godot Performance monitors; no external profiler attached by this wrapper'
    vsync_requested = [bool]$VSync
    audio_driver = 'Dummy (diagnostic fixture only; gameplay settings unchanged)'
    process_launch_style = 'Hidden; OS foreground state not independently observed'
    reference_target = 'Windows 11 / i5-8400 / GTX 1050 Ti 4GB / 16GB RAM / SSD / 1920x1080 60Hz'
    notes = 'Frame budgets are separate from capture validity. Displayed input/hit latency and human readability are not measured.'
}
try { $metadata.ram_bytes = (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory } catch { $metadata.hardware_query_errors += $_.Exception.Message }
try { $metadata.graphics = @(Get-CimInstance Win32_VideoController -ErrorAction Stop | Select-Object Name,DriverVersion) } catch { $metadata.hardware_query_errors += $_.Exception.Message }
try { $metadata.power_scheme = (& powercfg /GETACTIVESCHEME 2>&1 | Out-String).Trim() } catch { $metadata.hardware_query_errors += $_.Exception.Message }
$metadata | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 (Join-Path $benchmarkOutput 'host.json')
$results = @()
foreach ($seed in @(101,202,303)) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $benchmarkBinary
    $info.WorkingDirectory = $benchmarkRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = Join-Path $PSScriptRoot 'runtime-appdata'
    $arguments = @('--audio-driver','Dummy','--path',$benchmarkRoot,'--log-file',(Join-Path $benchmarkOutput "$Milestone-$seed-engine.log"),'--script',$scriptPath,'--','--seed',"$seed",'--output',$benchmarkOutput)
    if ($UseTemplate) { $arguments = @('--main-pack',$releasePack) + $arguments }
    if ($Milestone -eq 'm4') { $arguments += '--m4' }
    if ($Smoke) { $arguments += '--smoke' }
    if ($VSync) { $arguments += '--vsync-on' }
    foreach ($argument in $arguments) { $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $benchmarkProcessId = $process.Id
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $memoryRows = @()
    $memoryError = $null
    $watch = [Diagnostics.Stopwatch]::StartNew()
    while (-not $process.WaitForExit(1000)) {
        if ($watch.Elapsed.TotalSeconds -gt 240) { $process.Kill($true); throw "Benchmark $seed watchdog" }
        try {
            $process.Refresh()
            if ($process.WorkingSet64 -gt 0) {
                $memoryRows += [pscustomobject]@{ elapsed_seconds = $watch.Elapsed.TotalSeconds; working_set_bytes = $process.WorkingSet64; private_bytes = $process.PrivateMemorySize64; cpu_seconds = $process.TotalProcessorTime.TotalSeconds }
            }
        } catch { $memoryError = $_.Exception.Message }
    }
    $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $benchmarkOutput "$Milestone-$seed.log"), $output)
    $code = $process.ExitCode
    $process.Dispose()
    if ($code -ne 0 -or $output -match '(?m)^(ERROR:|SCRIPT ERROR|FAIL:)') { throw "Benchmark $seed failed: $output" }
    $result = Get-Content -LiteralPath (Join-Path $benchmarkOutput "$Milestone-$seed.json") -Raw | ConvertFrom-Json
    if ($result.engine_pid -ne $benchmarkProcessId) { throw 'Memory monitor PID is not the Godot engine process.' }
    $result | Add-Member -NotePropertyName observed_process_id -NotePropertyValue $benchmarkProcessId
    $memoryRows | Export-Csv -NoTypeInformation -Encoding utf8 -LiteralPath (Join-Path $benchmarkOutput "$Milestone-$seed-process.csv")
    $result | Add-Member -NotePropertyName process_memory_available -NotePropertyValue ($memoryRows.Count -gt 0)
    $result | Add-Member -NotePropertyName process_memory_query_error -NotePropertyValue $memoryError
    $result | Add-Member -NotePropertyName engine_memory_note -NotePropertyValue 'A zero static-memory monitor is unavailable in release templates, not zero memory usage; process CSV records OS memory independently.'
    $result | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 (Join-Path $benchmarkOutput "$Milestone-$seed.json")
    if (-not $result.capture_valid -or $result.capture_active_seconds -lt $(if ($Smoke) { 2 } else { 120 })) { throw 'Invalid capture or insufficient active duration.' }
    if ($Release -and $result.debug_build) { throw 'Release diagnostics unexpectedly ran a debug build.' }
    $results += $result
    $output -split "`n" | Where-Object { $_ -match 'BENCH ' } | Write-Output
}
$results | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 (Join-Path $benchmarkOutput 'results.json')
Write-Output "CAPTURE COMPLETE: $benchmarkOutput; reference acceptance remains open."
