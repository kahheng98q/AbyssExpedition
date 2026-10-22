# Quickstart

Run `Play Debug.cmd` (current source, pinned Godot). Choose party at guild/roster; everyone enters BASE / RUN Lv1. Earn XP; RUN Lv15 pauses for each living member's two-branch preview. Confirm applies only this run; Cancel defers, HUD Promotion reopens. Restart clears level/upgrades/branches. F9/DEV remains accessible; XP/eligibility controls require a current sandbox run. Existing materials ID now grants run eligibility, costs nothing.

Focused: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_validation.ps1 -OnlySuites run_promotion,progression,persistence,abilities,integration_m2,replay -DummyAudio -EvidenceDirectory docs/validation/run-level-promotion/focused` (PowerShell callers may pass an actual string array).
Full: `./tools/run_validation.ps1 -M4 -Graphical -Export -DummyAudio -EvidenceDirectory docs/validation/run-level-promotion/full -BuildDirectory builds/windows/run-level-promotion/full`.
Logs/results: [validation](../../docs/validation/run-level-promotion/results.md). Human checks: natural Lv15 reachability, party choice clarity, cancellation/reopen, 640x360 readability and original sword examples; no enjoyment/performance acceptance inferred from automation.
