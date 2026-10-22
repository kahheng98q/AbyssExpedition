[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Capture','Compare','Benchmark')][string]$Mode,
    [Parameter(Mandatory)][string]$EvidenceDirectory,
    [string]$ProjectDirectory,
    [string]$BaselineDirectory,
    [string]$CandidateDirectory,
    [string]$ReleaseExecutable,
    [ValidateSet('enabled','disabled')][string]$Presentation = 'enabled',
    [switch]$PreviewAccess
)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'sword_identity_contract.ps1')
$taskEvidence=[IO.Path]::GetFullPath($EvidenceDirectory,$taskRoot)
if(Test-Path -LiteralPath $taskEvidence){throw 'Evidence directory exists; choose new run-id'}
if($Mode -eq 'Compare'){
    if(-not $BaselineDirectory -or -not $CandidateDirectory -or $ProjectDirectory -or $ReleaseExecutable -or $PreviewAccess -or $Presentation -ne 'enabled'){throw 'Compare requires only BaselineDirectory/CandidateDirectory/new EvidenceDirectory'}
    $leftDirectory=[IO.Path]::GetFullPath($BaselineDirectory,$taskRoot)
    $rightDirectory=[IO.Path]::GetFullPath($CandidateDirectory,$taskRoot)
    # Standard-library streaming worker applies the same frozen V3 whitelist.
    # Preserve raw files and separate diagnostic values; no broad field omissions.
    $info=[Diagnostics.ProcessStartInfo]::new();$info.FileName='python';$info.WorkingDirectory=$taskRoot;$info.UseShellExecute=$false;$info.CreateNoWindow=$true;$info.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden;$info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
    foreach($argument in @('-X','utf8',(Join-Path $PSScriptRoot 'sword_identity_compare.py'),'--baseline',$leftDirectory,'--candidate',$rightDirectory,'--output',$taskEvidence)){$info.ArgumentList.Add($argument)}
    $process=[Diagnostics.Process]::new();$process.StartInfo=$info;[void]$process.Start()
    $stdout=$process.StandardOutput.ReadToEndAsync();$stderr=$process.StandardError.ReadToEndAsync()
    $timedOut=-not $process.WaitForExit(180000)
    if($timedOut){$process.Kill($true);$process.WaitForExit()}
    $log=$stdout.GetAwaiter().GetResult()+$stderr.GetAwaiter().GetResult()
    $code=$process.ExitCode;$process.Dispose()
    if(Test-Path -LiteralPath $taskEvidence){[IO.File]::WriteAllText((Join-Path $taskEvidence 'compare.log'),$log)}
    Write-Output $log
    if($timedOut -or $code -ne 0){throw 'Gameplay/manifest comparison failed; no fallback pass'}
    exit 0
}
if(-not $ProjectDirectory -or $BaselineDirectory -or $CandidateDirectory){throw 'Capture/Benchmark requires explicit ProjectDirectory'}
$taskProject=[IO.Path]::GetFullPath($ProjectDirectory,$taskRoot)
if(-not (Test-Path -LiteralPath (Join-Path $taskProject 'project.godot'))){throw 'Invalid project root'}
if($Mode -eq 'Capture' -and $ReleaseExecutable){throw 'ReleaseExecutable only valid for Benchmark'}
$taskEngine=Join-Path $taskRoot 'tools/godot-4.5/Godot_v4.5-stable_win64_console.exe'
$version=(& $taskEngine --version).Trim()
if($version -cne '4.5.stable.official.876b29033'){throw 'Pinned engine required'}
$identity=Get-SwordTreeIdentity $taskProject
$fixtureFiles=@('tests/fixtures/pacing_observer.gd','tests/fixtures/sword_identity_session.gd')
$fixtureRows=@($fixtureFiles | Sort-Object | ForEach-Object { $_+':'+(Get-FileHash -LiteralPath (Join-Path $taskRoot $_) -Algorithm SHA256).Hash.ToLowerInvariant() })
$fixtureHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes(($fixtureRows -join "`n")))).ToLowerInvariant()
if($Mode -eq 'Benchmark'){
    if($Presentation -ne 'enabled' -or $PreviewAccess -or -not $ReleaseExecutable -or -not [IO.Path]::IsPathFullyQualified($ReleaseExecutable) -or -not $ReleaseExecutable.EndsWith('.console.exe')){throw 'Benchmark requires absolute matching Release console path; no presentation overrides'}
    $release=[IO.Path]::GetFullPath($ReleaseExecutable)
    $exe=$release.Substring(0,$release.Length-12)+'.exe'
    $build=Get-Content -LiteralPath (Join-Path (Split-Path $release -Parent) 'pacing-build.json') -Raw | ConvertFrom-Json
    if($build.source_hash -cne $identity.hash -or $build.engine -cne $version -or $build.release_denial -cne 'executed and passed' -or $build.release_sha256 -ine (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash -or $build.console_sha256 -ine (Get-FileHash -LiteralPath $release -Algorithm SHA256).Hash){throw 'Release/source/engine manifest mismatch; no fallback to old build'}
    $base=Get-Content -LiteralPath (Join-Path $taskRoot 'tests/performance/benchmark_capture.gd') -Raw
    $sword=Get-Content -LiteralPath (Join-Path $taskRoot 'tests/performance/sword_identity_benchmark.gd') -Raw
    $benchmarkHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($base+"`n"+$sword))).ToLowerInvariant()
    $baseIndented=($base -split '\r?\n' | ForEach-Object {"`t"+$_}) -join "`n"
    $sword=$sword.Replace('extends "res://tests/performance/benchmark_capture.gd"','extends BenchmarkBase')
    $swordIndented=($sword -split '\r?\n' | ForEach-Object {"`t"+$_}) -join "`n"
    $harness="extends SceneTree`nclass BenchmarkBase:`n$baseIndented`nclass SwordBenchmark:`n$swordIndented`nfunc _initialize() -> void:`n`tcall_deferred(`"begin`")`nfunc begin() -> void:`n`troot.add_child(SwordBenchmark.new())`n"
    New-Item -ItemType Directory -Path $taskEvidence | Out-Null
    $harnessPath=Join-Path $taskEvidence 'benchmark.gd'
    [IO.File]::WriteAllText($harnessPath,$harness)
    $candidate=(Get-Content -LiteralPath (Join-Path $taskProject 'data/professions/swordsman.tres') -Raw) -match 'sword_identity\s*='
    [ordered]@{mode='Benchmark';engine=$version;build_hash=$identity.hash;source_files=$identity.files;fixture_hash=$benchmarkHash;release_sha256=$build.release_sha256;console_sha256=$build.console_sha256;candidate=$candidate;natural_human_recording=$false} | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $taskEvidence 'manifest.json') -Encoding utf8
    $info=[Diagnostics.ProcessStartInfo]::new();$info.FileName=$release;$info.WorkingDirectory=$taskProject;$info.UseShellExecute=$false;$info.CreateNoWindow=$true;$info.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden;$info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
    $info.Environment['APPDATA']=Join-Path $taskRoot ('tools/runtime-sword/'+(Split-Path $taskEvidence -Leaf)+'/appdata')
    $info.Environment['ABYSS_SWORD_CANDIDATE']=if($candidate){'yes'}else{'no'}
    $info.Environment['ABYSS_SWORD_BUILD_HASH']=$identity.hash;$info.Environment['ABYSS_SWORD_FIXTURE_HASH']=$benchmarkHash
    foreach($argument in @('--path',$taskProject,'--log-file',(Join-Path $taskEvidence 'benchmark-engine.log'),'--script',$harnessPath,'--','--m4','--seed','101','--output',$taskEvidence)){$info.ArgumentList.Add($argument)}
    $process=[Diagnostics.Process]::new();$process.StartInfo=$info;[void]$process.Start()
    $stdout=$process.StandardOutput.ReadToEndAsync();$stderr=$process.StandardError.ReadToEndAsync()
    $powerBefore=(& powercfg /getactivescheme 2>&1 | Out-String).Trim()
    $observation=[Collections.Generic.List[object]]::new();$observedCpu=@{};$clock=[Diagnostics.Stopwatch]::StartNew()
    while(-not $process.HasExited -and $clock.Elapsed.TotalSeconds -lt 240){
        $rows=@(Get-Process | ForEach-Object {if($null -ne $_.CPU){$cpu=$_.CPU;$delta=if($observedCpu.ContainsKey($_.Id)){[Math]::Max(0,$cpu-$observedCpu[$_.Id])}else{0};$observedCpu[$_.Id]=$cpu;[ordered]@{name=$_.ProcessName;pid=$_.Id;cpu_delta_seconds=$delta;working_set_bytes=$_.WorkingSet64}}})
        $observation.Add([ordered]@{elapsed_seconds=$clock.Elapsed.TotalSeconds;power=(& powercfg /getactivescheme 2>&1 | Out-String).Trim();visible_processes=$rows})
        [void]$process.WaitForExit(1000)
    }
    $timedOut=-not $process.HasExited;if($timedOut){$process.Kill($true);$process.WaitForExit()}
    $log=$stdout.GetAwaiter().GetResult()+$stderr.GetAwaiter().GetResult();[IO.File]::WriteAllText((Join-Path $taskEvidence 'benchmark.log'),$log)
    $code=$process.ExitCode;$process.Dispose()
    [ordered]@{power_before=$powerBefore;power_after=(& powercfg /getactivescheme 2>&1 | Out-String).Trim();observations=@($observation.ToArray());scope='visible process CPU/working set and power; not a guarantee of complete host GPU/background visibility';timed_out=$timedOut;exit_code=$code} | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $taskEvidence 'environment.json') -Encoding utf8
    if($timedOut -or $code -ne 0 -or $log -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:)'){throw 'Benchmark failed; partial logs retained'}
    $summary=Get-Content -LiteralPath (Join-Path $taskEvidence 'm4-101.json') -Raw | ConvertFrom-Json -AsHashtable
    $errors=@(Get-SwordWindowErrors $summary.sword_windows $candidate)
    if(-not $summary.capture_valid -or $summary.debug_build -or $summary.debugger_active -or $summary.warmup_active_seconds -lt 30 -or $summary.capture_active_seconds -lt 120 -or $summary.build_hash -cne $identity.hash -or $summary.fixture_hash -cne $benchmarkHash -or $errors.Count){throw ('Invalid sword capture: '+($errors -join '; '))}
    Write-Output ('Sword Release sample valid; frame_budget_pass='+$summary.frame_budget_pass+'; human/reference/full environment acceptance remains open')
    exit 0
}
New-Item -ItemType Directory -Path $taskEvidence | Out-Null
$taskRuntime=Join-Path $taskRoot ('tools/runtime-sword/'+(Split-Path $taskEvidence -Leaf))
if(Test-Path -LiteralPath $taskRuntime){throw 'Runtime exists; choose new run-id'}
$taskCopy=Join-Path $taskRuntime 'project'
New-Item -ItemType Directory -Path $taskCopy | Out-Null
# Explicit whitelist prevents copying builds/recursive source trees. Original stays frozen.
foreach($directory in @('scripts','data','scenes','assets','tests')){Copy-Item -LiteralPath (Join-Path $taskProject $directory) -Destination (Join-Path $taskCopy $directory) -Recurse}
foreach($file in @('project.godot','default_bus_layout.tres','icon.svg','icon.svg.import')){Copy-Item -LiteralPath (Join-Path $taskProject $file) -Destination $taskCopy}
foreach($file in $fixtureFiles){Copy-Item -LiteralPath (Join-Path $taskRoot $file) -Destination (Join-Path $taskCopy $file) -Force}
function Invoke-SwordProcess([string]$Name,[string[]]$Arguments,[int]$Timeout){
    $info=[Diagnostics.ProcessStartInfo]::new();$info.FileName=$taskEngine;$info.WorkingDirectory=$taskCopy;$info.UseShellExecute=$false;$info.CreateNoWindow=$true;$info.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true;$info.Environment['APPDATA']=Join-Path $taskRuntime 'appdata'
    foreach($argument in $Arguments){$info.ArgumentList.Add($argument)}
    $process=[Diagnostics.Process]::new();$process.StartInfo=$info;[void]$process.Start()
    $stdout=$process.StandardOutput.ReadToEndAsync();$stderr=$process.StandardError.ReadToEndAsync()
    $timedOut=-not $process.WaitForExit($Timeout*1000)
    if($timedOut){$process.Kill($true);$process.WaitForExit()}
    $log=$stdout.GetAwaiter().GetResult()+$stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $taskEvidence ($Name+'.log')),$log)
    $exitCode=$process.ExitCode;$process.Dispose()
    if($timedOut -or $exitCode -ne 0 -or $log -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:)'){throw "$Name failed (exit $exitCode, timeout=$timedOut); logs retained"}
    Write-Output "$Name PASS (exit $exitCode)"
}
Invoke-SwordProcess 'import' @('--headless','--editor','--import','--path',$taskCopy) 60
Invoke-SwordProcess 'capture' @('--headless','--fixed-fps','60','--path',$taskCopy,'--log-file',(Join-Path $taskEvidence 'capture-engine.log'),'--script','res://tests/fixtures/sword_identity_session.gd','--','--output',$taskEvidence,'--build-hash',$identity.hash,'--fixture-hash',$fixtureHash,'--presentation',$Presentation,'--preview',$(if($PreviewAccess){'yes'}else{'no'})) 600
$allSamples=@(Get-ChildItem -LiteralPath $taskEvidence -Filter '*.json' -File | Sort-Object Name | ForEach-Object {
    $record=Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json -AsHashtable
    [ordered]@{id=$record.metadata.session_id;seed=$record.metadata.seed;file=$_.Name;sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}
})
$samples=@($allSamples | Where-Object {$_.id -notlike 'lifecycle-*'})
$lifecycleSamples=@($allSamples | Where-Object {$_.id -like 'lifecycle-*'})
if($samples.Count -ne 54){throw 'Incomplete capture; expected 54 hero/profession/role/seed samples'}
if($lifecycleSamples.Count -ne 6){throw 'Incomplete capture; expected six lifecycle/seed samples'}
$first=Get-Content -LiteralPath (Join-Path $taskEvidence $samples[0].file) -Raw | ConvertFrom-Json -AsHashtable
$manifest=[ordered]@{format='sword-identity-captures-v2';projection='sword-gameplay-v1';engine=$version;engine_sha256=(Get-FileHash -LiteralPath $taskEngine -Algorithm SHA256).Hash.ToLowerInvariant();build_hash=$identity.hash;source_files=$identity.files;catalog=$first.metadata.catalog;fixture_hash=$fixtureHash;fixture_files=$fixtureRows;samples=$samples;lifecycle_samples=$lifecycleSamples;presentation=$Presentation;preview_access=[bool]$PreviewAccess;natural_human_recording=$false;external_test_copy=$taskCopy}
$manifest | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $taskEvidence 'manifest.json') -Encoding utf8
Assert-SwordCaptureManifest $manifest $taskEvidence
& python -X utf8 (Join-Path $PSScriptRoot 'sword_identity_compare.py') --validate $taskEvidence
if($LASTEXITCODE -ne 0){throw 'Non-empty lifecycle coverage/schema guard failed'}
Write-Output 'Capture complete: 54 combat + 6 lifecycle controlled samples; no natural/human acceptance claim'
exit 0
