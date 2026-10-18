param([Parameter(Mandatory)][string]$OutputDirectory,[string]$Executable,[switch]$RequireTextContainment,[switch]$InkBounds)
$ErrorActionPreference='Stop'
$auditRoot=Split-Path $PSScriptRoot -Parent
$auditOutput=[IO.Path]::GetFullPath($OutputDirectory,$auditRoot)
if(Test-Path (Join-Path $auditOutput 'context.json')){throw 'Preserve existing evidence; choose a new directory.'}
New-Item -ItemType Directory -Force $auditOutput | Out-Null
if(-not $Executable){$Executable=Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe'}
$auditScript=Join-Path $auditRoot 'tests/visual_ui_boundary_audit.gd'
$pack=$Executable.Replace('.console.exe','.exe')
[ordered]@{utc=[DateTime]::UtcNow.ToString('o');executable=$Executable;executable_sha256=(Get-FileHash $Executable).Hash;embedded_pack_sha256=$(if($pack -ne $Executable){(Get-FileHash $pack).Hash}else{$null});harness_sha256=(Get-FileHash $auditScript).Hash;kind='Native viewport and layout audit; not physical window capture'} | ConvertTo-Json | Set-Content (Join-Path $auditOutput 'context.json')
$auditInfo=[Diagnostics.ProcessStartInfo]::new()
$auditInfo.FileName=$Executable;$auditInfo.WorkingDirectory=$auditRoot;$auditInfo.UseShellExecute=$false
$auditInfo.CreateNoWindow=$true;$auditInfo.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
$auditInfo.RedirectStandardOutput=$true;$auditInfo.RedirectStandardError=$true
$auditInfo.Environment['APPDATA']=Join-Path $PSScriptRoot 'runtime-appdata'
foreach($arg in @('--audio-driver','Dummy','--path',$auditRoot,'--log-file',(Join-Path $auditOutput 'engine.log'),'--script',$auditScript,'--','--output',$auditOutput)){$auditInfo.ArgumentList.Add($arg)}
if($RequireTextContainment){$auditInfo.ArgumentList.Add('--require-text-containment')}
if($InkBounds){$auditInfo.ArgumentList.Add('--ink-bounds')}
$auditProcess=[Diagnostics.Process]::new();$auditProcess.StartInfo=$auditInfo;[void]$auditProcess.Start()
$auditStdout=$auditProcess.StandardOutput.ReadToEndAsync();$auditStderr=$auditProcess.StandardError.ReadToEndAsync()
if(-not $auditProcess.WaitForExit(90000)){$auditProcess.Kill($true);$auditProcess.WaitForExit()}
$auditText=$auditStdout.GetAwaiter().GetResult()+$auditStderr.GetAwaiter().GetResult()
[IO.File]::WriteAllText((Join-Path $auditOutput 'run.log'),$auditText)
Write-Output $auditText
if($auditProcess.ExitCode -ne 0 -or $auditText -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:)'){throw 'UI boundary audit failed; retained logs and measurements identify the exact fixture.'}
