param([Parameter(Mandatory)][string]$OutputDirectory,[string]$Executable,[string]$ScriptPath)
$ErrorActionPreference='Stop'
$captureRoot=Split-Path $PSScriptRoot -Parent
$captureOutput=[IO.Path]::GetFullPath($OutputDirectory,$captureRoot)
if(Test-Path (Join-Path $captureOutput 'context.json')){throw 'Preserve existing capture; choose a new directory.'}
New-Item -ItemType Directory -Force $captureOutput | Out-Null
if(-not $Executable){$Executable=Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe'}
$captureScript=Join-Path $captureRoot 'tests/visual_wallclock_capture.gd'
if($ScriptPath){$captureScript=[IO.Path]::GetFullPath($ScriptPath,$captureRoot)}
$capturePack=$Executable.Replace('.console.exe','.exe')
[ordered]@{utc=[DateTime]::UtcNow.ToString('o');executable=$Executable;executable_sha256=(Get-FileHash $Executable).Hash;embedded_pack_sha256=$(if($capturePack -ne $Executable){(Get-FileHash $capturePack).Hash}else{$null});harness_sha256=(Get-FileHash $captureScript).Hash} | ConvertTo-Json | Set-Content (Join-Path $captureOutput 'context.json')
$captureInfo=[Diagnostics.ProcessStartInfo]::new()
$captureInfo.FileName=$Executable;$captureInfo.WorkingDirectory=$captureRoot;$captureInfo.UseShellExecute=$false
$captureInfo.CreateNoWindow=$true;$captureInfo.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
$captureInfo.RedirectStandardOutput=$true;$captureInfo.RedirectStandardError=$true
$captureInfo.Environment['APPDATA']=Join-Path $PSScriptRoot 'runtime-appdata'
foreach($arg in @('--audio-driver','Dummy','--path',$captureRoot,'--log-file',(Join-Path $captureOutput 'engine.log'),'--script',$captureScript,'--','--output',$captureOutput)){$captureInfo.ArgumentList.Add($arg)}
$captureProcess=[Diagnostics.Process]::new();$captureProcess.StartInfo=$captureInfo;[void]$captureProcess.Start()
$captureOut=$captureProcess.StandardOutput.ReadToEndAsync();$captureErr=$captureProcess.StandardError.ReadToEndAsync()
if(-not $captureProcess.WaitForExit(90000)){$captureProcess.Kill($true);$captureProcess.WaitForExit()}
$captureText=$captureOut.GetAwaiter().GetResult()+$captureErr.GetAwaiter().GetResult()
[IO.File]::WriteAllText((Join-Path $captureOutput 'run.log'),$captureText)
Write-Output $captureText
if($captureProcess.ExitCode -ne 0 -or $captureText -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:)'){throw 'Wall-clock capture failed; see retained evidence.'}
