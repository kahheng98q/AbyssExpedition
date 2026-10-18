# Abyss Expedition — Milestone 4 — Abyss and Aetheran Coast

Offline Godot 4.5 survivor-style combat prototype with a guild hub, six collectible heroes, Sera's story rescue, earned-ticket recruitment, duplicate-token exchange and persistent progression. Six promotion branches and up to two AI companions remain available. Corruption brings XP rewards and tougher future waves; seeded contracts and three event types shape each coastal expedition. Original procedural placeholders; fully offline.


## Documentation / 开发文档

- [Visual Development Dashboard / 离线开发图鉴](docs/game-development-dashboard.html) — screenshots, characters, promotion trees and verified status; open locally in a browser.
- [Implementation Overview / 中文实现概览](docs/IMPLEMENTATION_OVERVIEW.md) — playable scope, limits and quick launch.
- Spec Kit: [Spec](specs/001-abyss-expedition-mvp/spec.md) · [Plan](specs/001-abyss-expedition-mvp/plan.md) · [Tasks](specs/001-abyss-expedition-mvp/tasks.md) · [Constitution](.specify/memory/constitution.md).
- Evidence: [Convergence fixes / 收敛修复与当前验收](docs/validation/convergence-2026-10-15.md) · [Previous full verification / 此前完整验证](docs/validation/verification-2026-10-15.md) · [M4 gate](docs/validation/m4-gate.md) · [Documentation audit](docs/validation/documentation-dashboard.md).

**Current build / 当前构建**：2026-10-18 Q1战斗品质迭代：新扫斩、命中/击杀反馈、角色/首领、海岸遗迹与分区HUD。14组5,249原生断言、源码及新EXE三尺寸受控图形通过；体验和性能验收仍开放。详见 [实机前后与验证](docs/validation/quality-20261018.md)。

## Play the Windows demo

1. Double-click `builds/windows/quality-20261018/AbyssExpedition.exe`. Previous M4 is retained in `builds/windows/m4/`. The embedded game data requires no separate PCK or Godot installation. Previous M1/M2/M3 builds are retained separately.
2. In the guild, choose **Expedition**, then Aren (melee arc), Lia (straight arrows), or Milo (homing stars). All three starting classes are owned permanently without drawing. Recruited heroes become additional next-run selections.
3. Use the displayed random seed or enter a decimal seed from **0 to 2147483647**, then choose **Start Expedition**. Clearing the field generates a new seed on the first press; press Start again to use it.
4. Move with **WASD or arrow keys**. Attacks fire automatically toward nearby enemies. Collect the cyan diamond gems.
5. At level-up, choose one of three upgrades by clicking, pressing **1/2/3**, or using arrows and **Enter**. The world stays frozen until you choose.
6. **Escape** pauses; Resume continues. Abandon requires a second confirmation. Escape cannot skip an upgrade.
7. The Tidebound Hierophant enters at **9:00 active time**. Avoid orange cone/circle warnings. Defeat it to win; there is no automatic victory at 10:00. Death ends the run.
8. Results save permanent rewards before offering **Retry**, **New Expedition**, or character selection. Run upgrades and health reset; Retry retains earned permanent progress and warns when starting progression or Sera ownership changes replay conditions.

The current M4 executable exports and launches successfully; M2/M3/M4 controlled graphical flows and release debug restrictions pass. Human acceptance, reference-machine performance and displayed latency remain open; see [current evidence](docs/validation/convergence-2026-10-15.md).

Open **Roster / party / promote** before starting. Confirm one active hero and zero to two other owned heroes as companions. Scroll or Tab to reach controls in longer screens. Each participant gains 20 permanent XP per full active minute plus 100 for victory, including downed companions; victory also grants one shared promotion item. Abandonment grants no rewards. Permanent levels need 100 XP each, cap at 30, and add 2% starting HP/damage per level.

While Sera is unowned, at **4:00** accept Sera's paused rescue offer and remain inside the marked circle for **30 active seconds**. Leaving once or dying fails that opportunity; try again next expedition. A completed rescue recruits Sera on victory or defeat settlement. Once Sera is owned, each 2/4/6-minute event independently chooses Merchant, Altar or Rescue. Each successful owned rescue earns one additional settled ticket. Sera's Guiding Light heals the lowest-health living party member every 20 active seconds.

Settlements award **1 ticket at five minutes**, plus **2 for victory**. In **Recruit / exchange / history**, inspect **Brann 50% / Nyra 50%** and confirm a single pull for **1 ticket** or ten independent pulls for **10 tickets**. Each duplicate gives **1 token**; exchange **5 tokens** for either unowned pool hero. Brann's Bastion halves the first eligible hit in each 20-second interval; Nyra's Far Sight adds 20% starting reach. All three recruits can use their existing class promotion branches. Results save before reveal; interrupted reveals reopen with the original ordered results. Acknowledging them also saves. Excess tokens remain visible after full collection.

At permanent level 15, spend one item to choose either branch permanently: Swordmaster/Abyss Swordsman, Sharpshooter/Star Hunter, Elemental Sage/Void Caster. Preview each attack and fifth-activation effect before confirming. Aren retains Resolute, Lia Fleet Step and Milo Arcane Pulse after promotion. Followers attack from formation at half outgoing damage with full defense/healing, become downed on death, and recover full health next run.

The local profile lives in the Godot user-data folder **Abyss Expedition/profiles/default/**. M2 profiles migrate to schema v2 without granting recruitment balances or new heroes; migration sources are retained. Saves retain current/prior validated generations. A failed save blocks further play/spending and offers Retry for the same pending result. Corrupt saves require explicit recovery; unsupported versions are preserved. If a crash leaves a writer lock, close all other instances before confirming stale-lock recovery.

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
& './tools/run_validation.ps1' -M4 -Graphical -Export
& './tools/run_debug_validation.ps1' -SkipRegression
& './tools/run_m4_release_regressions.ps1'
& './tools/check_m2_lock.ps1'
& './tools/run_m4_benchmarks.ps1'
```

Validation runs import, parsing, content/scene checks, M1/M2 regressions, recruitment and M3/M4 integration, invalid-input rejection, three-size source graphical checks and M4 release export/graphical checks. Recruitment tests include 200,000 draws and 8,192 ten-pull batches with fixed seeds and preselected statistical thresholds, reward matrices, ordered duplicates, unlocks and persistence failures. Logs are in `docs/validation/`. Tests inject unique profile roots under `user://tests/`; process-local APPDATA is isolated in `tools/runtime-appdata`. The lock harness checks separate Windows processes and crash recovery. The separate debug script exports/probes the developer panel; release regressions test earlier flows in the current M4 executable. Use `-DummyAudio` on validation/release regressions only to isolate host audio-device failures. Benchmarks use the M4 maximum-corruption workload and diagnostic Dummy audio; `-Release` profiles the actual generated executable with PID-matched OS memory. A valid capture does not mean frame budgets pass. Set `ABYSS_GODOT_EXE` only to another verified 4.5 console executable.

Definitions live in `data/`, scenes in `scenes/`, and systems in `scripts/`. The historical `tools/create_m1_content.ps1` overwrites starter data; do not rerun it over current content. `docs/development.md` and `docs/validation/m4-gate.md` separate implemented features, executed checks and open human/hardware acceptance.

## Developer playtesting

Run builds/windows/debug-panel/AbyssExpedition-debug.exe or F5 in Godot, enter combat and press F9. Four tabs provide levels/XP, promotion and temporary branch previews, safe enemy/boss spawning, companions, invincibility/god mode, 1x/2x/4x speed and isolated test saves. Opening pauses combat; closing preserves existing pause reasons. The sandbox banner means normal saves and rewards are isolated. System > Discard session / normal menu restores the normal profile.

Use tools/run_debug_validation.ps1 to regress M1/M2, test the panel and build/probe debug and release exports. Release F9 and debug actions are disabled. Full controls, limitations, changed files and manual checks: docs/developer-debug-panel.md. Actual test evidence: docs/validation/debug-panel.md.


## Abyss choices

Press **C** in combat for the exact corruption thresholds. Corruption starts at zero and rises by five each active minute. At 25/50/75/100, new gems give +10/20/30/40% XP. Risks accumulate: more enemies, more Broodmothers, stronger corrupted variants, and a second warned boss eruption at 100. Existing enemies and stored gems keep their values.

At **2/4/6 minutes**, paused events offer choices. Spend temporary coins at the Merchant for healing or Might. The Altar offers **Blood Tithe** (20% max HP and +25 corruption for +30% damage) or **Unbound Assault** (+35 corruption for +40% attack frequency). Bonuses apply to the living party for this expedition. Full costs and disabled reasons are shown; leave/decline is free. Completing Chapter 1 saves a flag; repeat expeditions remain available and require defeating the boss again.

M4 uses schema v3 and preserves existing v1/v2 progression through migration. All corruption, coins, contracts and event state reset between runs. Maximum-corruption profiling: `tools/run_m4_benchmarks.ps1` (three 30-second warm-up / 120-second captures).
