param([switch]$Baseline, [switch]$Cached, [switch]$Atlas)
$ErrorActionPreference = 'Stop'
$qualityRoot = Split-Path $PSScriptRoot -Parent
$label = if ($Baseline) { 'baseline' } elseif ($Atlas) { 'atlas' } elseif ($Cached) { 'cached' } else { 'current' }
$directory = Join-Path $qualityRoot "docs/validation/quality-20261018/benchmark-$label"
if (Test-Path -LiteralPath (Join-Path $directory 'm4-101.json')) { throw 'Retained capture exists; do not overwrite.' }
New-Item -ItemType Directory -Force $directory | Out-Null
$build = Join-Path $qualityRoot $(if ($Baseline) { 'builds/windows/m4/AbyssExpedition' } else { 'builds/windows/quality-20261018/AbyssExpedition' })
$fixture = [IO.File]::ReadAllText((Join-Path $qualityRoot 'tests/performance/benchmark_capture.gd'))
$indented = ($fixture -split "\r?\n" | ForEach-Object { "`t" + $_ }) -join "`n"
$bootstrap = "extends SceneTree`nclass Benchmark:`n$indented`nfunc _initialize() -> void:`n`tcall_deferred(`"start_capture`")`nfunc start_capture() -> void:`n`troot.add_child(Benchmark.new())`n"
$script = Join-Path $directory 'benchmark.gd'
[IO.File]::WriteAllText($script,$bootstrap)
[ordered]@{ label=$label; executable="$build.exe"; sha256=(Get-FileHash -LiteralPath "$build.exe").Hash; fixture_sha256=(Get-FileHash -LiteralPath (Join-Path $qualityRoot 'tests/performance/benchmark_capture.gd')).Hash; audio='Dummy'; seed=101; warmup_active_seconds=30; capture_active_seconds=120; reference_acceptance=$false; foreground='not independently observed'; power_mode='not independently observed'; note='One seed comparison, no simultaneous validation processes intended; not a reference-hardware or input-latency acceptance.' } | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $directory 'host.json')
$info = [Diagnostics.ProcessStartInfo]::new()
$info.FileName = "$build.console.exe"
$info.WorkingDirectory = $qualityRoot
$info.UseShellExecute = $false
$info.CreateNoWindow = $true
$info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
$info.RedirectStandardOutput = $true
$info.RedirectStandardError = $true
$info.Environment['APPDATA'] = Join-Path $PSScriptRoot 'runtime-quality'
foreach ($arg in @('--path',$qualityRoot,'--audio-driver','Dummy','--log-file',(Join-Path $directory 'engine.log'),'--script',$script,'--','--m4','--seed','101','--output',$directory)) { $info.ArgumentList.Add($arg) }
$process = [Diagnostics.Process]::new()
$process.StartInfo = $info
[void]$process.Start()
$stdout = $process.StandardOutput.ReadToEndAsync()
$stderr = $process.StandardError.ReadToEndAsync()
if (-not $process.WaitForExit(240000)) { $process.Kill($true); throw 'Benchmark watchdog expired' }
$output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
[IO.File]::WriteAllText((Join-Path $directory 'output.log'),$output)
$code=$process.ExitCode
$process.Dispose()
if ($code -ne 0 -or $output -match '(?m)^(ERROR:|SCRIPT ERROR|FAIL:)') { throw "Benchmark failed: $output" }
$output -split "`n" | Where-Object { $_ -match '^BENCH' } | Write-Output
