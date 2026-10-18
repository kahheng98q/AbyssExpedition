# Milestone 4 implementation and acceptance � 2026-10-15

> 当前收敛修复（2026-10-16）：见 [Phase 14 实施与验收边界](convergence-2026-10-15.md)。本轮 5,239 条原生断言、源码与实际 Windows EXE 三尺寸受控图形通过；release p95 27.571–29.259 ms，未达预算。人工/参考机/显示延迟验收仍开放。下文是历史交付证据，不代表当前 gate 已关闭。

> 后续验证：本页保留原交付证据与构建 hash。当前源码及重新导出的 M4、前序功能、F9 和新压力采样见[本次完整验证](verification-2026-10-15.md)；人工/参考硬件验收仍开放。

M4 implementation is delivered; full acceptance remains open. The user explicitly requested only Milestone 4 and approved proceeding despite unchecked reviewer-owned gameplay checks and earlier unmet gates. requirements.md remains 16 checked/0 unchecked; gameplay.md remains 0 checked/40 unchecked. No AGENTS.md, Git repository, extension hooks, subagents, external services or new runtime dependencies were introduced.

Twenty-six M4 tasks are complete: T144�T152, T154�T167, T169, T171, T173. T153/T168 retain ordinary manual phase acceptance, T170 the ten-player bargain study, T172 the performance/reference/latency gate, T174 an ordinary full offline human session, and T175 the final acceptance gate. Earlier open tasks are preserved. Total roadmap state: 149 complete / 26 open.

## Implementation

Corruption has explicit benefits and risks: +10/20/30/40% new-gem XP across 25/50/75/100, against increased future wave counts, Broodmother share, corrupted-enemy damage and a second warned boss circle. Existing enemies/gems/warnings keep their snapshots. The Altar offers damage for health/corruption or frequency for corruption, with full-cost atomic checks and exact disabled reasons. Merchant spending uses temporary coins; rescue reuses the original objective. All three event kinds use independent seeded slots and frozen one-shot offers, with guaranteed unowned Sera at minute four and the specified owned scheduling change.

Original procedural Aetheran coastal shelves/cult stones and a single-eyed tentacled boss extend the existing field/encounter. Schema v3 adds persistent chapter completion through the once-only victory transaction; migrations retain source generations, all roster/history/RNG data and zero default completion. Temporary effects reset and every replay needs another boss defeat.

## Executed validation

Engine: 4.5.stable.official.876b29033, Compatibility rendering, matching local Windows templates. Commands from the workspace root:

```powershell
./tools/run_validation.ps1 -M4 -Graphical -Export
./tools/check_m2_lock.ps1
./tools/run_m4_benchmarks.ps1
./tools/run_m4_release_regressions.ps1
# Debug native suite:
$env:APPDATA = Join-Path (Get-Location) 'tools/runtime-appdata'
& ./tools/godot-4.5/Godot_v4.5-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd -- --suite debug_panel
```

Import, runner parsing, catalog validation, all native suites, negative CLI arguments and native locks pass. Source M1/M2/M3/M4 graphical checks and the actual M4 release graphical harness pass at 1280x720, 1920x1080 and 1371x813. Screenshots were reviewed; oversized bars overlapping status text were fixed. Exact final counts/hash are recorded below.

All seed-101 starter solo full-run fixtures win with real event decisions: Aren 33348 ticks (9:15.80), Lia 32860 (9:07.67), Milo 32893 (9:08.22). This is accelerated controlled simulation, not an ordinary human duration sample. The earlier no-contract Aren policy lost at tick 32011; using available contracts resolves the regression without changing specified combat balance. Defeat/simultaneous death/abandonment/retry, durable rewards, corruption/event ordering and cleanup remain covered by prior and new suites.

Twenty replay pairs across the ten frozen seeds and both Sera ownership cohorts compare version/start, waves/positions, upgrades, event offers/decisions with differing pause/cosmetic activity. Twenty settlement interruption cases and legacy failure matrices preserve a complete prior or committed state, frozen Retry bytes and once-only rewards. All test profiles are isolated under workspace-local APPDATA user://tests/, never the live player profile.

## Traceability

| Requirements | Evidence |
| --- | --- |
| FR-035�037 | corruption unit/boundary tests, reservation snapshots, crowded caps, stored gems, broodlings, boss committed warnings; m4-corruption.md |
| FR-038�039 | event slot/RNG/cost/health/headroom/party/fresh-input tests and three-size source/release UI; m4-events-chapter.md |
| FR-040�042 | original coast/boss presentation, actual router chapter settlement, v3 migration/reopen and repeat reset; m4-release-playtest.md |
| SC-008 | exact boundary/disabled/decline automation passes; ten-player comprehension remains open in m4-human-playtest.md |
| SC-009 | ten frozen seeds, both ownership cohorts, all types and at least three sequences, guaranteed unowned rescue and durable chapter; m4-event-variety.md |
| SC-011 | twenty repeat pairs include ordered events and Sera ownership; replay suite |
| SC-012 | twenty v3 interruption/reopen cases plus earlier failure/collection suites and actual exported prior flows; m4-integrity.md; ordinary human full session remains open |
| Earlier FR-001�034 | all prior native suites and source/actual-release UI regression harnesses; native Windows locks; three independent starter victories |

## Open acceptance

No ten-person usability/comprehension/fun study or twenty ordinary human victories was performed. Controlled graphical snapshots do not measure displayed input/hit latency. Maximum-corruption stress measurements on this Ryzen 7 5800H/GTX 1650 host miss the target and do not establish the specified reference-machine gate; see docs/benchmarks/m4.md for exact results/limits. No speculative pooling or behavior-changing balance adjustment was used. Full ordinary offline manual acceptance and prior unmet human/hardware criteria remain open.

The M4 release launches successfully on this host; the historical M3 Windows policy block is retained only in its historical evidence. The new release does not overwrite the earlier milestone executables. There are no known remaining import, script, automated assertion or controlled graphical failures in the final checked build.

## Final native results

| Suite | Assertions | Failures | Skips |
| --- | ---: | ---: | ---: |
| unit | 182 | 0 | 0 |
| scene_smoke | 130 | 0 | 0 |
| integration_m1 | 37 | 0 | 0 |
| replay | 40 | 0 | 0 |
| full_run | 9 | 0 | 0 |
| progression | 13 | 0 | 0 |
| persistence | 304 | 0 | 0 |
| abilities | 107 | 0 | 0 |
| integration_m2 | 36 | 0 | 0 |
| recruitment | 293 | 0 | 0 |
| integration_m3 | 196 | 0 | 0 |
| integration_m4 | 307 | 0 | 0 |
| **Main total** | **1654** | **0** | **0** |
| Separate debug_panel regression | 69 | 0 | 0 |

Catalog: 51 root Resources, 27 registered scenes, 98 shipping scripts; digest `97664f9f25b1232d331b80728d5cfdd10f637e261e35a1f4e3a79b538a7ea2c9`. Native totals: 1,654 primary + 69 debug = **1,723 passing assertions**, zero failures/skips. M4 event sequences are printed in m4-integration_m4-final.log. Unknown suite/overflow seed exit 2 as expected. The final source Windows version is Microsoft Windows NT 10.0.26200.0, CPU AMD Ryzen 7 5800H, GPU/driver GTX 1650 / 546.30.

Stress result: seed 101 p95/p99 25.606/28.257 ms; seed 202 25.816/28.183 ms; seed 303 25.277/27.832 ms. Every capture retained exactly 100 normals, one boss and 500 gems; effects 30�31, projectiles 100�109. Source uncapped workload exceeds the frame budgets, so performance is explicitly unaccepted.


Additional release regression: the same M4 executable passed earlier M2 promotion/branch/companion/downing paths and M3 rescue/draw/exchange/history/reveal/reopen paths at all three window sizes. The real release denies all debug entry points (20 assertions), while source developer UI passes its graphical regression (97 assertions). Together with the native suites, this is **1,840 counted passing assertions**, plus the source/release graphical checks that track failures without counting assertions. The final summary Escape test exercises both the early input guard and armed close; consuming input before synchronous detachment prevents a null viewport access. No shipping source changed after the final export.

Final retained Windows executable: `builds/windows/m4/AbyssExpedition.exe`, 97,101,752 bytes, SHA-256 `874471DAFE4164A6EA2706E79AE3B105C7C7BD4CBD3D8A48112050F15AA10E70`. Final source and actual-release Escape regressions both pass.

## 后续Q1品质迭代 — 2026-10-18

新表现和HUD已实现并经过14组5,249原生断言、三尺寸源码/实际新EXE受控图形验证。新构建独立保存在builds/windows/quality-20261018/，本页旧构建与性能证据保持保留。见[Q1前后、性能比较与体验假设](quality-20261018.md)。M4的人工体验/参考机/显示延迟gate仍未关闭。

Q1最终实际release的seed101密集样本p95=13.768ms/p99=14.345ms，30秒预热＋120主动秒且工作负载有效，该样本达标。其余seed/参考机/延迟/人工验收仍开放；详见Q1报告，不能用这一样本抹去本页历史结果。
