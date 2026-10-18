param([Parameter(Mandatory)][string]$EvidenceDirectory)
$ErrorActionPreference = 'Stop'
$probeRoot = Split-Path $PSScriptRoot -Parent
$probeOutput = [IO.Path]::GetFullPath($EvidenceDirectory, $probeRoot)
if (Test-Path -LiteralPath $probeOutput) { throw 'Use a fresh evidence directory.' }
New-Item -ItemType Directory -Path $probeOutput | Out-Null
$probeBase = [IO.File]::ReadAllText((Join-Path $probeRoot 'tests/performance/benchmark_capture.gd'))
$probeChild = [IO.File]::ReadAllText((Join-Path $probeRoot 'tests/performance/visual_cost_probe.gd')).Replace('extends "res://tests/performance/benchmark_capture.gd"', 'extends Base')
$probeScript = "extends SceneTree`nclass Base:`n" + (($probeBase -split "`n" | ForEach-Object { "`t$_" }) -join "`n") + "`nclass Probe:`n" + (($probeChild -split "`n" | ForEach-Object { "`t$_" }) -join "`n") + "`nfunc _initialize():`n`troot.add_child(Probe.new())`n"
$probePath = Join-Path $probeOutput 'probe.gd'
[IO.File]::WriteAllText($probePath, $probeScript)
$probeBinary = Join-Path $probeRoot 'builds/windows/m4/AbyssExpedition.exe'
@{ embedded_pack_sha256=(Get-FileHash $probeBinary).Hash; fixture_sha256=(Get-FileHash (Join-Path $probeRoot 'tests/performance/benchmark_capture.gd')).Hash; probe_sha256=(Get-FileHash $probePath).Hash; diagnostic_only=$true; reference_acceptance=$false; utc=[DateTime]::UtcNow.ToString('o') } | ConvertTo-Json | Set-Content (Join-Path $probeOutput 'context.json')
foreach ($probeMode in @('baseline','world-hidden','presenters-off','both')) {
    $probeModeOutput = Join-Path $probeOutput $probeMode
    New-Item -ItemType Directory -Path $probeModeOutput | Out-Null
    $probeInfo = [Diagnostics.ProcessStartInfo]::new()
    $probeInfo.FileName=$probeBinary
    $probeInfo.WorkingDirectory=$probeRoot
    $probeInfo.UseShellExecute=$false
    $probeInfo.CreateNoWindow=$true
    $probeInfo.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
    $probeInfo.RedirectStandardOutput=$true
    $probeInfo.RedirectStandardError=$true
    $probeInfo.Environment['APPDATA']=Join-Path $PSScriptRoot 'runtime-appdata'
    $probeInfo.Environment['ABYSS_COST_MODE']=$probeMode
    foreach ($probeArg in @('--audio-driver','Dummy','--path',$probeRoot,'--log-file',(Join-Path $probeModeOutput 'engine.log'),'--script',$probePath,'--','--m4','--seed','101','--output',$probeModeOutput)) { $probeInfo.ArgumentList.Add($probeArg) }
    $probeProcess=[Diagnostics.Process]::new()
    $probeProcess.StartInfo=$probeInfo
    [void]$probeProcess.Start()
    $probeOut=$probeProcess.StandardOutput.ReadToEndAsync()
    $probeErr=$probeProcess.StandardError.ReadToEndAsync()
    if (-not $probeProcess.WaitForExit(60000)) { $probeProcess.Kill($true); throw 'Probe watchdog.' }
    $probeText=$probeOut.GetAwaiter().GetResult()+$probeErr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $probeModeOutput 'run.log'),$probeText)
    if ($probeProcess.ExitCode -ne 0 -or $probeText -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:)') { throw $probeText }
    $probeText -split "`n" | Where-Object { $_ -match 'BENCH seed' }
    $probeProcess.Dispose()
}
