[CmdletBinding()]
param([string]$EvidenceDirectory,[string]$CaptureDirectory)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'sword_identity_contract.ps1')
$checks = [Collections.Generic.List[object]]::new()
function Check([bool]$Condition,[string]$Name) { $checks.Add([ordered]@{name=$Name;passed=$Condition}) }
function Clone($Value) { return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable) }
function Equal($A,$B) { return @(Get-SwordDifferences (Get-SwordGameplayProjection $A) (Get-SwordGameplayProjection $B)).Count -eq 0 }
$base = @{metadata=@{engine='4.5';simulation='m4';seed=101;party=@('aren');build_hash='old';catalog='old';session_id='old'};trace=@{start=@{catalog='old';seed=101};inputs=@(@{tick=0;direction=@(0,0)});decisions=@(@{upgrade='might'})};states=@(@{hp=42;activations=5;rng=@{spawns='1';offers='2';events='3';extra='4'};effects=@(@{direction=@(1,0);reach=48;angle=100;expires=10;color=@(1,1,1)});followups=@(@{due=10;origin=@(0,0);direction=@(1,0);reach=48;angle=100;damage=36;knockback=80;burn=$false;frost=$false});damage_requests=@(@{damage=36});activation_heals=@{'0:5'=$true}});professions=@{swordsman=@{damage=36;visual_set=@{palette='old'}};mage=@{damage=36;visual_set=@{palette='mage'}}}}
Check (Equal $base (Clone $base)) 'identical full gameplay passes'
$visual=Clone $base
$visual.metadata.build_hash='new';$visual.metadata.catalog='new';$visual.metadata.session_id='new';$visual.trace.start.catalog='new'
$visual.states[0].effects[0].color=@(0,1,1)
$visual.states[0].effects[0].sword_visual=@{identity='dual'}
$visual.states[0].followups[0].sword_visual=@{identity='dual'}
$visual.professions.swordsman.visual_set.palette='new'
Check (Equal $base $visual) 'V3 exact version/color/sword_visual/sword VisualSet whitelist passes'
foreach ($key in @('hp','activations')) { $bad=Clone $base;$bad.states[0][$key]++;Check (-not (Equal $base $bad)) "reject $key mutation" }
foreach ($key in @('spawns','offers','events','extra')) { $bad=Clone $base;$bad.states[0].rng[$key]='changed';Check (-not (Equal $base $bad)) "reject RNG $key mutation" }
foreach ($key in @('direction','reach','angle','expires')) { $bad=Clone $base;$bad.states[0].effects[0][$key]=999;Check (-not (Equal $base $bad)) "reject effect $key mutation" }
foreach ($key in @('due','origin','direction','reach','angle','damage','knockback','burn','frost')) { $bad=Clone $base;$bad.states[0].followups[0][$key]=999;Check (-not (Equal $base $bad)) "reject followup $key mutation" }
foreach ($path in @('unknown','damage_requests','activation_heals')) { $bad=Clone $base;$bad.states[0][$path]='changed';Check (-not (Equal $base $bad)) "reject unknown/container $path mutation" }
$bad=Clone $base;$bad.trace.decisions[0].upgrade='reach';Check (-not (Equal $base $bad)) 'reject choice mutation'
$bad=Clone $base;$bad.metadata.Remove('seed');Check (-not (Equal $base $bad)) 'reject missing seed'
$bad=Clone $base;$bad.metadata.fixture_hash='changed';Check (-not (Equal $base $bad)) 'reject changed fixture identity'
$bad=Clone $base;$bad.professions.swordsman.damage=37;Check (-not (Equal $base $bad)) 'reject profession gameplay mutation'
$bad=Clone $base;$bad.professions.mage.visual_set.palette='new';Check (-not (Equal $base $bad)) 'reject non-sword VisualSet mutation'
$windows=@(foreach($i in 0..11){@{start=1800+600*$i;end=2400+600*$i;dual=5;spin=1;long=5;heal=1;rendered=@{dual=1;spin=1;long=1;heal=1}}})
Check (@(Get-SwordWindowErrors $windows $true).Count -eq 0) '12 complete windows pass'
foreach($key in @('dual','spin','long','heal')) {
    $bad=Clone $windows;$bad[6][$key]=0;Check (@(Get-SwordWindowErrors $bad $true).Count -gt 0) "reject missing $key in any sample window / only warmup"
    $bad=Clone $windows;$bad[6].rendered[$key]=0;Check (@(Get-SwordWindowErrors $bad $true).Count -gt 0) "reject no actual $key render frame"
}
$bad=Clone $windows;foreach($w in $bad){$w.heal=0};Check (@(Get-SwordWindowErrors $bad $true).Count -gt 0) 'reject all-full-health sample'
Check (@(Get-SwordWindowErrors $windows[0..10] $true).Count -gt 0) 'reject missing 600tick window'
if($CaptureDirectory){
    $capture=[IO.Path]::GetFullPath($CaptureDirectory,(Split-Path $PSScriptRoot -Parent))
    $manifest=Get-Content -LiteralPath (Join-Path $capture 'manifest.json') -Raw | ConvertFrom-Json -AsHashtable
    $accepted=$true
    try{Assert-SwordCaptureManifest $manifest $capture}catch{$accepted=$false;Write-Output $_.Exception.Message}
    Check $accepted 'complete captured manifest/state schema accepted'
    foreach($mutation in @('bad-source','bad-fixture','missing-seed','missing-sample','bad-engine','bad-duration-hash','missing-lifecycle','bad-lifecycle-hash')){
        $bad=Clone $manifest
        switch($mutation){
            'bad-source' {$bad.build_hash='0'*64}
            'bad-fixture' {$bad.fixture_hash='0'*64}
            'missing-seed' {$bad.samples=@($bad.samples | Where-Object seed -ne 303)}
            'missing-sample' {$bad.samples=$bad.samples[0..52]}
            'bad-engine' {$bad.engine='4.7'}
            'bad-duration-hash' {$bad.samples[0].sha256='0'*64}
            'missing-lifecycle' {$bad.lifecycle_samples=$bad.lifecycle_samples[0..4]}
            'bad-lifecycle-hash' {$bad.lifecycle_samples[0].sha256='0'*64}
        }
        $rejected=$false
        try{Assert-SwordCaptureManifest $bad $capture}catch{$rejected=$true}
        Check $rejected "manifest rejects $mutation"
    }
}
$hostPath=(Get-Process -Id $PID).Path
$cli=Join-Path $PSScriptRoot 'validate_sword_identity.ps1'
$negativeRoot=Join-Path $PSScriptRoot ('runtime-sword-contract/'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $negativeRoot | Out-Null
foreach($entry in @(
    @{name='unknown parameter';args=@('-Mode','Capture','-EvidenceDirectory',(Join-Path $negativeRoot 'unknown'),'-Unknown','x')},
    @{name='unknown mode';args=@('-Mode','Missing','-EvidenceDirectory',(Join-Path $negativeRoot 'mode'))},
    @{name='existing evidence';args=@('-Mode','Capture','-EvidenceDirectory',$negativeRoot)},
    @{name='missing project';args=@('-Mode','Capture','-EvidenceDirectory',(Join-Path $negativeRoot 'project'))},
    @{name='early/missing capture';args=@('-Mode','Compare','-EvidenceDirectory',(Join-Path $negativeRoot 'early'),'-BaselineDirectory',$negativeRoot,'-CandidateDirectory',$negativeRoot)}
)){
    $info=[Diagnostics.ProcessStartInfo]::new();$info.FileName=$hostPath;$info.UseShellExecute=$false;$info.CreateNoWindow=$true;$info.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden;$info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
    foreach($argument in @('-NoProfile','-File',$cli)+$entry.args){$info.ArgumentList.Add($argument)}
    $process=[Diagnostics.Process]::new();$process.StartInfo=$info;[void]$process.Start()
    $stdout=$process.StandardOutput.ReadToEndAsync();$stderr=$process.StandardError.ReadToEndAsync();$finished=$process.WaitForExit(15000)
    if(-not $finished){$process.Kill($true);$process.WaitForExit()}
    $stdout.GetAwaiter().GetResult() | Out-Null;$stderr.GetAwaiter().GetResult() | Out-Null
    Check ($finished -and $process.ExitCode -ne 0) ('CLI rejects '+$entry.name)
    $process.Dispose()
}
if($EvidenceDirectory){
    if(Test-Path -LiteralPath $EvidenceDirectory){throw 'New evidence directory required'}
    New-Item -ItemType Directory -Path $EvidenceDirectory | Out-Null
    @($checks.ToArray()) | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $EvidenceDirectory 'contract.json') -Encoding utf8
}
$failed=@($checks | Where-Object {-not $_.passed})
$failed | ForEach-Object { Write-Output ('FAIL: '+$_.name) }
Write-Output ("Sword contract: $($checks.Count) checks; $($failed.Count) failures")
if($failed.Count){exit 1}
exit 0
