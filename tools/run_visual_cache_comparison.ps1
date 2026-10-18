param([Parameter(Mandatory)][string]$EvidenceDirectory)
$ErrorActionPreference='Stop'
$comparisonRoot=Split-Path $PSScriptRoot -Parent
$comparisonOutput=[IO.Path]::GetFullPath($EvidenceDirectory,$comparisonRoot)
if(Test-Path -LiteralPath $comparisonOutput){throw 'Preserve prior captures; use a fresh directory.'}
New-Item -ItemType Directory -Path $comparisonOutput | Out-Null
$comparisonBase=[IO.File]::ReadAllText((Join-Path $comparisonRoot 'tests/performance/benchmark_capture.gd'))
$comparisonBase=$comparisonBase.Replace('var warmup: float = 30.0','var warmup: float = 10.0').Replace('var capture: float = 120.0','var capture: float = 10.0')
$comparisonChild=[IO.File]::ReadAllText((Join-Path $comparisonRoot 'tests/performance/visual_slice_stress.gd')).Replace('extends "res://tests/performance/benchmark_capture.gd"','extends Base')
$comparisonScript="extends SceneTree`nclass Base:`n"+(($comparisonBase -split "`n" | ForEach-Object{"`t$_"}) -join "`n")+"`nclass Slice:`n"+(($comparisonChild -split "`n" | ForEach-Object{"`t$_"}) -join "`n")+"`nfunc _initialize():`n`troot.add_child(Slice.new())`n"
$comparisonPath=Join-Path $comparisonOutput 'diagnostic-only.gd'
[IO.File]::WriteAllText($comparisonPath,$comparisonScript)
$comparisonOld=Join-Path $comparisonRoot 'docs/validation/visual-vd01/completion-r2/retained-p2/build/AbyssExpedition.exe'
$comparisonNew=Join-Path $comparisonRoot 'builds/windows/m4/AbyssExpedition.exe'
$comparisonRows=@()
foreach($comparisonRole in @('A-parent','B-cache','B-cache','A-parent')){
    $comparisonIndex=$comparisonRows.Count
    $comparisonBinary=if($comparisonRole -eq 'A-parent'){$comparisonOld}else{$comparisonNew}
    $comparisonFolder=Join-Path $comparisonOutput "$comparisonIndex-$comparisonRole"
    New-Item -ItemType Directory -Path $comparisonFolder | Out-Null
    $comparisonInfo=[Diagnostics.ProcessStartInfo]::new()
    $comparisonInfo.FileName=$comparisonBinary
    $comparisonInfo.WorkingDirectory=$comparisonRoot
    $comparisonInfo.UseShellExecute=$false
    $comparisonInfo.CreateNoWindow=$true
    $comparisonInfo.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
    $comparisonInfo.RedirectStandardOutput=$true
    $comparisonInfo.RedirectStandardError=$true
    $comparisonInfo.Environment['APPDATA']=Join-Path $PSScriptRoot 'runtime-appdata'
    $comparisonInfo.Environment['ABYSS_VISUAL_MODE']='after'
    foreach($comparisonArg in @('--audio-driver','Dummy','--path',$comparisonRoot,'--log-file',(Join-Path $comparisonFolder 'engine.log'),'--script',$comparisonPath,'--','--m4','--seed','101','--output',$comparisonFolder)){$comparisonInfo.ArgumentList.Add($comparisonArg)}
    $comparisonProcess=[Diagnostics.Process]::new()
    $comparisonProcess.StartInfo=$comparisonInfo
    [void]$comparisonProcess.Start()
    $comparisonOut=$comparisonProcess.StandardOutput.ReadToEndAsync()
    $comparisonErr=$comparisonProcess.StandardError.ReadToEndAsync()
    if(-not $comparisonProcess.WaitForExit(60000)){$comparisonProcess.Kill($true);throw 'Comparison watchdog'}
    $comparisonText=$comparisonOut.GetAwaiter().GetResult()+$comparisonErr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $comparisonFolder 'run.log'),$comparisonText)
    if($comparisonProcess.ExitCode -ne 0 -or $comparisonText -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:)'){throw $comparisonText}
    $comparisonRows+=@{order=$comparisonIndex;role=$comparisonRole;embedded_pack_sha256=(Get-FileHash $comparisonBinary).Hash;summary=Get-Content (Join-Path $comparisonFolder 'm4-101.json') -Raw | ConvertFrom-Json}
    $comparisonText -split "`n" | Where-Object{$_ -match 'BENCH seed='}
    $comparisonProcess.Dispose()
}
@{diagnostic_only=$true;reference_acceptance=$false;sequence='ABBA';warmup_active_seconds=10;capture_active_seconds=10;fixture_sha256=(Get-FileHash $comparisonPath).Hash;note='Same P02 workload and seed101; shortened diagnostic, never a replacement for30+120 gates.';runs=$comparisonRows}|ConvertTo-Json -Depth 10|Set-Content (Join-Path $comparisonOutput 'comparison.json')
