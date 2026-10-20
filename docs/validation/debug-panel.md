# Developer Debug Panel validation — 2026-10-14

> 最新保护性修复（2026-10-18）：[DEV/F9、跨界面与常规回归](debug-protected-20261018.md)。源码原生126项、源码及实际Debug图形各118项、实际新Release禁用41项通过；首轮4551失败保留为历史，物理键鼠烟测待人工验收。下文保留历史结果。

> 后续验证：本页为历史交付记录。当前 M4 源码与新调试/发布导出的 69 条原生、三尺寸图形及 20 条发布禁用检查见[本次完整验证](verification-2026-10-15.md)。

Implemented user-requested developer tooling only. Engine: 4.5.stable.official.876b29033 with matching Windows debug/release templates. No milestone-3/4 systems or third-party dependencies. No AGENTS.md was found. The workspace is not a Git repository.

Executed final command:

    & './tools/run_debug_validation.ps1'

The script ran import, runner parsing, content validation, all M1/M2 suites, invalid suite/seed rejection, existing M1/M2 source graphics, developer integration/source graphics, debug/release exports and probes. Every check passed.

| Native suite | Assertions | Failures | Skips |
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
| debug_panel | 68 | 0 | 0 |
| Actual exported release denial probe | 18 | 0 | 0 |
| **Total** | **719** | **0** | **0** |

All 39 root gameplay Resources, 21 registered gameplay scenes and 77 scripts validate. The additional developer PackedScene is explicitly loaded/tested by the developer suite. Gameplay content digest is unchanged: 318c0d513ea44edd6741a532de640dfabfc410fc99e31bfbb4ec0832ef1716d4.

M1-mode seed-101 victories retain identical tick counts: Aren 33754, Lia 33206, Milo 33080. Existing damage/waves/upgrades/outcomes/pause/replay checks pass. M2 profile/promoted ability/party tests pass after shared stat-derivation changes.

## Developer integration

debug-panel.log records 68 assertions. Coverage:

- Hidden default, F9 toggle, always-processing UI with frozen clock, owner-token release and retention of manual/earned-level pauses.
- Deferred upgrade UI cannot steal debug keyboard focus; number keys cannot consume upgrades behind the overlay; closing restores upgrade navigation.
- Selected permanent levels/XP use cap/derived-stat logic, shared run XP remains separate, heal/cooldown semantics and independent invincibility/god-mode toggles.
- Existing promotion screen/service commits sandbox class/materials; runtime alternate-branch preview preserves saved class and passives, updates real attacks and supports companions.
- Two owned distinct companions, no third/unowned addition, temporary roles, full healing, no revival, separate AI movement/attack disable and no actor-ID reuse after removal.
- 1/10/50/100 warned reservations, unconsumed gameplay RNG streams, one chapter boss, damage/death/reward cleanup and hostile projectile removal.
- 1×/2×/4× fixed-step speed settings, no paused tick advancement, same-seed restart and cleanup of engine/health/AI/branch modifiers.
- Safe save/load, failure-blocked resume, immutable Retry, bounded logs and debug boss victory settlement.
- The normal writer's payload AND exact committed bytes remain unchanged after XP, promotions, spawning, party edits, failed Retry and boss rewards. Sandbox end restores normal menu/profile.

## Graphical and release evidence

debug-graphical.log and debug-exported-graphical.log each report failures=0. Source and an actual exported debug template exercised native F9 events, all four tabs, scrolling, the reused promotion UI and promoted party combat at 1280×720, 1920×1080 and 1371×813. Layout assertions check tab/feedback/modal bounds. Captures in screenshots/debug-*.png were visually inspected. Native input tests await window startup and flush events before checking state.

debug-release-denial.log reports 18 assertions, no failures/skips. It executes the actual release template, verifies no developer mount or F9 pause, rejects direct commands and sandbox creation even with forged service state, ignores forged invincibility/god-mode fields, refuses speed setters/restoration, preserves save bytes and frees manually instantiated developer UI before it can enable anything.

Debug and release exports are in builds/windows/debug-panel/. External test scripts are excluded from those packages and are not needed to play.

The original M1 and M2 executables were retained unchanged:

- M1 SHA-256: 70B1F7A4B7017C704BCB300ABE7EA74DDF038D6BD7394B0029900B56C602DE8D
- M2 SHA-256: C762074AD6553EF696257926A8C8CDBA4C2BE80520F7CF56120FA6CA8AF8C2D8

All automated profiles use unique user://tests/ roots with child APPDATA scoped to tools/runtime-appdata. The live user profile was not accessed by the tests.

## Limits

This verifies functional/native/graphical behavior, not a new performance or ordinary human-play acceptance study. Earlier M1/M2 human and reference-hardware gates remain open. Collision visualization uses the standard debug hint. Enemy spawning retains capacity/safety/boss-time boundaries. No revival, permanent class reset, active-control swap, new ownership, recruitment/gacha or corruption was introduced.

Controls, complete file list and manual steps are in ../developer-debug-panel.md.
