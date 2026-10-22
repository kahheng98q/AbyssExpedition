param([switch]$Graphical, [switch]$Export, [switch]$M2 = $true, [switch]$M3, [switch]$M4, [string]$EvidenceDirectory, [string[]]$OnlySuites = @(), [switch]$DummyAudio, [string]$BuildDirectory)
$ErrorActionPreference = 'Stop'
$validationRoot = Split-Path 'C:\Users\kahhe\Desktop\Project\new-game-project\tools' -Parent
$godotBinary = Join-Path 'C:\Users\kahhe\Desktop\Project\new-game-project\tools' 'godot-4.5/Godot_v4.5-stable_win64_console.exe'
if ($env:ABYSS_GODOT_EXE) { $godotBinary = $env:ABYSS_GODOT_EXE }
if (-not (Test-Path -LiteralPath $godotBinary)) { throw 'Godot binary missing. Set ABYSS_GODOT_EXE to Godot 4.5 console.' }
$godotBinary = (Resolve-Path -LiteralPath $godotBinary).Path
$validationDirectory = Join-Path $validationRoot 'docs/validation'
if ($EvidenceDirectory) { $validationDirectory = [IO.Path]::GetFullPath($EvidenceDirectory, $validationRoot) }
$runtimeData = Join-Path 'C:\Users\kahhe\Desktop\Project\new-game-project\tools' 'runtime-appdata'
New-Item -ItemType Directory -Force $validationDirectory,$runtimeData | Out-Null
function Invoke-Check([string]$name, [string[]]$arguments, [int]$expectedExit = 0, [int]$timeout = 60, [string]$executable = $godotBinary) {
    if ($DummyAudio) { $arguments = @('--audio-driver','Dummy') + $arguments }
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $executable
    $info.WorkingDirectory = $validationRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = $runtimeData
    foreach ($argument in $arguments) { $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $timedOut = -not $process.WaitForExit($timeout * 1000)
    if ($timedOut) { $process.Kill($true); $process.WaitForExit() }
    $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $validationDirectory "$name.log"), $output)
    $exitCode = $process.ExitCode
    $process.Dispose()
    if ($timedOut) { throw "$name watchdog expired; stdout/stderr and partial evidence retained" }
    if ($exitCode -ne $expectedExit -or $output -match '(?m)^(SCRIPT ERROR|ERROR:|FAIL:|Debugger Break)') { throw "$name failed (exit $exitCode):`n$output" }
    Write-Output "$name PASS (exit $exitCode)"
    $output -split "`n" | Where-Object { $_ -match 'SUITE|CONTENT:|AUTOPLAY|GRAPHICAL:|BENCH ' } | Write-Output
}
function New-SwordHarness([string]$filename) {
    $harness = [IO.File]::ReadAllText((Join-Path $validationRoot "tests/$filename.gd"))
    $capture = [IO.File]::ReadAllText((Join-Path $validationRoot 'tests/error_capture.gd'))
    $capture = ($capture -split "\r?\n" | ForEach-Object { "`t" + $_ }) -join "`n"
    $harness = $harness.Replace('extends SceneTree', ("extends SceneTree`n`nclass ErrorCapture:`n" + $capture))
    $harness = $harness.Replace('preload("res://tests/error_capture.gd").new()', 'ErrorCapture.new()')
    $harnessPath = Join-Path $validationDirectory "$filename-external.gd"
    [IO.File]::WriteAllText($harnessPath, $harness)
    return $harnessPath
}
function Invoke-SwordRealtime([string]$kind, [string]$executable = $godotBinary) {
    $harnessPath = New-SwordHarness 'sword_preview_realtime_check'
    $combinations = @(@{hostMode='normal';speed=1})
    if ($kind -ne 'release') { $combinations += @(@{hostMode='dev';speed=1},@{hostMode='dev';speed=2},@{hostMode='dev';speed=4}) }
    foreach ($combination in $combinations) {
        $id = "sword-realtime-$kind-$($combination.hostMode)-$($combination.speed)"
        $target = Join-Path $validationDirectory $id
        if (Test-Path -LiteralPath $target) { throw "Realtime evidence already exists: $target" }
        New-Item -ItemType Directory $target | Out-Null
        [ordered]@{kind=$kind;host=$combination.hostMode;speed=$combination.speed;executable=$executable;executable_sha256=(Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash;fixture_sha256=(Get-FileHash -LiteralPath (Join-Path $validationRoot 'tests/sword_preview_realtime_check.gd') -Algorithm SHA256).Hash;clock='production monotonic';wall_deadline_seconds=180} | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $target 'invocation.json')
        Write-Output "$id START (ten real cycles, native focus, 180-second watchdog)"
        Invoke-Check $id @('--path',$validationRoot,'--log-file',(Join-Path $target 'engine.log'),'--script',$harnessPath,'--','--host',$combination.hostMode,'--speed',[string]$combination.speed,'--kind',$kind,'--output',$target) 0 180 $executable
    }
}
