$ErrorActionPreference = 'Stop'
$contractPath = Join-Path $PSScriptRoot 'pacing_benchmark_contract.ps1'
if (-not (Test-Path -LiteralPath $contractPath)) { throw 'FAIL: missing benchmark pair contract' }
. $contractPath
# Constructed summaries test the comparator; these are not performance evidence.
$sample = @{
    capture_valid=$true; fixture_rewards_preserved=$true; debug_build=$false; debugger_active=$false; smoke=$false
    same_machine_target=$true; processor='AMD Ryzen 7 5800H'; gpu='NVIDIA GeForce GTX 1650'
    engine='4.5-stable (official)'; renderer='gl_compatibility'; simulation='combat-pacing-audio-1'; catalog='catalog'
    build_hash='build'; fixture_hash='fixture'; seed=101; milestone='m4'; sample_count=7200
    warmup_active_seconds=30; capture_active_seconds=120; kills=382; frame_budget_pass=$true
    minimums=@{enemies=100;boss=1;effects=30;projectiles=100;gems=500}
    maximums=@{enemies=100;boss=1;effects=31;projectiles=111;gems=500}
    audio_mode='enabled'; audio=@{driver='WASAPI';device='Default';sample_rate=48000;cue_count=800;peak_voices=6}
}
function Copy-Sample { $sample | ConvertTo-Json -Depth 10 | ConvertFrom-Json }
function Compare-Pair($left,$right) { Get-PacingBenchmarkComparison @($left,$right) 'build' 'fixture' }
$left=Copy-Sample; $right=Copy-Sample; $right.audio_mode='disabled'; $right.audio.cue_count=0; $right.audio.peak_voices=0
if (-not (Compare-Pair $left $right).capture_valid) { throw 'FAIL: valid pair rejected' }
$checks=1
foreach ($field in @('same_machine_target','processor','gpu','engine','build_hash','fixture_hash','catalog')) {
    $bad=Copy-Sample
    $bad.$field=if($field -eq 'same_machine_target'){$false}else{'other'}
    if ((Compare-Pair $bad $right).capture_valid) { throw "FAIL: accepted changed target/provenance $field" }
    $checks++
}
foreach ($field in @('driver','device','sample_rate')) {
    $bad=$right | ConvertTo-Json -Depth 10 | ConvertFrom-Json
    $bad.audio.$field=if($field -eq 'sample_rate'){44100}else{'other'}
    if ((Compare-Pair $left $bad).capture_valid) { throw "FAIL: accepted different audio $field" }
    $checks++
}
foreach ($field in @('enemies','boss','effects','projectiles','gems')) {
    $bad=Copy-Sample
    $bad.minimums.$field=0
    if ((Compare-Pair $bad $right).capture_valid) { throw "FAIL: equal kills hid invalid workload $field" }
    $checks++
}
$bad=Copy-Sample; $bad.fixture_rewards_preserved=$false
if ((Compare-Pair $bad $right).capture_valid) { throw 'FAIL: accepted lost rewards' }; $checks++
$bad=Copy-Sample; $bad.same_machine_target=$false; $bad.processor='Other CPU'; $bad.gpu='Other GPU'
$diagnostic=Get-PacingBenchmarkComparison @($bad,$right) 'build' 'fixture' -Diagnostic
if ($diagnostic.capture_valid) { throw 'FAIL: mismatched machines accepted as diagnostic' }; $checks++
$other=$bad | ConvertTo-Json -Depth 10 | ConvertFrom-Json; $other.audio_mode='disabled'; $other.audio.cue_count=0; $other.audio.peak_voices=0
$diagnostic=Get-PacingBenchmarkComparison @($bad,$other) 'build' 'fixture' -Diagnostic
if (-not $diagnostic.capture_valid -or $diagnostic.same_machine_target -or $diagnostic.sc007_sample_pass) { throw 'FAIL: non-target diagnostic claimed SC007' }; $checks++
Write-Output "BENCHMARK CONTRACT PASS: $checks constructed checks; no performance samples generated"
