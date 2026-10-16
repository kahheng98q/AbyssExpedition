# Implementation continuation — 2026-10-15

The user authorized continuing despite the unchecked gameplay checklist. Checklist files and markers were left unchanged: requirements 16/16 checked; gameplay 0/40 checked. No extension configuration or AGENTS.md was found. The workspace has no Git repository; the existing Godot/tool/build/runtime/log ignore patterns were reviewed. No additional technology-specific ignore file was needed.

M1/M2 gameplay is already implemented. This continuation executed regression checks and corrected stale run instructions; it did not introduce M3/M4 code or claim missing acceptance evidence. The task plan requires T115 before T116. Missing participants, ordinary manual sessions and reference-hardware measurements leave that gate open.

## Executed checks

From `C:/Users/kahhe/Desktop/Project/new-game-project`:

```powershell
& ./tools/run_validation.ps1 -M2 -Graphical
& ./tools/check_m2_lock.ps1
Get-FileHash -Algorithm SHA256 -LiteralPath 'builds/windows/m1/AbyssExpedition.exe','builds/windows/m2/AbyssExpedition.exe'
```

Verified local executable: `tools/godot-4.5/Godot_v4.5-stable_win64_console.exe`, version `4.5.stable.official.876b29033`. Content digest: `318c0d513ea44edd6741a532de640dfabfc410fc99e31bfbb4ec0832ef1716d4`. Catalog validation loaded 39 root Resources, 21 scenes and 77 shipping scripts, including the separately added developer tools.

Import, runner parse and content checks exited 0. Native suite results:

| Suite | Assertions | Failures | Skips |
| --- | ---: | ---: | ---: |
| unit | 172 | 0 | 0 |
| scene_smoke | 103 | 0 | 0 |
| integration_m1 | 37 | 0 | 0 |
| replay | 20 | 0 | 0 |
| full_run | 9 | 0 | 0 |
| progression | 13 | 0 | 0 |
| persistence | 136 | 0 | 0 |
| abilities | 107 | 0 | 0 |
| integration_m2 | 36 | 0 | 0 |
| **Total** | **633** | **0** | **0** |

Unknown-suite and invalid-seed probes each returned the expected exit 2. Seed-101 automated base-starter victories retained the recorded timings: Aren 33754 ticks, Lia 33206, Milo 33080. These are accelerated fixtures, not ordinary human victories. Logs: `import.log`, `parse-runner.log`, `content.log`, the nine named suite logs, `reject-unknown-suite.log` and `reject-invalid-seed.log` in this directory.

The source graphical harnesses exited 0 and reported zero failures at actual window sizes 1280×720, 1920×1080 and 1371×813. They covered all starters, menu/selection/combat/choices/pause/boss patterns/results, roster/promotion previews, all six branch attacks, companions and downing. Logs: `graphical.log`, `m2-graphical.log` and their engine logs. Three existing captures were inspected before this run completed: roster, Milo promotion and Aren combat; they are visual context only, not a new interactive playtest. The automated captures do not establish displayed input latency, moving pixel jitter, fun, warning comprehension or completion of manual phase gates.

The Windows lock probe confirmed that a competing process refused the owned lock (exit 4). After terminating the fixture owner, explicitly confirmed recovery acquired and released the stale test lock (exit 0). Unique `m2-lock-*.log` files record the probe processes. Each test uses isolated `user://tests/` storage with child APPDATA scoped to `tools/runtime-appdata`.

No exports were rebuilt. Retained SHA-256 values still match prior delivery:

| Release | SHA-256 |
| --- | --- |
| M1 | `70B1F7A4B7017C704BCB300ABE7EA74DDF038D6BD7394B0029900B56C602DE8D` |
| M2 | `C762074AD6553EF696257926A8C8CDBA4C2BE80520F7CF56120FA6CA8AF8C2D8` |

## Outstanding prerequisites

No task checkbox was changed: these checks satisfy only portions of already-open acceptance tasks.

| Open tasks | Evidence still needed |
| --- | --- |
| T018, T032, T050, T059, T066 | Complete interactive phase checks, including controls/focus, motion, pause overlap, warning avoidance and outcome/retry paths |
| T069, T113 | Specified reference-machine protocol, uncapped release profiling and displayed input/hit latency; prior alternate-machine M2 p95 exceeded 16.67 ms, with two seeds also exceeding the p99 target |
| T070 | Ten-player first-use, starter distinction, enjoyment/retry and dense-danger recognition study |
| T071 | Twenty ordinary solo victories, split 7/7/6 across starters, with the required active-duration results |
| T072, T114 | Complete ordinary offline release sessions and manual path matrices, including save dialogs and quit/reopen |
| T088, T101, T111 | Remaining interactive progression/recovery, all branch/fifth-effect and companion behavior checks |
| T073, T115 | Final acceptance reconciliation after the preceding evidence passes |

T116–T143 (M3) and T144–T175 (M4) remain unstarted. Headless/automated graphical results cannot substitute for the missing human/hardware criteria. No new performance capture was made, so the earlier measurements remain the latest performance evidence. No mandatory or optional before/after implementation hooks were configured at either check.
