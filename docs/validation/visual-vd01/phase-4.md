# Phase 4 — native UI checkpoint · 2026-10-17

Owner `approve all` / `proceed` authorizes the exact Phase4–6 slice; G2 is not granted. See implementation-authorization.json. Before edits, 234 source files, historical outputs and the embedded Windows build were retained under before/. No permanent profile used.

Implemented: shared native Theme, seven reusable UI components, grouped HUD with P01 movement, three actual Resource choice cards, fresh/repeat/duplicate guards, and read-only seed in pause. Gameplay definitions, combat/AI/progression/save rules remain unchanged. Actor/environment art is still procedural at this checkpoint.

## Executed evidence

Pinned Godot4.5 Compatibility, Dummy audio (audio playback not assessed). Full `run_validation.ps1 -M4 -Graphical -Export -DummyAudio` passed content, import, parse, all twelve primary suites and all source/export graphical probes. Raw logs: [phase-4/](phase-4/).

```
SUITE abilities: 123 assertions; 0 failures; 0 skipped
SUITE abilities: 123 assertions; 0 failures; 0 skipped
SUITE full_run: 9 assertions; 0 failures; 0 skipped
SUITE full_run: 9 assertions; 0 failures; 0 skipped
SUITE integration_m1: 37 assertions; 0 failures; 0 skipped
SUITE integration_m1: 37 assertions; 0 failures; 0 skipped
SUITE integration_m2: 45 assertions; 0 failures; 0 skipped
SUITE integration_m2: 45 assertions; 0 failures; 0 skipped
SUITE integration_m3: 196 assertions; 0 failures; 0 skipped
SUITE integration_m3: 196 assertions; 0 failures; 0 skipped
SUITE integration_m4: 3734 assertions; 0 failures; 0 skipped
SUITE integration_m4: 3734 assertions; 0 failures; 0 skipped
SUITE persistence: 343 assertions; 0 failures; 0 skipped
SUITE persistence: 343 assertions; 0 failures; 0 skipped
SUITE progression: 13 assertions; 0 failures; 0 skipped
SUITE progression: 13 assertions; 0 failures; 0 skipped
SUITE recruitment: 293 assertions; 0 failures; 0 skipped
SUITE recruitment: 293 assertions; 0 failures; 0 skipped
SUITE replay: 44 assertions; 0 failures; 0 skipped
SUITE replay: 44 assertions; 0 failures; 0 skipped
SUITE scene_smoke: 150 assertions; 0 failures; 0 skipped
SUITE scene_smoke: 150 assertions; 0 failures; 0 skipped
SUITE unit: 202 assertions; 0 failures; 0 skipped
SUITE unit: 202 assertions; 0 failures; 0 skipped
```

`run_debug_validation.ps1 -SkipRegression -BuildDirectory builds/windows/visual-vd01-phase4-debug`: 69 debug assertions, source97/export97/release denial20; all passed. Root debug logs copied to phase-4/debug-evidence/.

First release regression hit four historical screenshot overwrite errors; no assertion was waived. Wrapper now isolates captures under an explicit evidence directory. Complete rerun `run_m4_release_regressions.ps1 -DummyAudio -EvidenceDirectory docs/validation/visual-vd01/phase-4-release-r1` passed M2/M3/M4 release flows, release denial20 and source debug97.

`run_visual_capture.ps1 -Mode phase-4 -OutputDirectory screenshots/visual-vd01/phase-4/source`: 42 actual native viewport captures, zero errors. Includes 0/100 corruption, boss, two companions/downed, all rescue outcomes, level-up and eight boundary locations at three requested window sizes. See [rectangle measurements](ui-layout.json). Maximum visible HUD panel union is24.52%; this does not prove danger visibility or physical-window scaling.

## Limits kept open

Physical-window/letterbox screenshots, long-value stress, dedicated danger at every edge, complete shared-screen manual input sessions and ten-person recognition remain pending. Source F9 launcher/banner remain developer-only overlays; release denial passes. No human taste/performance acceptance claimed. Baseline full M4 and P02 runs already miss budgets on this non-reference host; see before/perf and before/perf-visual. Phase5 must preserve these restrictions.
