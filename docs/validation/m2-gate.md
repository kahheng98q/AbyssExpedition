# Milestone 2 implementation and verification — 2026-10-14

> 当前收敛修复（2026-10-16）：见 [Phase 14 实施与验收边界](convergence-2026-10-15.md)。本轮 5,239 条原生断言、源码与实际 Windows EXE 三尺寸受控图形通过；release p95 27.571–29.259 ms，未达预算。人工/参考机/显示延迟验收仍开放。下文是历史交付证据，不代表当前 gate 已关闭。

M2 functionality is implemented. The user explicitly authorized proceeding after the unchecked gameplay checklist/M1 acceptance gate was reported. M3/M4 are untouched. Reviewer-owned checklists remain unchanged. Full human/hardware acceptance remains open.

Reproduce: tools/run_validation.ps1 -M2 -Graphical -Export; tools/check_m2_lock.ps1; tools/run_m2_benchmarks.ps1. Engine: 4.5.stable.official.876b29033. Content digest: 318c0d513ea44edd6741a532de640dfabfc410fc99e31bfbb4ec0832ef1716d4. All 39 root Resources, 21 scenes and 74 registered shipping scripts load and validate.

| Native suite | Assertions | Failures | Skips |
| --- | ---: | ---: | ---: |
| unit (M1 combat/waves/upgrades/outcomes/seeds) | 172 | 0 | 0 |
| scene_smoke (including M2 screens/effects) | 100 | 0 | 0 |
| integration_m1 | 37 | 0 | 0 |
| replay | 20 | 0 | 0 |
| full_run | 9 | 0 | 0 |
| progression | 13 | 0 | 0 |
| persistence | 136 | 0 | 0 |
| abilities (promotion/passives/branches/companions) | 107 | 0 | 0 |
| integration_m2 (party and app) | 36 | 0 | 0 |
| **Total** | **630** | **0** | **0** |

Import, runner parse, content validation, invalid suite/seed rejection, M1 graphical checks and M2 source/export graphical checks pass. Automated seed-101 M1-mode full runs retain victory timings: Aren 33754 ticks, Lia 33206, Milo 33080. M1 snapshots deliberately exercise the historical combat primitives without permanent/passive bonuses; M2 snapshots inject the requested progression/passives. Starting modes, movement, fixed waves, XP/upgrades, boss timing/strength, pause stages and defeat precedence remain unchanged.

| Requirement | Executed evidence |
| --- | --- |
| FR-015 roster | Owned XP/level, base/current profession, passive, items, eligibility and saved 0–2 companion roles; scene/app and source/export graphical checks |
| FR-016 permanent levels | 100 XP, level 1/14/15/30, cap/overflow, 2% HP/damage baselines, independent run upgrades |
| FR-017 rewards | Minute boundaries, victory/defeat/abandonment, downed selected participants, unselected exclusion, one frozen settlement and duplicate result guard |
| FR-018 promotion | Fresh revision, owned/base/level/item checks, cancellation, one atomic branch/item cost, repeated UI submission and failed readback Retry |
| FR-019 six branches | Actual hits, twin arcs/spin, spectral healing, three-victim piercing, distinct ricochet/mark, splash/frost/burst, finite damage/pull zones, per-activation counters and original shape identities |
| FR-020 passives | Resolute after defense/minimum one, Fleet Step speed, Arcane Pulse fifth damage, before/after promotion and counters independent of branch fifth effects |
| FR-021 party AI | Distinct owned 0/1/2 roles, separate formation slots, follow over chase, blocked/separated safe recovery; each targets from own position |
| FR-022 companion combat | Half outgoing damage after modifiers, full healing/defense, separate 45-tick immunity, living-only shared upgrades, downing, active-death defeat, next-run full reset |
| FR-023 durability | Version/checksum/reference validation, current/prior generations, exact pending Retry, before/after-publication interruption, explicit recovery/incompatibility, Windows two-process lock/crash checks |
| SC-005 | All controlled boundaries and twenty complete close/reopen payload comparisons pass |

Detailed evidence: m2-durable-progression.md, m2-promotions.md, m2-companions.md, m2-reopen.md, m2-release-playtest.md and ../benchmarks/m2.md. Scoped process APPDATA plus injected user://tests/ roots isolate tests from the real profile.

Outstanding tasks T088/T101/T111 retain interactive manual portions; T113 retains performance/latency/reference-hardware acceptance; T114 retains a full ordinary manual release session; T115 retains final acceptance reconciliation. Measured p95 was 17.5–17.7 ms on alternate hardware, above target. No human ten-player/ordinary-duration studies or universal power-loss durability claims are made. The original M1 gates remain open. M3 remains blocked pending full acceptance.

Retained M2 release: builds/windows/m2/AbyssExpedition.exe, 96992856 bytes. SHA-256: C762074AD6553EF696257926A8C8CDBA4C2BE80520F7CF56120FA6CA8AF8C2D8. Final close-before-deferred-results regression also passes; a completed run is settled once before exit or pending-loss confirmation.
