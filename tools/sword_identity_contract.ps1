function Get-SwordGameplayProjection([System.Collections.IDictionary]$Record) {
    # Frozen sword-gameplay-v1 whitelist. Never drop an entire gameplay container.
    $copy = $Record | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable
    foreach ($key in @('build_hash','catalog','session_id')) { if ($copy.metadata) { $copy.metadata.Remove($key) } }
    if ($copy.trace.start) { $copy.trace.start.Remove('catalog') }
    foreach ($state in @($copy.states) + @($copy.final)) {
        if ($null -eq $state) { continue }
        foreach ($effect in $state.effects) { $effect.Remove('color'); $effect.Remove('sword_visual') }
        foreach ($followup in $state.followups) { $followup.Remove('sword_visual') }
    }
    foreach ($id in @('swordsman','swordmaster','abyss_swordsman')) {
        if ($copy.professions -and $copy.professions.Contains($id)) { $copy.professions[$id].Remove('visual_set') }
    }
    # Newly collected presentation facts/caches are diagnostic only, not HP or requests.
    $copy.Remove('presentation')
    return $copy
}

function Get-SwordDifferences($Expected, $Actual, [string]$Path = '') {
    if ($Expected -is [System.Collections.IDictionary] -and $Actual -is [System.Collections.IDictionary]) {
        $keys = @(@($Expected.Keys) + @($Actual.Keys) | Sort-Object -Unique)
        foreach ($key in $keys) {
            if (-not $Expected.Contains($key) -or -not $Actual.Contains($key)) { "$Path/$key : missing field" }
            else { Get-SwordDifferences $Expected[$key] $Actual[$key] "$Path/$key" }
        }
    } elseif ($Expected -is [array] -and $Actual -is [array]) {
        if ($Expected.Count -ne $Actual.Count) { "$Path/length : $($Expected.Count) != $($Actual.Count)" }
        for ($i=0; $i -lt [Math]::Min($Expected.Count,$Actual.Count); $i++) { Get-SwordDifferences $Expected[$i] $Actual[$i] "$Path/$i" }
    } elseif ($null -eq $Expected -or $null -eq $Actual) {
        if ($null -ne $Expected -or $null -ne $Actual) { "$Path : null mismatch" }
    } elseif ($Expected -cne $Actual) { "$Path : $Expected != $Actual" }
}

function Get-SwordWindowErrors($Windows, [bool]$Candidate) {
    if (@($Windows).Count -ne 12) { 'Exactly twelve 600tick sample windows required'; return }
    for ($i=0; $i -lt 12; $i++) {
        $w=$Windows[$i]
        if ($w.start -ne 1800+600*$i -or $w.end -ne 2400+600*$i) { "Window $i boundaries differ" }
        foreach ($key in @('dual','spin','long','heal')) {
            $minimum=if($key -in @('dual','long')){5}else{1}
            if ($null -eq $w[$key] -or $w[$key] -lt $minimum) { "Window $i insufficient real $key facts" }
            if ($Candidate -and ($null -eq $w.rendered[$key] -or $w.rendered[$key] -lt 1)) { "Window $i missing actual $key rendered frame" }
        }
    }
}

function Get-SwordTreeIdentity([string]$ProjectDirectory) {
    $files=@(Get-ChildItem -LiteralPath (Join-Path $ProjectDirectory 'scripts'),(Join-Path $ProjectDirectory 'data'),(Join-Path $ProjectDirectory 'scenes'),(Join-Path $ProjectDirectory 'assets') -Recurse -File | Where-Object {$_.Extension -in @('.gd','.tres','.tscn','.wav','.png','.svg','.import')} | ForEach-Object FullName)
    $files+=Join-Path $ProjectDirectory 'project.godot'
    $files+=Join-Path $ProjectDirectory 'default_bus_layout.tres'
    $rows=@(foreach($file in ($files | Sort-Object -Unique)){[ordered]@{path=[IO.Path]::GetRelativePath($ProjectDirectory,$file).Replace('\','/');sha256=(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()}})
    $lines=@($rows | ForEach-Object {$_.path+':'+$_.sha256})
    [ordered]@{hash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes(($lines -join "`n")))).ToLowerInvariant();files=$rows}
}

function Assert-SwordCaptureManifest($Manifest,[string]$Directory) {
    foreach($field in @('format','projection','engine','engine_sha256','build_hash','fixture_hash','fixture_files','samples','lifecycle_samples','source_files','catalog')) { if(-not $Manifest.Contains($field)){throw "Missing manifest field $field"} }
    if($Manifest.format -cne 'sword-identity-captures-v2' -or $Manifest.projection -cne 'sword-gameplay-v1' -or $Manifest.engine -cne '4.5.stable.official.876b29033'){throw 'Manifest protocol/engine mismatch'}
    foreach($field in @('build_hash','fixture_hash','catalog','engine_sha256')){if($Manifest[$field] -notmatch '^[a-f0-9]{64}$'){throw "Invalid manifest $field"}}
    $fixtureDigest=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes(($Manifest.fixture_files -join "`n")))).ToLowerInvariant()
    if($fixtureDigest -cne $Manifest.fixture_hash){throw 'Fixture manifest digest mismatch'}
    $lines=@($Manifest.source_files | ForEach-Object {$_.path+':'+$_.sha256})
    $hash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes(($lines -join "`n")))).ToLowerInvariant()
    if($hash -cne $Manifest.build_hash){throw 'Source manifest digest mismatch'}
    if(@($Manifest.samples).Count -ne 54){throw 'Incomplete capture: exactly 54 samples required'}
    $seeds=@($Manifest.samples | ForEach-Object seed | Sort-Object -Unique)
    if(($seeds -join ',') -ne '101,202,303'){throw 'Missing fixed seed'}
    $ids=@{}
    foreach($sample in $Manifest.samples){
        if($ids.ContainsKey($sample.id)){throw 'Duplicate capture ID'};$ids[$sample.id]=$true
        if($sample.file -notmatch '^[a-z0-9_-]+\.json$'){throw 'Invalid sample path'}
        $file=Join-Path $Directory $sample.file
        if(-not (Test-Path -LiteralPath $file) -or (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -cne $sample.sha256){throw 'Sample missing/hash mismatch'}
        $record=Get-Content -LiteralPath $file -Raw | ConvertFrom-Json -AsHashtable
        foreach($key in @('build_hash','fixture_hash','catalog')){if($record.metadata[$key] -cne $Manifest[$key]){throw "Sample identity mismatch $key"}}
        if($record.metadata.seed -ne $sample.seed -or $record.metadata.session_id -cne $sample.id -or $record.metadata.engine -cne '4.5-stable (official)' -or $record.states.Count -ne 360 -or $record.final.tick -ne 360){throw 'Sample seed/engine/identity/duration mismatch'}
        foreach($state in @($record.states)+@($record.final)){
            foreach($field in @('tick','stage','phase','kills','coins','corruption','level','xp','pending','stacks','sequence','request_id','party','enemies','projectiles','pickups','rng','snapshot_format','spawns','boss_hits','rescue','corruption_last_minute','pending_rewards','registry','boss_actor_id','pause_reasons','followups','delayed_impacts','damage_requests','consumed_damage','activation_heals','collected_pickups','offer','events','effects')){
                if(-not $state.Contains($field)){throw "Incomplete original gameplay state: missing $field"}
            }
            foreach($label in @('wave_types','spawn_positions','upgrade_offers','event_offers')){if(-not $state.rng.Contains($label) -or $state.rng[$label] -isnot [string]){throw 'Missing/imprecise original RNG state'}}
        }
    }
    $groups=@($Manifest.samples | Group-Object { $_.id -replace '-(101|202|303)$','' })
    if($groups.Count -ne 18 -or @($groups | Where-Object Count -ne 3).Count){throw 'Incomplete hero/profession/role matrix'}
    $expected=@(foreach($hero in @('aren','brann')){foreach($profession in @('swordsman','swordmaster','abyss_swordsman')){foreach($role in @('hero','companion')){"$hero-$profession-$role"}}})
    $expected+=@('lia-archer-hero','lia-sharpshooter-hero','lia-star_hunter-hero','milo-mage-hero','milo-elemental_sage-hero','milo-void_caster-hero')
    foreach($group in $groups){if($group.Name -cnotin $expected){throw 'Unexpected hero/profession/role group'}}
    $lifecycleIds=@(foreach($profession in @('swordmaster','abyss_swordsman')){foreach($seed in @(101,202,303)){"lifecycle-aren-$profession-$seed"}})
    if(@($Manifest.lifecycle_samples).Count -ne 6 -or @($Manifest.lifecycle_samples.id | Sort-Object -Unique).Count -ne 6){throw 'Exactly six unique lifecycle samples required'}
    foreach($sample in $Manifest.lifecycle_samples){
        if($sample.id -cnotin $lifecycleIds -or $sample.file -cne ($sample.id+'.json')){throw 'Unexpected lifecycle sample'}
        $file=Join-Path $Directory $sample.file
        if(-not (Test-Path -LiteralPath $file) -or (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -cne $sample.sha256){throw 'Lifecycle missing/hash mismatch'}
    }
}
