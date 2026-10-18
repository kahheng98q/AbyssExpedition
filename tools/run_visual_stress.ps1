param([ValidateSet('before','after')][string]$Mode,[string]$Executable,[string]$EvidenceDirectory,[switch]$Smoke)
$ErrorActionPreference='Stop'
$stressRoot=Split-Path $PSScriptRoot -Parent
if(-not $Mode -or -not $Executable -or -not $EvidenceDirectory){throw 'Explicit before/after, retained executable and output required.'}
$stressOutput=[IO.Path]::GetFullPath($EvidenceDirectory,$stressRoot)
New-Item -ItemType Directory -Force $stressOutput | Out-Null
$base=[IO.File]::ReadAllText((Join-Path $stressRoot 'tests/performance/benchmark_capture.gd'))
$child=[IO.File]::ReadAllText((Join-Path $stressRoot 'tests/performance/visual_slice_stress.gd')) -replace 'extends "res://tests/performance/benchmark_capture.gd"','extends Base'
$bootstrap="extends SceneTree`nclass Base:`n"+(($base -split "`n"|ForEach-Object{"`t$_"}) -join "`n")+"`nclass Slice:`n"+(($child -split "`n"|ForEach-Object{"`t$_"}) -join "`n")+"`nfunc _initialize():`n`troot.add_child(Slice.new())`n"
$stressScript=Join-Path $stressOutput 'visual-stress.gd';[IO.File]::WriteAllText($stressScript,$bootstrap)
foreach($seed in @(101,202,303)){
 if(Test-Path (Join-Path $stressOutput "m4-$seed.json")){throw 'Output exists; use a fresh revision.'}
 $i=[Diagnostics.ProcessStartInfo]::new();$i.FileName=$Executable;$i.WorkingDirectory=$stressRoot;$i.UseShellExecute=$false;$i.CreateNoWindow=$true;$i.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden;$i.RedirectStandardOutput=$true;$i.RedirectStandardError=$true
 $i.Environment['APPDATA']=Join-Path $PSScriptRoot 'runtime-appdata';$i.Environment['ABYSS_VISUAL_MODE']=$Mode
 $arguments=@('--audio-driver','Dummy','--path',$stressRoot,'--log-file',(Join-Path $stressOutput "seed-$seed-engine.log"),'--script',$stressScript,'--','--m4','--seed',"$seed",'--output',$stressOutput)
 if($Smoke){$arguments+='--smoke'}
 foreach($a in $arguments){$i.ArgumentList.Add($a)}
 $p=[Diagnostics.Process]::new();$p.StartInfo=$i;[void]$p.Start();$o=$p.StandardOutput.ReadToEndAsync();$e=$p.StandardError.ReadToEndAsync()
 if(-not $p.WaitForExit(240000)){$p.Kill($true);$p.WaitForExit()}
 $txt=$o.GetAwaiter().GetResult()+$e.GetAwaiter().GetResult();[IO.File]::WriteAllText((Join-Path $stressOutput "seed-$seed.log"),$txt)
 if($p.ExitCode-ne 0 -or $txt-match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:)'){throw $txt}
 $txt -split "`n"|Where-Object{$_-match 'BENCH '}
}
@{mode=$Mode;executable=$Executable;sha256=(Get-FileHash $Executable -Algorithm SHA256).Hash;embedded_pack_sha256=(Get-FileHash ($Executable.Replace('.console.exe','.exe')) -Algorithm SHA256).Hash;fixture_sha256=(Get-FileHash (Join-Path $stressRoot 'tests/performance/visual_slice_stress.gd')).Hash;smoke=[bool]$Smoke;reference_acceptance=$false;source='supplemental P02, not original M4'}|ConvertTo-Json|Set-Content (Join-Path $stressOutput 'host.json')
