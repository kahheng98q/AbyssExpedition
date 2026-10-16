$ErrorActionPreference = 'Stop'
$lockRoot = Split-Path $PSScriptRoot -Parent
$testRoot = 'user://tests/windows-lock-' + [Guid]::NewGuid().ToString('N') + '/'
function Start-Probe([string[]]$extra) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe'
    $info.WorkingDirectory = $lockRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = Join-Path $PSScriptRoot 'runtime-appdata'
    foreach ($arg in @('--headless','--path',$lockRoot,'--log-file',(Join-Path $lockRoot ('docs/validation/m2-lock-' + [Guid]::NewGuid().ToString('N') + '.log')),'--script','res://tests/lock_probe.gd','--','--root',$testRoot) + $extra) { $info.ArgumentList.Add($arg) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    return $process
}
$owner = Start-Probe @('--hold')
try {
    $line = $owner.StandardOutput.ReadLine()
    while ($null -ne $line -and $line -ne 'LOCK ACQUIRED') { $line = $owner.StandardOutput.ReadLine() }
    if ($line -ne 'LOCK ACQUIRED') { throw 'First process failed to acquire lock' }
    $second = Start-Probe @()
    $stdout = $second.StandardOutput.ReadToEndAsync()
    $stderr = $second.StandardError.ReadToEndAsync()
    if (-not $second.WaitForExit(10000)) { $second.Kill($true); throw 'Competing writer timed out' }
    if ($second.ExitCode -ne 4) { throw 'Second process unexpectedly acquired lock' }
    Write-Output ('COMPETING WRITER PASS: ' + $stdout.GetAwaiter().GetResult().Trim())
    $second.Dispose()
    $owner.Kill($true)
    $owner.WaitForExit()
    $recover = Start-Probe @('--recover','--confirmed')
    $stdout = $recover.StandardOutput.ReadToEndAsync()
    $stderr = $recover.StandardError.ReadToEndAsync()
    if (-not $recover.WaitForExit(10000)) { $recover.Kill($true); throw 'Crash recovery timed out' }
    if ($recover.ExitCode -ne 0) { throw ('Crash recovery failed: ' + $stderr.GetAwaiter().GetResult()) }
    Write-Output ('CRASH RECOVERY PASS: ' + $stdout.GetAwaiter().GetResult().Trim())
    $recover.Dispose()
} finally {
    if (-not $owner.HasExited) { $owner.Kill($true) }
    $owner.Dispose()
}
