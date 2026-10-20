@echo off
rem Run current source with the pinned debug engine; never launch a stale export.
if not exist "%~dp0tools\godot-4.5\Godot_v4.5-stable_win64.exe" (
  echo Missing pinned Godot 4.5. See docs\developer-debug-panel.md.
  pause
  exit /b 1
)
start "" "%~dp0tools\godot-4.5\Godot_v4.5-stable_win64.exe" --path "%~dp0."
