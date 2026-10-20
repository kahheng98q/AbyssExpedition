function Get-PacingBenchmarkComparison([object[]]$Summaries, [string]$BuildHash, [string]$FixtureHash, [switch]$Diagnostic) {
    $problems = [Collections.Generic.List[string]]::new()
    $target = $Summaries.Count -eq 2
    if ($Summaries.Count -ne 2) { $problems.Add('Exactly two complete summaries required') }
    foreach ($sample in $Summaries) {
        if (-not $sample.capture_valid -or -not $sample.fixture_rewards_preserved -or $sample.debug_build -or $sample.debugger_active -or $sample.smoke) { $problems.Add('Invalid capture/rewards/Release') }
        if ($sample.build_hash -cne $BuildHash -or $sample.fixture_hash -cne $FixtureHash) { $problems.Add('Build/fixture provenance mismatch') }
        $isTarget = $sample.same_machine_target -and $sample.processor -like '*5800H*' -and $sample.gpu -like '*1650*'
        $target = $target -and $isTarget
        if (-not $Diagnostic -and -not $isTarget) { $problems.Add('SC007 target hardware required') }
        if ($sample.engine -ne '4.5-stable (official)' -or $sample.renderer -ne 'gl_compatibility' -or $sample.seed -ne 101 -or $sample.milestone -ne 'm4') { $problems.Add('Wrong engine/renderer/seed/milestone') }
        if ($sample.warmup_active_seconds -lt 30 -or $sample.capture_active_seconds -lt 120 -or $sample.sample_count -le 0) { $problems.Add('Insufficient sample duration') }
        if (-not $sample.audio.driver -or $sample.audio.driver -eq 'Dummy' -or -not $sample.audio.device -or $sample.audio.sample_rate -le 0) { $problems.Add('Unknown/invalid real audio endpoint') }
        if ($sample.audio.peak_voices -gt 8) { $problems.Add('Voice budget exceeded') }
        foreach ($field in @('enemies','boss','gems')) {
            $expected = @{enemies=100;boss=1;gems=500}[$field]
            if ($sample.minimums.$field -ne $expected -or $sample.maximums.$field -ne $expected) { $problems.Add("Invalid fixed workload $field") }
        }
        if ($sample.minimums.effects -lt 30 -or $sample.minimums.projectiles -lt 100) { $problems.Add('Insufficient effects/projectiles') }
    }
    $same = $false
    if ($Summaries.Count -eq 2) {
        $left,$right = $Summaries
        $same = $left.kills -eq $right.kills -and $left.capture_active_seconds -eq $right.capture_active_seconds
        foreach ($field in @('processor','gpu','engine','renderer','simulation','catalog','build_hash','fixture_hash','seed','milestone')) {
            if (-not $left.$field -or $left.$field -cne $right.$field) { $problems.Add("Two-run mismatch: $field") }
        }
        foreach ($field in @('driver','device','sample_rate')) {
            if ($left.audio.$field -cne $right.audio.$field) { $problems.Add("Two-run audio mismatch: $field") }
        }
        if ($left.audio_mode -ne 'enabled' -or $right.audio_mode -ne 'disabled' -or $left.audio.cue_count -le 0 -or $left.audio.peak_voices -le 0 -or $right.audio.cue_count -ne 0 -or $right.audio.peak_voices -ne 0) { $problems.Add('Invalid actual audio on/off comparison') }
        if (-not $same) { $problems.Add('Final workload/time differs') }
    }
    $valid = $problems.Count -eq 0
    $budget = $Summaries.Count -eq 2 -and $Summaries[0].frame_budget_pass
    [pscustomobject]@{capture_valid=$valid;same_final_workload=($valid -and $same);same_machine_target=$target;enabled_budget_pass=$budget;sc007_sample_pass=($valid -and $target -and $budget);human_or_reference_acceptance=$false;diagnostic=[bool]$Diagnostic;errors=@($problems.ToArray())}
}
