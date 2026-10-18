param([switch]$UseTemplate, [string]$EvidenceDirectory, [switch]$M4Only, [switch]$DummyAudio)
$ErrorActionPreference = 'Stop'
$releaseRoot = Split-Path $PSScriptRoot -Parent
$releaseBinary = Join-Path $releaseRoot 'builds/windows/m4/AbyssExpedition.console.exe'
$releasePack = Join-Path $releaseRoot 'builds/windows/m4/AbyssExpedition.exe'
if ($UseTemplate) { $releaseBinary = Join-Path $PSScriptRoot 'godot-4.5-templates/templates/windows_release_x86_64.exe' }
$releaseEvidence = if ($EvidenceDirectory) { [IO.Path]::GetFullPath($EvidenceDirectory, $releaseRoot) } else { Join-Path $releaseRoot 'docs/validation' }
New-Item -ItemType Directory -Force -Path $releaseEvidence | Out-Null
Write-Output ('RELEASE RUNTIME: ' + $(if ($UseTemplate) { 'unmodified pinned release template + exported pack; not a launch of the generated executable' } else { 'generated executable' }))
$runtimeLabel = if ($UseTemplate) { 'template' } else { 'exe' }
[ordered]@{ runtime = $runtimeLabel; dummy_audio = [bool]$DummyAudio; executable = $releaseBinary; executable_sha256 = (Get-FileHash -LiteralPath $releaseBinary -Algorithm SHA256).Hash; pack_sha256 = (Get-FileHash -LiteralPath $releasePack -Algorithm SHA256).Hash } | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $releaseEvidence 'runtime.json')
function Invoke-ReleaseProbe([string]$name, [string]$script, [string]$binary = $releaseBinary, [string[]]$extra = @()) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $binary
    $info.WorkingDirectory = $releaseRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.Environment['APPDATA'] = Join-Path $PSScriptRoot 'runtime-appdata'
    $packArguments = if ($UseTemplate -and $binary -eq $releaseBinary) { @('--main-pack',$releasePack) } else { @() }
    if ($DummyAudio) { $packArguments += @('--audio-driver','Dummy') }
    foreach ($argument in ($packArguments + @('--path',$releaseRoot,'--log-file',(Join-Path $releaseEvidence "$name-engine.log"),'--script',$script) + $extra)) { $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit(60000)) { $process.Kill($true); throw "$name watchdog" }
    $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    [IO.File]::WriteAllText((Join-Path $releaseEvidence "$name.log"), $output)
    $code = $process.ExitCode
    $process.Dispose()
    if ($code -ne 0 -or $output -match '(?m)^(ERROR:|SCRIPT ERROR|FAIL:)') { throw "$name failed: $output" }
    Write-Output "$name PASS"
    $output -split "`n" | Where-Object { $_ -match 'GRAPHICAL|DEBUG RELEASE|DEBUG GRAPHICAL' } | Write-Output
}
foreach ($id in $(if ($M4Only) { @('m4') } else { @('m2','m3','m4') })) {
    $harness = [IO.File]::ReadAllText((Join-Path $releaseRoot "tests/${id}_graphical_check.gd"))
    $capture = [IO.File]::ReadAllText((Join-Path $releaseRoot 'tests/error_capture.gd'))
    $capture = ($capture -split "\r?\n" | ForEach-Object { "`t" + $_ }) -join "`n"
    $harness = $harness.Replace('extends SceneTree', ("extends SceneTree`n`nclass ErrorCapture:`n" + $capture))
    $harness = $harness.Replace('preload("res://tests/error_capture.gd").new()', 'ErrorCapture.new()')
    $screenshots = $releaseRoot.Replace('\','/') + "/screenshots/convergence-$runtimeLabel-$id-"
    $harness = $harness.Replace(('"res://screenshots/' + $id + '-"'), ('"' + $screenshots + '"'))
    $scriptPath = Join-Path $PSScriptRoot "m4_${id}_release_graphical.gd"
    [IO.File]::WriteAllText($scriptPath, $harness)
    $probeName = if ($id -eq 'm4') { 'm4-current-release' } else { "m4-prior-$id-release" }
    Invoke-ReleaseProbe $probeName $scriptPath
}
if (-not $M4Only) {
    Invoke-ReleaseProbe 'm4-debug-release-denial' (Join-Path $releaseRoot 'tests/debug_release_probe.gd')
    Invoke-ReleaseProbe 'm4-debug-graphical' (Join-Path $releaseRoot 'tests/debug_graphical_check.gd') (Join-Path $PSScriptRoot 'godot-4.5/Godot_v4.5-stable_win64_console.exe') @('--','--captures',(Join-Path $releaseRoot 'screenshots'))
}
