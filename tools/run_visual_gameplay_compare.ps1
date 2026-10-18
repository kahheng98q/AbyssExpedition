param([string]$BeforeExecutable,[string]$AfterExecutable,[string]$EvidenceDirectory)
$ErrorActionPreference='Stop'
$compareRoot=Split-Path $PSScriptRoot -Parent
$compareOutput=[IO.Path]::GetFullPath($EvidenceDirectory,$compareRoot)
New-Item -ItemType Directory -Force $compareOutput | Out-Null
foreach($entry in @(@('before',$BeforeExecutable),@('after',$AfterExecutable))){
 $name=$entry[0];$binary=$entry[1];$target=Join-Path $compareOutput "$name.json"
 if(Test-Path $target){throw 'Observation exists; preserve it and use a new directory.'}
 $info=[Diagnostics.ProcessStartInfo]::new();$info.FileName=$binary;$info.WorkingDirectory=$compareRoot;$info.UseShellExecute=$false;$info.CreateNoWindow=$true;$info.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden;$info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
 $info.Environment['APPDATA']=Join-Path $PSScriptRoot 'runtime-appdata'
 foreach($arg in @('--audio-driver','Dummy','--path',$compareRoot,'--log-file',(Join-Path $compareOutput "$name-engine.log"),'--script',(Join-Path $compareRoot 'tests/visual_gameplay_capture.gd'),'--','--output',$target)){$info.ArgumentList.Add($arg)}
 $p=[Diagnostics.Process]::new();$p.StartInfo=$info;[void]$p.Start();$stdout=$p.StandardOutput.ReadToEndAsync();$stderr=$p.StandardError.ReadToEndAsync()
 if(-not $p.WaitForExit(60000)){$p.Kill($true);$p.WaitForExit()}
 $txt=$stdout.GetAwaiter().GetResult()+$stderr.GetAwaiter().GetResult();[IO.File]::WriteAllText((Join-Path $compareOutput "$name.log"),$txt)
 if($p.ExitCode-ne 0 -or $txt-match '(?m)^(ERROR:|SCRIPT ERROR|FAIL:)'){throw $txt}
}
$a=Get-Content -Raw (Join-Path $compareOutput 'before.json')|ConvertFrom-Json
$b=Get-Content -Raw (Join-Path $compareOutput 'after.json')|ConvertFrom-Json
$equal=($a.observations|ConvertTo-Json -Depth 100 -Compress)-ceq($b.observations|ConvertTo-Json -Depth 100 -Compress)
[ordered]@{
 observations_equal=$equal;ticks=$a.ticks;seed=$a.seed;simulation_equal=$a.simulation_version-eq$b.simulation_version
 before_catalog=$a.catalog_digest;after_catalog=$b.catalog_digest
 before_exe_sha256=(Get-FileHash $BeforeExecutable).Hash;after_exe_sha256=(Get-FileHash $AfterExecutable).Hash
 before_embedded_pack_sha256=(Get-FileHash ($BeforeExecutable.Replace('.console.exe','.exe'))).Hash
 after_embedded_pack_sha256=(Get-FileHash ($AfterExecutable.Replace('.console.exe','.exe'))).Hash
 scope='Milo, two fixed enemies, four directions,120 actual simulation ticks; not an entire natural run'
}|ConvertTo-Json|Set-Content (Join-Path $compareOutput 'comparison.json')
if(-not $equal -or $a.simulation_version-ne$b.simulation_version){throw 'Unreviewed simulation observation difference.'}
Write-Output 'BEFORE/AFTER GAMEPLAY:120 ticks identical; catalog protection retained with separate hashes.'
