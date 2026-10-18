param([ValidateSet('before','phase-4','after')][string]$Mode, [string]$OutputDirectory, [string]$Executable)
$ErrorActionPreference='Stop'
$captureRoot=Split-Path $PSScriptRoot -Parent
if (-not $Mode -or -not $OutputDirectory) { throw 'Explicit Mode and OutputDirectory required.' }
$captureOutput=[IO.Path]::GetFullPath($OutputDirectory,$captureRoot)
if (Test-Path (Join-Path $captureOutput 'capture-manifest.json')) { throw 'Output already exists; preserve the previous capture.' }
New-Item -ItemType Directory -Force $captureOutput | Out-Null
if (-not $Executable) { $Executable=Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe' }
$captureScript=Join-Path $captureRoot 'tests/visual_slice_capture.gd'
$embeddedPack = $Executable.Replace('.console.exe','.exe')
[ordered]@{mode=$Mode;executable=$Executable;executable_sha256=(Get-FileHash $Executable -Algorithm SHA256).Hash;embedded_pack_sha256=$(if($embeddedPack -ne $Executable){(Get-FileHash $embeddedPack -Algorithm SHA256).Hash}else{$null});harness_sha256=(Get-FileHash $captureScript -Algorithm SHA256).Hash;utc=[DateTime]::UtcNow.ToString('o');capture_kind='native Godot viewport, not physical-window screenshot'} | ConvertTo-Json | Set-Content (Join-Path $captureOutput 'capture-context.json')
$info=[Diagnostics.ProcessStartInfo]::new()
$info.FileName=$Executable; $info.WorkingDirectory=$captureRoot; $info.UseShellExecute=$false; $info.CreateNoWindow=$true
$info.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden; $info.RedirectStandardOutput=$true; $info.RedirectStandardError=$true
$info.Environment['APPDATA']=Join-Path $PSScriptRoot 'runtime-appdata'
foreach($arg in @('--audio-driver','Dummy','--path',$captureRoot,'--log-file',(Join-Path $captureOutput 'engine.log'),'--script',$captureScript,'--','--mode',$Mode,'--output',$captureOutput)) { $info.ArgumentList.Add($arg) }
$p=[Diagnostics.Process]::new(); $p.StartInfo=$info; [void]$p.Start()
$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync()
if (-not $p.WaitForExit(90000)) { $p.Kill($true); $p.WaitForExit() }
$captureText=$stdout.GetAwaiter().GetResult()+$stderr.GetAwaiter().GetResult()
[IO.File]::WriteAllText((Join-Path $captureOutput 'run.log'),$captureText)
if ($p.ExitCode -ne 0 -or $captureText -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:)') { throw $captureText }
Write-Output $captureText
