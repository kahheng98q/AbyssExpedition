# Milestone 3 implementation / acceptance report — 2026-10-15

> 当前收敛修复（2026-10-16）：见 [Phase 14 实施与验收边界](convergence-2026-10-15.md)。本轮 5,239 条原生断言、源码与实际 Windows EXE 三尺寸受控图形通过；release p95 27.571–29.259 ms，未达预算。人工/参考机/显示延迟验收仍开放。下文是历史交付证据，不代表当前 gate 已关闭。

M3 implementation is delivered; final acceptance is open. The user explicitly requested only M3 with recruitment/gacha testing and no real-money purchases. Recorded authorization to proceed despite the checklist is retained. Checklists remain read-only: requirements 16 checked/0 unchecked; gameplay 0 checked/40 unchecked. No AGENTS.md or `.specify/extensions.yml` was found; no before/after implementation hooks were registered. No subagents, external services or runtime dependencies were added. The workspace has no Git repository.

T116–T126, T128–T139 and T141 are complete (24 tasks). T127/T140 retain ordinary manual phase checks; T142 retains ordinary release-session and final-binary runtime verification; T143 remains open. Earlier M1/M2 human/performance gates are not retroactively marked passed. M4 is absent and remains gated. The user's explicit M3 activation does not imply acceptance of those earlier criteria.

## Executed validation

Pinned console engine: `4.5.stable.official.876b29033`; Compatibility renderer; matching Windows templates. Content digest `c078e3f49b592eb9e5b47a9fb200ec8188a8876564b09b94fdcfd0e69a0b381b`. Content validation loads 47 root Resources, 25 scenes and 90 shipping scripts. Commands from the workspace root:

```powershell
./tools/run_validation.ps1 -M3 -Graphical -Export
# Additional regression, and a final test-only expansion of passive coverage:
$env:APPDATA = Join-Path (Get-Location) 'tools/runtime-appdata'
& './tools/godot-4.5/Godot_v4.5-stable_win64_console.exe' --headless --fixed-fps 60 --path . --script res://tests/run_tests.gd -- --suite debug_panel
& './tools/godot-4.5/Godot_v4.5-stable_win64_console.exe' --headless --fixed-fps 60 --path . --script res://tests/run_tests.gd -- --suite recruitment
./tools/check_m2_lock.ps1
```

Import, runner parsing, content validation and all native suites pass. Latest per-suite counts:

| Suite | Assertions | Failures | Skips |
| --- | ---: | ---: | ---: |
| unit | 172 | 0 | 0 |
| scene_smoke | 120 | 0 | 0 |
| integration_m1 | 37 | 0 | 0 |
| replay | 20 | 0 | 0 |
| full_run | 9 | 0 | 0 |
| progression | 13 | 0 | 0 |
| persistence | 136 | 0 | 0 |
| abilities | 107 | 0 | 0 |
| integration_m2 | 36 | 0 | 0 |
| recruitment | 293 | 0 | 0 |
| integration_m3 | 196 | 0 | 0 |
| **Main suites total** | **1139** | **0** | **0** |
| Additional debug_panel regression | 69 | 0 | 0 |

The initial full final validation had 291 recruitment assertions; two additional no-revival/paused-Bastion assertions were then added and the affected suite rerun (293 pass). No shipping code changed after the final export. Logs are the suite-named `.log` files; debug coverage is in `m3-debug-regression.log`. Unknown suite and invalid seed probes return expected exit 2. The Windows lock probe refuses a second writer and acquires/releases a test stale lock after explicitly simulated crash recovery.

Statistical results: 200,000 draws yield Brann 99,635 / Nyra 100,365, chi-square 2.664500 (df=1; cutoff 10.828). 8,192 actual ten-pull candidates yield chi-square 9.111558 against Binomial(10,.5), df=10/cutoff 29.588. Both tests use fixed seeds and preselected alpha .001; exact weight intervals and reward conservation are tested separately. [Detailed draw and persistence evidence](m3-draws-exchange.md).

Original seed-101 solo victories still pass: Aren 33754 ticks, Lia 33206, Milo 33080. The automated policy declines the new rescue and preserves the earlier combat baseline. Source M1/M2/M3 graphical harnesses pass at 1280×720, 1920×1080 and 1371×813. Visual checks found and fixed six-hero selection overflow and the rescue zone's drawing order. Long rosters/history/selection scroll with focus following. These are controlled automated graphical checks, not human latency/fun/duration acceptance.

Export succeeds, but **Windows Application Control blocks the final executable's launch with error 4551**. The earlier M3 export passed its release harness; final executable/runtime limits and both hashes are documented in [release evidence](m3-release-playtest.md). The final validation command therefore exits nonzero specifically at release launch, despite all preceding stages passing. Do not claim a fully passing final gate.

## Scope reconciliation

| Requirements | Implementation / evidence |
| --- | --- |
| FR-024–025 | Guild routes, six acquisition entries/balances; exactly three guaranteed starters; locked selection rejection |
| FR-026–027 | Seed-independent minute-four paused rescue, exact zone/continuous timer/failure/pause conditions, earned Sera on victory/defeat |
| FR-028 | Full outcome/time/rescue-ownership reward matrix; same-generation result guard; actual-router settlement/reopen |
| FR-029–030 | Confirm/cancel single/ten earned-ticket draws, exact costs/missing balance, weight-derived visible 50/50 odds; no paid currencies/purchases/pity |
| FR-031–032 | Ordered tentative duplicate conversion; five-token unowned exchange; exact all-outcome ownership matrix and durable exchange failure/Retry |
| FR-033–034 | Atomic candidate, independent persistent 64-bit draw state/index, immutable original receipt/history/reopen, saved acknowledgment, expected revision, repeated-input and failure/interruption tests |
| SC-006–007 | [Collection acceptance evidence](m3-collection-acceptance.md), exact controlled/statistical tests and separately inspected screenshots |
| Prior regressions | All M1/M2 suites, three starter victories, ten-seed replay pairs, graphical promotion/party checks and native Windows locks pass |

## Remaining acceptance

T127/T140 need the specified ordinary interactive manual rescue/recruitment path matrices. T142 needs a host that permits the exported executable and an ordinary offline release playthrough; Windows policy remains unchanged. T143 stays open until required evidence is complete. Prior ordinary victories, ten-player studies and reference-machine performance/latency criteria in the M1/M2 reports remain open. No new reference benchmark or human study was performed. These limitations do not hide known code/test failures: the final-source checks described above pass.
