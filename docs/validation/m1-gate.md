# Milestone 1 delivery and acceptance

> 当前收敛修复（2026-10-16）：见 [Phase 14 实施与验收边界](convergence-2026-10-15.md)。本轮 5,239 条原生断言、源码与实际 Windows EXE 三尺寸受控图形通过；release p95 27.571–29.259 ms，未达预算。人工/参考机/显示延迟验收仍开放。下文是历史交付证据，不代表当前 gate 已关闭。

Date: 2026-10-14. Game version m1.0. Engine: 4.5.stable.official.876b29033. Catalog digest: 00b232c5b9a9080364ce4b3ba9f128b625fda595729261087a581cccc5b63abe.

**Playable combat demo delivered. Formal M1 acceptance remains open; M2 is blocked.**

Release: builds/windows/m1/AbyssExpedition.exe, **96,919,232 bytes**. SHA-256: `70B1F7A4B7017C704BCB300ABE7EA74DDF038D6BD7394B0029900B56C602DE8D`.

63 implementation tasks are marked [X]. T018/T032/T050/T059/T066 remain open because their complete historical manual checkpoint protocols were not performed; their consolidated automated/graphical evidence exists in the corresponding documents. T069–T073 remain open for reference-hardware/human/full manual acceptance. M2–M4 tasks and modules remain untouched.

## Actual executed final checks

Command from project root: `& './tools/run_validation.ps1' -Graphical -Export`.

| Check | Actual result |
| --- | --- |
| Verified binary --version / --help | 4.5 pin confirmed; help executed |
| Headless editor --import | Exit 0; no errors |
| --check-only --script res://tests/run_tests.gd | Exit 0 |
| tests/validate_content.gd | 30 root Resources / 16 PackedScenes / 55 gameplay scripts; valid |
| unit | 172 assertions, 0 failures, 0 skipped |
| scene_smoke (including UI) | 76 assertions, 0 failures, 0 skipped |
| integration_m1 | 37 assertions, 0 failures, 0 skipped |
| replay | 20 assertions / ten matching pairs, 0 failures, 0 skipped |
| full_run | 9 assertions / three starter victories, 0 failures, 0 skipped |
| Unknown suite / invalid seed | Both correctly rejected with exit 2 |
| Source graphical harness | Three physical window sizes, all starter screens/choices/pause/boss patterns/results, 0 capture failures |
| Windows release export | Exit 0; embedded package; excludes later/dev content |
| Packaged release graphical harness via .console.exe | Same three window sizes and screen coverage; exit 0, no errors |
| Benchmark fixture smoke | Executed headless seed 101, 1s warmup / 2s capture; not performance acceptance |

Total native assertions: **314 passed / 0 failed / 0 skipped**. Native runner captures engine/script errors via the Godot 4.5 Logger API. The PowerShell harness checks stdout/stderr as well, validates expected exits and terminates its own hung child after 60 seconds. Runner's monotonic wall-clock watchdog is 55 seconds. No GUT addon is used; these are the project's native Godot tests.

Final automated full-run results, seed 101, base starter, legal offered upgrades only, one simulation step per actual physics frame with --fixed-fps 60:

| Starter | Outcome | Active ticks | Active duration | Kills / run level | Remaining HP |
| --- | --- | --- | --- | --- | --- |
| Aren | Victory | 33754 | 9:22.57 | 394 / 8 | 13 |
| Lia | Victory | 33206 | 9:13.43 | 421 / 9 | 125 |
| Milo | Victory | 33080 | 9:11.33 | 423 / 9 | 124 |

These are accelerated automated checks, not the required twenty ordinary human victories. Boss HP reaches zero through actual automatic attacks; no health/XP/damage/time injections are used in full_run. Earlier failed bot/balance iterations were fixed and superseded; their results are not presented as final passing evidence. The final explicit lexicographic upgrade ordering was audited and all suites were rerun afterward.

## Requirement coverage and remaining acceptance

| Requirements | Delivered behavior / evidence | Limitation |
| --- | --- | --- |
| FR-001–FR-003 | Offline start/selection, normalized WASD/arrows, independent arc/straight/homing attacks; unit/scene/integration/graphical checks | Polished art and animated selection previews are pending |
| FR-004–FR-008 | Five behaviors + broodlings, fixed seeded waves, safe warnings/cap, XP/overflow, twelve upgrades and feedback; unit/integration/full_run | Human balance/fun remains unmeasured |
| FR-009–FR-010 | Warned boss, death precedence, victory/defeat/abandonment, pause, results/retry cleanup; outcome/integration/graphical/full_run | Full manual exported path matrix remains open |
| FR-011–FR-014 | Compact HUD, original procedural placeholders, versioned seeded trace, fixed starters without later systems | Trace comparison is director/choice protocol coverage, not cross-platform physics playback |
| SC-001 / SC-003 / human SC-010 | In-game help, distinct attacks/silhouettes and warning shapes | Ten-player usability/fun/recognition study not conducted |
| SC-002 | Three automated independent victories around 9–10 active minutes | Twenty ordinary victories / 7-7-6 starter split not conducted |
| SC-004 | Automated exercised outcomes/cleanup/pause/retry pass | Complete manual release-play matrix not conducted |
| SC-010 performance / SC-011 | Stress fixture, three window sizes, seeded trace tests and available local smoke | Reference-machine sustained performance and displayed latency not measured |

See development.md for the service-based actor composition, procedural art conventions, tunable numeric hypotheses and red-first/checkpoint workflow deviations. All shipping/runtime blocking errors observed during available checks were fixed. Remaining acceptance gaps require human playtests or the specified hardware/protocol; no M2 authorization is inferred from this demo delivery.
