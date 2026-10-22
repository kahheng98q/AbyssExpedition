# Abyss Expedition — Milestone 4 — Abyss and Aetheran Coast

> Current work: [004 Run Level Promotion](specs/004-run-level-promotion/spec.md). Every expedition starts BASE / RUN Lv1; at RUN Lv15 each living member chooses a run-only branch. No permanent levels, XP, saved branches or promotion materials. 17 native suites (10,152 assertions across incremental runs), source/export graphics and actual release denial passed. Native-focus long checks and human/natural-Lv15 acceptance remain open. [Current evidence](docs/validation/run-level-promotion/results.md).

Offline Godot 4.5 survivor-style combat prototype with a guild hub, six collectible heroes, Sera's story rescue, earned-ticket recruitment, duplicate-token exchange and permanent collection progress. Six promotion branches and up to two AI companions remain available. Corruption brings XP rewards and tougher future waves; seeded contracts and three event types shape each coastal expedition. Original procedural placeholders; fully offline.


## Documentation / 开发文档

- 当前004：[规格](specs/004-run-level-promotion/spec.md) · [计划](specs/004-run-level-promotion/plan.md) · [任务](specs/004-run-level-promotion/tasks.md) · [验证](docs/validation/run-level-promotion/results.md)。

- [Visual Development Dashboard / 离线开发图鉴](docs/game-development-dashboard.html) — screenshots, characters, promotion trees and verified status; open locally in a browser.
- [Implementation Overview / 中文实现概览](docs/IMPLEMENTATION_OVERVIEW.md) — playable scope, limits and quick launch.
- Spec Kit: [Spec](specs/001-abyss-expedition-mvp/spec.md) · [Plan](specs/001-abyss-expedition-mvp/plan.md) · [Tasks](specs/001-abyss-expedition-mvp/tasks.md) · [Constitution](.specify/memory/constitution.md).
- 历史002实施： [002 计划](specs/002-combat-pacing-audio/plan.md) · [任务清单](specs/002-combat-pacing-audio/tasks.md) · [验证指南](specs/002-combat-pacing-audio/quickstart.md) · [2026-10-20 Phase 7实施](docs/validation/combat-pacing-audio/phase7-20261020/results.md) — 完整快照/终结计数/性能守卫已修复并通过窄测；完整M4/图形/新Debug及Release通过，人工验收开放。
- Evidence: [Convergence fixes / 收敛修复与当前验收](docs/validation/convergence-2026-10-15.md) · [Previous full verification / 此前完整验证](docs/validation/verification-2026-10-15.md) · [M4 gate](docs/validation/m4-gate.md) · [Documentation audit](docs/validation/documentation-dashboard.md).
- Debug: [DEV / F9 使用与人工烟测](docs/developer-debug-panel.md) · [2026-10-18 保护性修复与回归](docs/validation/debug-protected-20261018.md).
- 收敛实施：[Phase 7当前结果](docs/validation/sword-promotion-identity/convergence-20261021-v1/results.md) — T055／T056／T062及原T047完成；文档10测试、流程12测试、工具54检查与投影26检查通过。性能预算失败后停止后续实现，保留原始失败。
- 历史003剑系切片：[003计划](specs/003-sword-promotion-identity/plan.md) · [62项任务](specs/003-sword-promotion-identity/tasks.md) · [验证指南](specs/003-sword-promotion-identity/quickstart.md) · [Phase 7证据](docs/validation/sword-promotion-identity/convergence-20261021-v1/results.md) · [验收矩阵](docs/validation/sword-promotion-identity/acceptance.md)。三轮廓、实际恢复与静音转职演示已实现；三组各60样本零差异，新Debug／Release完整图形与九组合真实时钟通过。候选性能样本有效但p95 16.732ms超目标；四类真人验收开放。

**历史003源码验证**：003剑系三身份、实际恢复提示及独立转职演示已实现。完整M4图形导出退出0、16组9,917原生断言通过，新Debug／Release实际图形与九组合真实十轮通过，Release禁调试41项通过。性能有效但p95=16.732ms超16.67目标，T049／T057未完成；自然九局、五人理解、同组灰度／密集辨识与物理DEV仍待真人。旧4551与全部失败保留。[当前收敛结果](docs/validation/sword-promotion-identity/convergence-20261021-v1/results.md)。源码用`Play Debug.cmd`；本轮可运行Release及Debug位于`builds/windows/sword-promotion-identity/convergence-release-20261021-v1/`。

## Play the Windows demo

1. For current004, double-click `Play Debug.cmd` for pinned current source, or run `builds/windows/run-level-promotion/final-v9/AbyssExpedition-debug.exe` (DEV/F9) or `AbyssExpedition.exe` in the same folder (Release). Both exports passed actual launch and core graphical checks; Release rejects debug actions. Native real-clock focus checks and human/performance acceptance remain open. Older milestone builds are historical. Embedded exports need no separate PCK or Godot installation.
2. In the guild, choose **Expedition**, then Aren (melee arc), Lia (straight arrows), or Milo (homing stars). All three starting classes are owned permanently without drawing. Recruited heroes become additional next-run selections.
3. Use the displayed random seed or enter a decimal seed from **0 to 2147483647**, then choose **Start Expedition**. Clearing the field generates a new seed on the first press; press Start again to use it.
4. Move with **WASD or arrow keys**. Attacks fire automatically toward nearby enemies. Collect the cyan diamond gems.
5. At level-up, choose one of three upgrades by clicking, pressing **1/2/3**, or using arrows and **Enter**. The world stays frozen until you choose.
6. Losing window focus pauses the run; regaining focus releases only its own pause reason. **Escape** pauses; Resume continues. Abandon requires a second confirmation. Escape cannot skip an upgrade.
7. The Tidebound Hierophant enters at **9:00 active time**. Avoid orange cone/circle warnings. Defeat it to win; there is no automatic victory at 10:00. Death ends the run.
8. Results save tickets, recruitment and chapter progress before offering **Retry**, **New Expedition**, or selection. Every new run resets level, upgrades, health and class choices; changed Sera ownership can affect seeded event conditions.

The current M4 executable exports and launches successfully; M2/M3/M4 controlled graphical flows and release debug restrictions pass. Human acceptance, reference-machine performance and displayed latency remain open; see [current evidence](docs/validation/convergence-2026-10-15.md).

Open **Roster / party / previews** before starting. Confirm one active hero and up to two owned companions. Every expedition starts at **BASE / RUN Lv1**. Shared run XP, upgrade cards and class branches reset on exit; there are no permanent levels, XP bonuses or promotion materials.

While Sera is unowned, at **4:00** accept Sera's paused rescue offer and remain inside the marked circle for **30 active seconds**. Leaving once or dying fails that opportunity; try again next expedition. A completed rescue recruits Sera on victory or defeat settlement. Once Sera is owned, each 2/4/6-minute event independently chooses Merchant, Altar or Rescue. Each successful owned rescue earns one additional settled ticket. Sera's Guiding Light heals the lowest-health living party member every 20 active seconds.

Settlements award **1 ticket at five minutes**, plus **2 for victory**. In **Recruit / exchange / history**, inspect **Brann 50% / Nyra 50%** and confirm a single pull for **1 ticket** or ten independent pulls for **10 tickets**. Each duplicate gives **1 token**; exchange **5 tokens** for either unowned pool hero. Brann's Bastion halves the first eligible hit in each 20-second interval; Nyra's Far Sight adds 20% starting reach. All three recruits can use their existing class promotion branches. Results save before reveal; interrupted reveals reopen with the original ordered results. Acknowledging them also saves. Excess tokens remain visible after full collection.

At **RUN Lv15**, combat pauses to offer each living member two branches: Swordmaster/Abyss Swordsman, Sharpshooter/Star Hunter, Elemental Sage/Void Caster. The existing attack previews remain. Confirm applies immediately for this run, retaining passive/upgrades and HP ratio. **Later** defers; use the visible **Promotion** HUD button to reopen. Followers retain half outgoing damage, full defense/healing and downing rules.

The local profile lives in the Godot user-data folder **Abyss Expedition/profiles/default/**. Legacy schema 1–3 profiles migrate atomically to schema 4: obsolete levels, XP, branches and materials are removed; roster, tickets, tokens, recruitment history/RNG, chapter flags, seed, selection and prior receipt evidence are preserved. Migration sources are retained. Saves retain current/prior validated generations. A failed save blocks further play/spending and offers Retry for the same pending result. Corrupt saves require explicit recovery; unsupported versions are preserved. If a crash leaves a writer lock, close all other instances before confirming stale-lock recovery.

For a first run, Lia provides a forgiving ranged introduction. Keep moving, pick up gems, and combine offensive upgrades with Ironhide, Vitality or Battle Mend.

## Play from source

The GitHub repository contains source, specifications, tests, validation evidence and real screenshots. Engine binaries, export templates, built executables, caches and runtime profiles are excluded. For a fresh clone, supply the pinned Godot 4.5 editor/console and matching Windows export templates at the local paths in `export_presets.cfg` and the validation scripts before rebuilding. Existing local build paths below refer to generated artifacts.

Open `project.godot` with the included `tools/godot-4.5/Godot_v4.5-stable_win64.exe` and press **F5**, or run from PowerShell at the project root:

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64.exe' --path .
```

Engine pin: `4.5.stable.official.876b29033`. The independently installed 4.7.2 binary is not used for validation.

Q1 comparison captures and the separately retained build can be reproduced with `./tools/validate_quality.ps1` (diagnostic Dummy audio). See [Q1 specification](specs/001-abyss-expedition-mvp/quality-pass-20261018.md).

## Validate and rebuild

```powershell
$validationId = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')
& './tools/run_validation.ps1' -M4 -Graphical -Export -BuildDirectory "builds/windows/run-level-promotion/$validationId" -EvidenceDirectory "docs/validation/run-level-promotion/$validationId"
& './tools/run_debug_validation.ps1' -SkipRegression -BuildDirectory "builds/windows/run-level-promotion/$validationId-debug" -EvidenceDirectory "docs/validation/run-level-promotion/$validationId-debug"
& './tools/run_m4_release_regressions.ps1'
& './tools/check_m2_lock.ps1'
& './tools/run_m4_benchmarks.ps1'
```

Validation runs import, parsing, content/scene checks, M1/M2 regressions, recruitment and M3/M4 integration, invalid-input rejection, three-size source graphical checks and M4 release export/graphical checks. Recruitment tests include 200,000 draws and 8,192 ten-pull batches with fixed seeds and preselected statistical thresholds, reward matrices, ordered duplicates, unlocks and persistence failures. Logs are in `docs/validation/`. Tests inject unique profile roots under `user://tests/`; process-local APPDATA is isolated in `tools/runtime-appdata`. The lock harness checks separate Windows processes and crash recovery. The separate debug script exports/probes the developer panel; release regressions test earlier flows in the current M4 executable. Use `-DummyAudio` on validation/release regressions only to isolate host audio-device failures. Benchmarks use the M4 maximum-corruption workload and diagnostic Dummy audio; `-Release` profiles the actual generated executable with PID-matched OS memory. A valid capture does not mean frame budgets pass. Set `ABYSS_GODOT_EXE` only to another verified 4.5 console executable.

Definitions live in `data/`, scenes in `scenes/`, and systems in `scripts/`. The historical `tools/create_m1_content.ps1` overwrites starter data; do not rerun it over current content. `docs/development.md` and `docs/validation/m4-gate.md` separate implemented features, executed checks and open human/hardware acceptance.

## Developer playtesting

Double-click **Play Debug.cmd** to run current source with pinned Godot 4.5, or F5 in that editor. Click the persistent corner **DEV** button or press **F9** in menus, guild, selection, battle, pause or results. Restart retains the same panel. The normal Q1 release executable intentionally has no developer controls. Four existing tabs preserve levels/XP, promotion and temporary branch previews, safe enemy/boss spawning, companions, invincibility/god mode, 1x/2x/4x speed and isolated test saves. Opening pauses combat; closing preserves existing pause reasons. System > Discard session / normal menu restores the normal profile.

`tools/run_validation.ps1` always includes `debug_panel`; `-Graphical` covers DEV/F9/transitions and `-Export` includes actual-release denial plus debug export. Use `tools/run_debug_validation.ps1` for dedicated export probes. Release F9 and all debug actions are disabled. [Controls and manual checks](docs/developer-debug-panel.md) · [current results and failure history](docs/validation/debug-protected-20261018.md).


## Abyss choices

Press **C** in combat for the exact corruption thresholds. Corruption starts at zero and rises by five each active minute. At 25/50/75/100, new gems give +10/20/30/40% XP. Risks accumulate: more enemies, more Broodmothers, stronger corrupted variants, and a second warned boss eruption at 100. Existing enemies and stored gems keep their values.

At **2/4/6 minutes**, paused events offer choices. Spend temporary coins at the Merchant for healing or Might. The Altar offers **Blood Tithe** (20% max HP and +25 corruption for +30% damage) or **Unbound Assault** (+35 corruption for +40% attack frequency). Bonuses apply to the living party for this expedition. Full costs and disabled reasons are shown; leave/decline is free. Completing Chapter 1 saves a flag; repeat expeditions remain available and require defeating the boss again.

Current schema v4 migrates legacy v1–v3 profiles, removing only obsolete permanent growth/material fields while preserving collection economy, history, chapters, selection and receipt evidence. All corruption, coins, contracts and event state reset between runs. Maximum-corruption profiling: `tools/run_m4_benchmarks.ps1` (three 30-second warm-up / 120-second captures).
