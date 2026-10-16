param([switch]$Smoke, [switch]$Release, [switch]$UseTemplate, [switch]$VSync, [string]$EvidenceDirectory)
& (Join-Path $PSScriptRoot 'run_benchmarks.ps1') -Milestone m2 @PSBoundParameters
