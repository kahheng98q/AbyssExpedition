# Debug Panel permanent protection — 2026-10-18

## Investigation and cause

The original scene, four-tab script and 28-action service still exist and are wired in current source. `project.godot` starts `scenes/app/app.tscn`; there are no autoloads. App remains alive while navigation replaces screen/modal/expedition hosts. Debug is an App child outside those hosts. Layer 100 is above screen 10/modal 20; `PROCESS_MODE_ALWAYS` already permits paused input. Native `OS.has_feature("debug")` correctly prevents release mounting. No source evidence or failing transition test establishes that polish deleted the panel.

The concrete access/delivery defect is the entry path: `Play Debug.cmd` launched `builds/windows/debug-panel-access-fix/`, an October 15 artifact. The Q1 documented executable is a **release** export, which correctly has no debug UI. Neither path reliably selects the latest source **with** development tools. F9 used direct logical/physical key handling but had **no InputMap action**. Standard validation omitted `debug_panel`; separate debug/quality workflows ran it. These verified defects allowed access requirements to drift. We cannot infer which binary or OS event caused the user's particular observation.

## Repair boundaries

- Keep the original scene/service/controls. Extract its mount into idempotent `App.initialize_debug_ui()`; repeated calls retain one panel. No new panel/autoload, gameplay rules, profile schema or data Resources.
- Existing launcher becomes **DEV**, anchored top-right below the HUD; its viewport parent ignores empty-area mouse input. Existing overlay, banner, focus and pause-token ownership remain.
- Visual review found the old startup banner obscured guild text. Startup now shows only DEV; sandbox/FPS status appears at the bottom center after opening, and an unavailable-profile reason expands there when needed.
- Register debug-only `debug_panel_toggle` / physical F9; retain logical/physical raw-key compatibility and echo rejection. Release registers no action and mounts no UI; service guards remain.
- `Play Debug.cmd` launches current source through pinned Godot, with a missing-engine message, instead of a historical export.
- `run_validation.ps1` always includes `debug_panel`, even with `-OnlySuites`. `-Graphical` adds source DEV/F9/route checks; `-Export` adds actual-release denial and debug export; both switches probe debug graphics. Dedicated validation accepts isolated evidence paths/Dummy audio.
- AGENTS.md protects future Spec Kit/polish work. [Manual smoke](../developer-debug-panel.md#required-manual-graphical-smoke-human-acceptance-remains-pending) must be reported separately.

## Executed evidence

Pinned engine `4.5.stable.official.876b29033`; Windows, Dummy audio, unique profiles under workspace-scoped child APPDATA. Harnesses did not use the normal player profile.

```powershell
# Before runtime changes: red regression
./tools/run_validation.ps1 -OnlySuites debug_panel -DummyAudio -EvidenceDirectory docs/validation/debug-protected-20261018/before
# Focused repair checks
./tools/run_validation.ps1 -OnlySuites debug_panel,scene_smoke -DummyAudio -EvidenceDirectory docs/validation/debug-protected-20261018/after
# Full normal workflow with automatic debug gate
./tools/run_validation.ps1 -M4 -Graphical -DummyAudio -EvidenceDirectory docs/validation/debug-protected-20261018/workflow
# First export attempt; stops at blocked debug launch
./tools/run_debug_validation.ps1 -SkipRegression -DummyAudio -BuildDirectory builds/windows/debug-protected-20261018 -EvidenceDirectory docs/validation/debug-protected-20261018
# Final current-source exports and actual executable probes
./tools/run_debug_validation.ps1 -SkipRegression -DummyAudio -BuildDirectory builds/windows/debug-protected-20261018 -EvidenceDirectory docs/validation/debug-protected-20261018/final-exports
# After isolating M4 capture output; also proves focused runs include debug
./tools/run_validation.ps1 -OnlySuites scene_smoke -M4 -Graphical -DummyAudio -EvidenceDirectory docs/validation/debug-protected-20261018/final-graphical-isolated
```

| Check | Actual result | Evidence |
| --- | --- | --- |
| Before repair | 126 assertions / **3 failures**: action, physical F9 registration, DEV label | [red log](debug-protected-20261018/before/debug_panel.log) |
| Focused repair | Debug 126; scenes 132; 0 failures/skips | [debug](debug-protected-20261018/after/debug_panel.log), [scenes](debug-protected-20261018/after/scene_smoke.log) |
| Full normal workflow — native suites | 13 suites / **5,297 assertions**, 0 failures/skips | [totals](debug-protected-20261018/workflow/suite-summary.json) |
| Import/parser/content/invalid suite/invalid seed | Pass; 51 root Resources, 27 catalog scenes, 99 scripts; content digest unchanged | [content](debug-protected-20261018/workflow/content.log) |
| Source debug graphical | **118 assertions / 0 failures**; three dimensions | [log](debug-protected-20261018/workflow/debug-graphical.log) |
| Source M1–M4 graphical — final focused workflow | All pass; scene smoke 132 and automatic debug 126 also pass | [M1](debug-protected-20261018/final-graphical-isolated/graphical.log), [M2](debug-protected-20261018/final-graphical-isolated/m2-graphical.log), [M3](debug-protected-20261018/final-graphical-isolated/m3-graphical.log), [M4](debug-protected-20261018/final-graphical-isolated/m4-graphical.log) |
| Final new debug/release exports | Export commands pass; fresh task directory | [debug](debug-protected-20261018/final-exports/debug-export.log), [release](debug-protected-20261018/final-exports/debug-release-export.log), [hashes](debug-protected-20261018/build-sha256.json) |
| Final actual exported debug graphical | **118 assertions / 0 failures**, three sizes | [log](debug-protected-20261018/final-exports/debug-exported-graphical.log) |
| Final actual new release EXE | **41 assertions / 0 failures**, exit 0 | [log](debug-protected-20261018/final-exports/debug-release-denial.log) |

Failure history is retained: [first wrapper 4551](debug-protected-20261018/first-export/debug-exported-graphical.log), [first direct debug denial](debug-protected-20261018/first-export/direct-debug.log). At that point the dedicated script stopped before release probing, so a separate `ProcessStartInfo` call ran the then-new **release EXE directly**, `--path <project> --audio-driver Dummy --script <project>/tests/debug_release_probe.gd --headless`, child APPDATA=`tools/runtime-appdata`; [41 checks passed](debug-protected-20261018/first-export/direct-release.log). Final re-export and both executable probes now pass through the dedicated script. No OS security settings changed; no specific reason for the initial host denial is inferred. The normal workflow's `-Export` branch was inspected but not separately rerun against historical milestone builds.

After the banner refinement, all 13 native suites and debug graphics passed again, but M4 failed to overwrite 3 existing PNGs (6 failures including captured logger errors). A no-code retry failed on 4 different PNGs (8 failures): [full-workflow failure](debug-protected-20261018/workflow/m4-graphical.log), [retry](debug-protected-20261018/graphical-retry/m4-graphical.log). Isolating M4 output resolved those failures; the next attempt exposed the same issue in M1 (3 old PNG writes failed): [M1 failure](debug-protected-20261018/final-graphical/graphical.log). No disk-space shortage was found; the precise external file-access cause is unconfirmed. M1–M4 now accept `--captures`; normal validation supplies evidence subdirectories instead of overwriting shared historical screenshots. Default/release-harness prefixes stay compatible. The final focused graphical workflow passes with isolated capture output. This changes test output paths only, not gameplay.

Integration checks all 28 actions have a valid handler/connected button and retain existing behavior checks for levels/XP, promotion/materials, companions, safe enemy/boss spawning, God Mode/HP, speed, seed restart and save isolation. New checks deliver F9 through engine input, preserve panel identity across menu/guild/selection/roster/recruitment/promotion/restart, and preserve menu tree pause. Graphical tests use engine mouse hit testing across those screens, battle/manual pause, restart and results; existing focused XP typing, all tabs/scrolling and promotion checks remain. Release denies **all 28 actions**, initialization/F9, direct mutation and forged health/speed state.

## Visual review and remaining acceptance

Inspected new real menu, combat and XP-panel captures: DEV appears below the right HUD; tabs/feedback fit the logical viewport. [Menu](../../screenshots/debug-protected-20261018-menu.png) · [combat](../../screenshots/debug-protected-20261018-combat.png) · [panel](../../screenshots/debug-protected-20261018-panel.png). Instantaneous screenshot FPS is diagnostic, not a benchmark.

Offline documentation check: [178 local links/assets](debug-protected-20261018/document-checks.json), dashboard anchors/image alt text/inline JavaScript and no remote runtime dependencies checked; 0 failures.

**已实现并验证**：源码及实际Debug的DEV/F9、切换/暂停/重开、原有动作接线与存档隔离、实际Release禁用。**待人工验收**：Explorer双击、物理鼠标和F9/Fn、OS焦点/缩放、入口是否足够低干扰及正常试玩。按链接烟测记录结果，不以注入事件代替真人测试。旧构建及历史证据保留；没有新增体验/性能验收结论。
