# Tasks: Abyss Expedition — Four MVP Milestones

**Generated**: 2026-10-14. **Status (2026-10-15)**: M1/M2 implementations and original exports retained. Explicitly requested M3 implementation delivered: 24 M3 tasks complete; T127/T140/T142/T143 remain open for manual/final-runtime acceptance. M4 was explicitly activated and implemented; its human/manual/performance acceptance tasks remain open.

**Current implementation verification (2026-10-15)**: corrected the project engine feature declaration to pinned 4.5; baseline and post-fix full validation pass. Post-fix 13 native suites / 1,723 assertions, source and current-release three-size graphical regressions, F9 isolation/release denial, Windows locks and headless startup pass. See [commands, pressure captures and unexecuted checks](../../docs/validation/verification-2026-10-15.md). Human/reference-machine/latency acceptance remains open; no task checkbox was changed by this pass.

**M3 validation 2026-10-15**: 1139 main native assertions plus 69 debug regression assertions pass; source graphical checks and Windows lock checks pass. Final export succeeds but Windows Application Control blocks its launch (4551); prior M3 export passed graphical checks. M3 was explicitly activated by the user while earlier human/hardware gates remain open. M4 task status is summarized below; earlier open acceptance markers are preserved. See [M3 evidence and remaining acceptance](../../docs/validation/m3-gate.md).

**Input**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [data-model.md](data-model.md), [systems contract](contracts/systems.md), [persistence contract](contracts/persistence.md), [UI contract](contracts/ui.md), [quickstart.md](quickstart.md), and [constitution 1.0.0](../../.specify/memory/constitution.md).

**Organization**: Four milestone groups contain setup/foundation, dependency-ordered story phases, and acceptance/export tasks. US1 spans combat setup and complete-loop integration because its ending depends on US2's build choices. US3 verifies the integrated M1 loop. Shared mechanics belong to their first consumer; later stories reuse them. Later milestones are a gated roadmap, not simultaneous implementation authorization. Do not begin implementation during task generation.

## Format and execution rules

- Each checklist line is `- [ ] Tnnn [P?] [USn?] Action with exact project-relative file path`. Paths resolve from the workspace root; `user://` paths resolve through Godot, not the installation directory.
- `[P]` identifies work in separate files that can share the phase's stated prerequisite. It does not waive prerequisites or authorize parallel agents. Unmarked tasks run in listed order. Explicit task dependencies override order; prerequisites for each parallel batch are listed below.
- Story labels map directly to the nine specification stories. Setup, foundation and cross-cutting gates have no story label. Tests are required by the user and constitution, including contract, logic, scene and integration checks.
- Write each phase's behavioral tests before implementing its behavior; use parse-valid fixtures/minimal interfaces and confirm the relevant assertions fail for the missing behavior. Register each added fixture/test in the appropriate runner suite when it becomes active. Missing tooling or a parse error is not a meaningful behavioral failure. Run and pass the tests at the checkpoint.
- Definition tasks cover all fields in their named data-model row. Quoted validation constraints below are verbatim from the data model. Use fixed specification values; record and tune only its explicitly unspecified initial hypotheses without removing required distinctions.
- Each checkpoint task invokes the validation procedure below and updates `docs/development.md` and its named evidence file. Do not pass a gate with an import, parse, runtime, test, export or acceptance failure. Missing graphical/human/hardware/tooling evidence leaves the gate open; record the limitation.
- Never build M2–M4 stubs or load their content in M1. Introduce Resources, scene registrations, test suites and migrations only at their owning milestone. No network, premium currency, backend, additional roster or expedition-resume scope.

### Standard Godot validation procedure (V)

Use the verified console binary in `ABYSS_GODOT_EXE`, pinned to `4.5.stable.official.876b29033` with matching templates. Execute the commands in `quickstart.md` separately and check each exit/log: headless import; `--check-only --script res://tests/run_tests.gd`; `tests/validate_content.gd`; runner `--suite scene_smoke`; applicable unit/integration/replay/persistence suites. Load every registered script/Resource/PackedScene, including normally uninstantiated content; instantiate active-milestone scenes, advance process/physics frames, verify wiring and cleanup. A watchdog/unknown suite/missing fixture/runtime error fails. Run changed gameplay graphically at 1280×720, 1920×1080 and an irregular window size. Record command/procedure, build/engine/content versions, seed/start, actual pass/fail/skip counts, logs and limitations. Headless checks cannot establish visible latency, readability, fun or run duration.

## Milestone 1 — Playable Combat

**Scope**: US1–US3; FR-001–FR-014; SC-001–SC-004, SC-010–SC-011. No permanent profile or later systems. End build: all three starters can independently win/lose/retry a seeded expedition with waves, upgrades, HUD and warned boss.

### Phase 1 — Setup (M1.0)

**Prerequisite**: design documents only. **Check**: verified engine, reproducible configuration and documented art conventions.

- [X] T001 Verify the console executable/version/help and matching Windows export templates; record `ABYSS_GODOT_EXE`, tooling limitations and the 4.5 pin in `docs/development.md` before changing project configuration.
- [X] T002 Reconcile `project.godot` with Godot 4.5, Compatibility rendering, 60-Hz physics, WASD/arrows and menu actions, 640×360 integer viewport/keep-aspect/nearest sampling and a 1280×720 default window; remove incompatible Forward Plus/D3D12 settings.
- [X] T003 [P] Document 16×16 tiles, 32×32 heroes/enemies, 64×64 boss, 16-pixel hero footprint, animation timing/priorities and presentation-only pixel snapping in `docs/art-direction.md` before reusable art creation.
- [X] T004 [P] Establish creator/source/license/placeholder/replacement entries in `assets/provenance.md` for each original placeholder introduced later; prohibit copied franchise assets.
- [X] T005 Run the available configuration import/version checks, update `docs/development.md`, and record actual outcomes and the not-yet-playable setup state in `docs/validation/m1-setup.md`.

### Phase 2 — Foundation (M1.0)

**Prerequisite**: T005. **Check**: menu → selection → empty bounded field → menu works; content and scene validation report meaningful failures.

- [X] T006 Implement the native assertion/suite registry and runner in `tests/run_tests.gd`; exit nonzero for assertions, engine errors, unknown arguments/suites/seeds and missing fixtures; implement only active M1 suites and a bounded hang watchdog.
- [X] T007 [P] Define `scripts/data/stat_block.gd` with the StatBlock fields and constraints "Positive health/frequency/ranges, nonnegative defense. Class baselines are immutable; runtime effective stats are derived."
- [X] T008 [P] Define `scripts/characters/character_definition.gd`, `scripts/characters/profession_definition.gd` and `scripts/characters/skill_definition.gd` for M1 only; enforce "A branch must belong to the hero's base class." and "Period/count positive for relevant trigger." without introducing promotions/passives yet.
- [X] T009 [P] Define `scripts/data/weapon_definition.gd`, `scripts/data/effect_definition.gd` and `scripts/data/visual_set.gd`; enforce "Nonzero reach/frequency; projectile lifetime default 180 ticks; mode-specific required fields.", "Refresh durations without unintended stacking." and "No damage callbacks or gameplay cooldowns in visual assets."
- [X] T010 Implement the explicit Resource/PackedScene manifest in `scripts/data/content_catalog.gd`; enforce "Stable lowercase `StringName` IDs are unique within type", "Reject NaN/infinity, negative durations, unknown IDs, invalid ranges, duplicate IDs and cycles in profession branches." and "Definitions are read-only after validation."; report content path/ID/reason and resolve only registered effect capabilities.
- [X] T011 Implement `tests/validate_content.gd` and `tests/scenes/test_scene_smoke.gd` to load all active scripts/Resources/scenes, instantiate/frame-step/free them and verify required nodes/signals/no leftover run objects; test invalid catalog fixtures without directory-enumeration dependence.
- [X] T012 Implement `scripts/core/seed_streams.gd` and `scripts/core/run_start_snapshot.gd` with "seed 0..2147483647" and "Immutable for the expedition."; derive `wave_types`, `spawn_positions`, `upgrade_offers` using SHA-256 of `abyss-rng-v1|<decimal seed>|<label>`, first 8 bytes big-endian/sign-bit masked; keep cosmetics separate.
- [X] T013 Create `data/characters/aren.tres`, `data/characters/lia.tres`, `data/characters/milo.tres`, their three base definitions in `data/professions/` and arc/straight/homing definitions in `data/weapons/`; enforce "M1 Aren/Lia/Milo; passives mandatory M2. M3 adds Sera/Brann/Nyra, exactly six." in milestone-specific catalog checks; no mandatory passives or ownership service in M1; register content after schemas validate.
- [X] T014 Create `scenes/app/app.tscn` with ContentCatalog/ScreenHost/ExpeditionHost/ModalHost and `scripts/core/app_router.gd`; assign it as main scene in `project.godot`, own one expedition and disconnect/free it on exit.
- [X] T015 Create `scenes/world/expedition.tscn` with run composition and pausable world/actors/projectiles/pickups/telegraphs/effects hosts; create `scenes/world/coast_field.tscn` with a bounded 960×540 walkable field, collisions and camera limits; verify packed-subscene ownership.
- [X] T016 Create `scenes/ui/main_menu.tscn`, `scenes/ui/character_selection.tscn` and `scripts/ui/character_selection.gd`; show three starter attack previews, seed/limits/controls, keyboard focus and fresh-edge confirmation; reject invalid seed and generate/display one seed for blank input.
- [X] T017 Implement active-tick and owner-token pause primitives in `scripts/core/run_clock.gd` and `scripts/core/pause_coordinator.gd`; active time never catches up paused wall time, foreign-token release fails, and only routing/modal UI processes while paused.
- [ ] T018 Apply V to foundation, manually check focus/scaling/selection/field entry/exit for seeds 0 and 2147483647, update `docs/development.md`, and record the runnable scene checkpoint in `docs/validation/m1-foundation.md`.

### Phase 3 — US1: Movement, automatic combat and waves (M1.1–M1.2)

**Goal**: Control any starter, fight all five behaviors and collect XP. **Independent test**: from fixed starter selection run a controlled field encounter without M2–M4; US1's complete-ending acceptance also requires Phase 5. **Prerequisite**: T018. Movement/combat closes at T032. US1's waves and US2's choices form the single M1.2 implementation phase, with their joint validation checkpoint at T050.

- [X] T019 [P] [US1] Author movement/targeting/damage/attack fixtures in `tests/unit/test_combat.gd` covering opposing/diagonal/release/bounds, distance/spawn-order ties, no-target counters, distinct arc victims, straight direction, homing reacquisition/expiry, minimum damage, 45-tick immunity and stale/duplicate hits.
- [X] T020 [P] [US1] Author wave/spawn/broodling fixtures in `tests/unit/test_waves.gd` asserting exact schedule/weights/introductions, safe-candidate retries, cap with reservations, no backlog, child cap/cancellation and tick-32400 spawn stop before implementation.
- [X] T021 [US1] Create `scenes/actors/hero.tscn` and `scripts/characters/character_factory.gd` with CharacterBody2D/body/hurtbox/health/stats/controller/attack/presentation; isolate ActorState health/counters from shared definitions and use stable actor IDs.
- [X] T022 [US1] Implement normalized WASD/arrows, immediate release and field collision in `scripts/combat/player_controller.gd`; keep movement usable during attacks and equal-speed diagonals/opposing-input cancellation.
- [X] T023 [US1] Implement living/damageable actor registration and nearest-center targeting in `scripts/combat/targeting_service.gd`; tie by earliest spawn sequence, remove dead actors immediately and give bosses no priority.
- [X] T024 [US1] Implement queued deterministic hit resolution in `scripts/combat/damage_service.gd`; accept each request once, reject old run generations/dead/invulnerable targets, apply `max(1, (outgoing_damage - flat_defense) × defensive_multipliers)`, clamp health and emit one death.
- [X] T025 [US1] Implement 45-active-tick hero immunity and decaying knockback with resistant feedback in `scripts/combat/actor_health.gd`; ignored hits never extend immunity, healing cannot revive, and damage uses simulation rather than animation callbacks.
- [X] T026 [US1] Implement ready-target activation/snapshots/cooldowns in `scripts/combat/attack_executor.gd`; no target preserves readiness/counters, no attack backlog, `ceil(60/frequency)` minimum one tick; create attacks under Expedition with source snapshots.
- [X] T027 [US1] Create `scenes/combat/melee_arc.tscn` and `scripts/combat/melee_arc.gd` for Aren's target-facing short arc; each enemy in geometry is hit once per arc and movement is never animation-locked.
- [X] T028 [US1] Create `scenes/combat/projectile.tscn` and `scripts/combat/projectile.gd` for Lia's fixed-direction arrows and Milo's homing shots; enforce "Expiry is immutable; reacquisition cannot extend it." and expire immediately when no in-range valid homing target exists.
- [X] T029 [US1] Create original actor/attack/hit/immunity/death placeholder visuals under `assets/sprites/placeholders/` and `assets/effects/`; connect presentation in `scripts/combat/actor_presentation.gd` with specified animation priorities and update `assets/provenance.md`.
- [X] T030 [US1] Create `scenes/actors/enemy.tscn`, `scripts/data/enemy_definition.gd` and `data/enemies/saltbound_thrall.tres`; enforce "All non-boss deaths drop base 10 XP." and implement slow pursuit/contact damage in `scripts/combat/enemy_controller.gd`.
- [X] T031 [US1] Implement the ordered simulation stages in `scripts/core/simulation_coordinator.gd` and basic RunState/RunManager in `scripts/core/run_manager.gd`; resolve full same-tick hit batches before outcomes, stop between stages on choice pause, reject invalid paused callbacks and resume a suspended stage without duplicate work.
- [ ] T032 [US1] Apply V with combat tests and graphical checks of all starters, no-target/homing/death/bounds/feedback; update `docs/development.md` and `docs/validation/m1-movement-combat.md` before adding waves.
- [X] T033 [P] [US1] Define `scripts/data/wave_schedule.gd`, `scripts/data/field_definition.gd` and `data/encounters/coast_waves.tres`/`coast_field.tres`; enforce "Weights total 100%; required introductions replace Thrall slots before safety/cap skips." and "Fixed coordinate origin and spawn candidate ordering."; encode waves every 600 ticks from 0 through 31800 with 4/6/8/10/12 counts and specification mixes.
- [X] T034 [P] [US1] Define `data/enemies/skittering_brinejaw.tres`, `data/enemies/lantern_cantor.tres`, `data/enemies/shellbound_husk.tres`, `data/enemies/reef_broodmother.tres` and `data/enemies/broodling.tres`; enforce "Broodmother ≤3 living children; total cap includes children/reservations."; use the specified behaviors and explicit tunable stats/resistances/visuals.
- [X] T035 [US1] Implement warned committed rush/recovery in `scripts/combat/brinejaw_behavior.gd` and warned ranged-distance attacks in `scripts/combat/cantor_behavior.gd`; use active deadlines, distinct silhouettes and registered behavior policies.
- [X] T036 [US1] Implement armored resistance in `scripts/combat/husk_behavior.gd` and warned capped summons in `scripts/combat/broodmother_behavior.gd`; broodlings count toward total capacity and cancel if mother dies/space becomes unsafe/boss boundary arrives.
- [X] T037 [US1] Implement fixed-time composition and safe reservations in `scripts/combat/spawn_director.gd` and `scenes/combat/telegraph.tscn`; try ≤16 seeded edge candidates per slot, ≥96 pixels from every living party member, warn 45 ticks, revalidate safety and enforce active+reserved ≤100; discard skipped slots and record candidate RNG consumption/trace.
- [X] T038 [US1] Create `scenes/pickups/xp_gem.tscn` and `scripts/progression/xp_pickup.gd`; drop exactly one stored-value gem per non-boss death, preserve rewards without expiry and accept only one active-hero collection per pickup.
- [X] T039 [US1] Implement shared run XP/level overflow in `scripts/progression/run_progression.gd`; start at level 1, require `100 × current run level`, queue every earned level and freeze before further simulation; expose XP/level snapshots for later choice/UI integration.
- [X] T040 [US1] Register wave/enemy/pickup/telegraph scenes in `scripts/data/content_catalog.gd` and compose them in `scenes/world/expedition.tscn`; assert all five behaviors appear by forced introductions before capacity/safety skips and no spawn stat depends on hero strength.

### Phase 4 — US2: Distinct hero builds and paused upgrades (M1.2)

**Goal**: Three distinct attacks, twelve useful upgrades and reliable choice pause. **Independent test**: repeat identical enemy layouts with Aren/Lia/Milo, exhaust capped upgrades and collect multi-level XP; no permanent state. **Prerequisite**: T040; tests T019/T020 must be runnable and failures fixed before this phase's exit.

- [X] T041 [P] [US2] Author upgrade/XP/offer fixtures in `tests/unit/test_run_upgrades.gd` for exact catalog effects/caps/compatibility, three unique uniform choices, immutable offers, overflow, fallback trio and one application per confirmed offer.
- [X] T042 [P] [US2] Author paused-stage/modal/input tests in `tests/integration/test_choice_pause.gd`; assert no movement/hits/status/cooldown/immunity/spawn/pickup/clock progress, no update between queued choices and no confirmation leakage/Escape dismissal.
- [X] T043 [US2] Define `scripts/data/upgrade_definition.gd` and twelve named Resources in `data/upgrades/`; enforce "Might/Vitality/Battle Mend always eligible together. Exactly three distinct eligible offers; never ineffective/capped choices." and "`max_stacks` (0 means uncapped)"; copy every stated effect/limit from FR-007.
- [X] T044 [US2] Implement additive percentage/flat modifiers, healing and melee/ranged Echo effects in `scripts/progression/upgrade_effects.gd`; derive previews and simulation from one configuration, preserve Vitality's exact added-health heal and Battle Mend's useful damage bonus at full health.
- [X] T045 [US2] Implement burn/frost status deadlines in `scripts/combat/status_effects.gd`; burn is 30% snapshot damage over three 1-second ticks, refresh without parallel burns or resetting next-tick deadline; frost is 20%/120 ticks on susceptible targets, never recursively trigger attack effects.
- [X] T046 [US2] Implement lexicographically ordered eligibility and three uniform samples without replacement in `scripts/progression/upgrade_offer_service.gd`; reject capped/incompatible choices and enforce "Re-entry cannot resample; confirmed input is consumed once." with stable LevelChoice IDs.
- [X] T047 [US2] Implement level-choice serialization in `scripts/core/choice_coordinator.gd`; acquire/release owner pause tokens, use updated eligibility for each queued level, require a fresh input edge and cancel all choices on terminal result.
- [X] T048 [US2] Create `scenes/ui/level_up.tscn` and `scripts/ui/level_up.gd` with exactly three short accurate effects, keyboard selection and disabled dismissal/reroll; connect choice intents to services without UI-owned upgrade logic.
- [X] T049 [US2] Integrate choice/upgrades/statuses in `scenes/world/expedition.tscn` and register Resources in `scripts/data/content_catalog.gd`; validate one mutation per offer and temporary-state reset on run disposal.
- [ ] T050 [US2] Apply V with combat/wave/XP/upgrade/choice tests; manually play escalating waves, all starters and chained choices with manual pause overlap; update `docs/development.md` and `docs/validation/m1-waves-growth.md` before boss/results work.

### Phase 5 — US1: Complete expedition ending (M1.3)

**Goal**: One warned boss and correct victory/defeat/abandon/retry. **Independent test**: win and lose with a fresh starter, then retry without later modules. **Prerequisite**: T050.

- [X] T051 [P] [US1] Author boss/outcome fixtures in `tests/unit/test_run_outcomes.gd` covering tick 32400, crowded safe entrance retry, two ≥45-tick warnings, no automatic timeout, hero/boss simultaneous death precedence, terminal cancellation and one frozen summary.
- [X] T052 [P] [US1] Author start/finish/pause/abandon/retry/cleanup scene flows in `tests/integration/test_m1_loop.gd`; assert one expedition, no stale callbacks, no leftover health/XP/upgrades and M1 boot with M2–M4 absent (FR-014).
- [X] T053 [US1] Define `scripts/data/boss_definition.gd`, `scripts/data/boss_pattern.gd` and `data/encounters/tidebound_hierophant.tres`; enforce "arrival 32400 ticks, cone/eruption ≥45-tick warnings", "Warning geometry and damage query share identical parameters." and "No retargeting an already warned shape."
- [X] T054 [US1] Create `scenes/actors/boss.tscn` and `scripts/combat/boss_controller.gd` with safe warned entrance, cone/eruption/recovery and visible resistance; retain one pending entrance when crowded, preserve existing enemies and block normal/broodling creation from 9:00.
- [X] T055 [US1] Complete `scripts/core/run_manager.gd` and `scripts/core/run_summary.gd`; active-hero death wins same-tick arbitration, live-hero boss death wins expedition, abandonment grants no rewards, summary/time freeze once and invalidate pending choices/spawns.
- [X] T056 [US1] Create `scenes/ui/pause_menu.tscn` and `scripts/ui/pause_menu.gd`; Escape toggles only manual pause, Resume cannot release other tokens, and confirmed abandon/quit ends the current expedition without permanent mutations.
- [X] T057 [US1] Create `scenes/ui/run_results.tscn` and `scripts/ui/run_results.gd`; display outcome/hero/seed/time/level/kills, Retry uses the seed, New Expedition generates a seed and selection returns cleanly; show no permanent rewards in M1.
- [X] T058 [US1] Integrate terminal routing/restart in `scripts/core/app_router.gd`; disconnect/free all run nodes, timers/signals and choice tokens before a new run; expose no later screen or persistence dependency.
- [ ] T059 [US1] Apply V with complete-loop and boss suites, manually exercise both boss warnings and victory/defeat/simultaneous-death/pause/retry paths; update `docs/development.md` and `docs/validation/m1-complete-loop.md`.

### Phase 6 — US3: Read danger and replay (M1.3)

**Goal**: Readable HUD/feedback and reproducible random traces. **Independent test**: repeat matching seed/version/starter/tick decisions twice, changing only paused wall duration. **Prerequisite**: T059.

- [X] T060 [P] [US3] Author stream-derivation/seed/offer-position trace tests in `tests/unit/test_seed_streams.gd` and ten-pair replay fixtures in `tests/integration/test_replay.gd`; include all quickstart seeds, pause-duration independence, cosmetics isolation, invalid seeds and same-seed retry/new-seed path.
- [X] T061 [P] [US3] Author HUD snapshot/focus/warning-state tests in `tests/scenes/test_m1_ui.gd`; assert visible HP/XP requirement/level/time/seed match authoritative state and telegraph state precedes damage without claiming human readability.
- [X] T062 [US3] Create `scenes/ui/combat_hud.tscn` and `scripts/ui/combat_hud.gd`; render health/XP/run level/active time from signals/snapshots with high-contrast compact labels and no future currency/corruption widgets.
- [X] T063 [US3] Implement versioned start/decision/random trace recording in `scripts/core/replay_trace.gd`; capture engine/game/catalog digest, stream derivation, wave types/positions/attempts/skips and ordered offer IDs; ensure cosmetic RNG never consumes gameplay streams.
- [X] T064 [US3] Integrate replay metadata and clear matching-condition explanation in `scripts/ui/character_selection.gd` and `scripts/ui/run_results.gd`; display seed before start/on result and never promise equality after changed version/decisions.
- [X] T065 [US3] Audit/tune shape-based warning, attack direction, impact, 45-tick immunity and death feedback in `scripts/combat/actor_presentation.gd` and `scenes/combat/telegraph.tscn`; verify dense background contrast/pixel sampling against `docs/art-direction.md` and update provenance.
- [ ] T066 [US3] Apply V including ten replay pairs and HUD suites, manually check three window sizes/focus/pixel jitter/HUD/warning avoidance; update `docs/development.md` and `docs/validation/m1-readability-replay.md`.

### Milestone 1 acceptance and runnable build (M1.4)

**Prerequisite**: T066. No M2 implementation until T073 passes.

- [X] T067 Create the Windows Desktop release preset in `export_presets.cfg`, limit shipped manifest to M1 and exclude development fixtures; export `builds/windows/m1/AbyssExpedition.exe` with matching templates and record export commands/errors in `docs/validation/m1-export.md`.
- [X] T068 Create bounded benchmark fixtures in `tests/performance/combat_stress.tscn` and `tests/performance/benchmark_capture.gd` for 100 non-bosses + boss, 30 effects, 100 projectiles and 500 gems; add a long no-pickup reward-preservation check without changing shipping spawn rules.
- [ ] T069 Measure seeds 101/202/303 after 30-second warm-up/120-second active capture on the plan's reference Windows hardware; record raw metrics/environment in `docs/benchmarks/m1.md` and `docs/benchmarks/m1.csv`, targeting 60 FPS, p95 ≤16.67 ms, p99 ≤25 ms and graphical input/hit latency ≤100 ms; profile before any optimization and rerun affected replay/reward tests after fixes.
- [ ] T070 Conduct ten-player first-use/all-starter/fun/dense-danger playtests with only in-game help; record SC-001 (≥9 start in 2 minutes), SC-003 (≥8 distinguish starters, ≥7 each enjoyment/retry rating ≥4/5) and SC-010 (≥8 identify hero/danger in 1 second) in `docs/validation/m1-human-playtest.md`; unavailable participants leave criteria unverified.
- [ ] T071 Conduct twenty ordinary baseline solo victories split 7/7/6 across starters; record seeds/start/active durations in `docs/validation/m1-duration.md`; require every starter wins and ≥16 finish in 9–11 active minutes without accelerated/debug runs.
- [ ] T072 Launch `builds/windows/m1/AbyssExpedition.exe` offline; verify all starter/upgrade/wave/boss/HUD/pause/outcome/retry paths and Resource inclusion at each window size; record manual results and every exercised SC-004 case in `docs/validation/m1-release-playtest.md`.
- [ ] T073 Run final V/unit/integration_m1/replay and reconcile FR-001–FR-014 plus SC-001–SC-004/SC-010–SC-011 against actual evidence in `docs/validation/m1-gate.md`; update `docs/development.md`, retain the runnable M1 export and block M2 until every required criterion passes.

**Build checkpoint**: `builds/windows/m1/AbyssExpedition.exe` starts offline and supports complete combat/retry with only M1 content. This is the first playable MVP scope; later milestones extend an accepted build.

## Milestone 2 — Character Progression

**Scope**: US4–US5; FR-015–FR-023; SC-005 plus affected M1 regressions. **Entry**: T073 passed; recheck these planned tasks against accepted combat before execution. End build: durable starter roster, levels, six promotion branches and zero to two companions.

**Implementation authorization (2026-10-14)**: The user explicitly approved proceeding with M2 despite the unchecked reviewer gameplay checklist and open M1 human/hardware acceptance gates. This authorizes M2 implementation only; it does not mark those gates passed or authorize M3. See docs/validation/m2-gate.md for executed evidence and remaining acceptance work.

### Phase 7 — US4: Durable permanent progression (M2.0)

**Goal**: Permanent XP/items/selection survive reopen and failed saving blocks continuation. **Independent test**: settle victory/defeat/abandon, force save failures and reopen isolated starter profiles with no recruitment/corruption. **Prerequisite**: T073.

- [X] T074 [P] [US4] Author permanent XP/reward/stat fixtures in `tests/unit/test_permanent_progression.gd`; cover 1/14/15/30, overflow, 100 XP/level, 2%/level damage/health, full-minute boundaries, victory bonus/item, defeat/abandon and one participant settlement.
- [X] T075 [P] [US4] Author save-envelope/round-trip/recovery/failure fixtures in `tests/integration/test_persistence_v1.gd` and test-only storage adapter in `tests/fixtures/fault_file_store.gd`; implement the persistence contract's full failure classes/stages with roots under `user://tests/<unique run>/` and reject the live profile path.
- [X] T076 [US4] Define `scripts/persistence/profile_data.gd`, `scripts/progression/owned_hero.gd` and schema-v1 fixtures in `tests/fixtures/profiles/`; enforce "total permanent XP capped at 2900", "derived level `min(30, 1 + floor(total_xp/100))`", "Validate branch ownership, cap and distinct owned party IDs; only initial creation grants all three starters." and "All numeric JSON balances must be integral, nonnegative and within supported integer precision; reject overflow before spending/rewards."
- [X] T077 [US4] Implement envelope/payload validation in `scripts/persistence/profile_validator.gd`; validate required types/IDs/branches/party/XP/revision/checksum/version and bounded input, hash exact UTF-8 payload bytes and load no arbitrary scripts/Godot objects; reject incompatible higher versions.
- [X] T078 [US4] Implement lock-directory ownership in `scripts/persistence/profile_lock.gd`; one native `DirAccess.make_dir` acquisition, second-writer refusal, owned-only normal release and explicit stale-lock recovery after other-instance confirmation, preserving generations.
- [X] T079 [US4] Implement immutable generations/temp write/flush/reopen/verified rename/readback in `scripts/persistence/profile_store.gd` under `user://profiles/default/`; retain current/prior validated generations, preserve corrupt/incompatible/pending evidence and treat cleanup failure separately from commit.
- [X] T080 [US4] Implement serialized revision-checked mutation/same-candidate Retry in `scripts/persistence/save_coordinator.gd`; retain operation ID/candidate bytes/result, inspect already-published destination after failure and acknowledge only validated readback; never recalculate rewards or reapply a committed action.
- [X] T081 [US4] Implement newest-generation load and explicit recovery/new-profile handling in `scripts/persistence/profile_loader.gd`; no silent fallback/reset/temp commit, block newer schema/content, restore chosen valid state through a new higher revision and preserve damaged evidence.
- [X] T082 [US4] Introduce the Abyss Expedition user-data identity in `project.godot` and load-before-play integration in `scripts/core/app_router.gd`; persist exactly three initial starter records and confirmed selection through the writer, display resolved storage path in diagnostics and block start while not ready.
- [X] T083 [US4] Implement permanent leveling/reward previews in `scripts/progression/permanent_progression.gd`; each participant gets `20 × floor(active_ticks/3600) + 100 on victory`, victory gives one shared item, abandon none, XP caps without suppressing other rewards.
- [X] T084 [US4] Derive starting damage/health from profession ×`(1 + 0.02 × (level − 1))` in `scripts/characters/character_factory.gd`; snapshot owned class/level for replay and reset all run state/full health independently of permanent state.
- [X] T085 [US4] Route one frozen run settlement/operation receipt in `scripts/core/run_manager.gd` and `scripts/core/app_router.gd`; results show earned previews, continuation waits for commit and result re-entry cannot resettle the run.
- [X] T086 [US4] Create `scenes/ui/save_error.tscn` and `scripts/ui/save_error.gd`; show same pending action/error/Retry, disable play/spend/continuation, require pending-loss close confirmation and show recovery timestamp/lost-progress/incompatible/stale-lock reasons.
- [X] T087 [US4] Extend results/selection adapters in `scripts/ui/run_results.gd` and `scripts/ui/character_selection.gd` with durable rewards/selection and replay-change disclosure; Retry preserves seed without rewinding XP/items or claiming equality after changed starting progression.
- [ ] T088 [US4] Apply V/unit/persistence/integration_m2 to progression/blocked-save behavior, manually check creation/selection/settlement/recovery and competing Windows writer/crash recovery; update `docs/development.md` and `docs/validation/m2-durable-progression.md`.

### Phase 8 — US4: Passives and six promotion branches (M2.1)

**Goal**: Level-15/item-gated permanent class choice with distinct attacks/effects/visuals and retained passive. **Independent test**: starter fixtures at 14/15/30, items 0/1 and all six branches without M3/M4. **Prerequisite**: T088.

- [X] T089 [P] [US4] Author eligibility/cancellation/double-confirm/permanent-choice tests in `tests/unit/test_promotion.gd`; reject unowned/already-promoted/wrong-base/low-level/no-item commands and prove one item + one branch commit atomically.
- [X] T090 [P] [US4] Author passive/branch activation and promoted-damage fixtures in `tests/unit/test_profession_abilities.gd`; fifth counters advance once per fired activation, reset each run, persist passive identity and remain independent of extra arcs/shots/status ticks and Milo's fifth counter.
- [X] T091 [US4] Add `data/skills/resolute.tres`, `data/skills/fleet_step.tres`, `data/skills/arcane_pulse.tres` and `data/professions/swordmaster.tres`, `abyss_swordsman.tres`, `sharpshooter.tres`, `star_hunter.tres`, `elemental_sage.tres`, `void_caster.tres`; enforce "exactly two branches per base M2, no second tier/cycles/respec" and validate branch references; store all declared tuning proposals in Resources and retain specified visual/attack/effect distinctions.
- [X] T092 [US4] Implement configuration-driven Resolute/Fleet Step/Arcane Pulse in `scripts/characters/passive_executor.gd`; apply 10% incoming reduction after flat defense/minimum 1, +10% starting speed and ×1.5 every fifth fired activation respectively, without display-name conditionals.
- [X] T093 [US4] Implement Swordmaster/Abyss Swordsman attack policies in `scripts/combat/sword_branch_attacks.gd`; two arcs count once with one fifth spin; longer spectral arc's fifth heals 2% own max once only on actual damage, without revival/corruption dependency.
- [X] T094 [US4] Implement Sharpshooter/Star Hunter policies in `scripts/combat/bow_branch_attacks.gd`; each arrow pierces ≤3 distinct enemies or ricochets once to a different nearby living target, fifth adds three-arrow volley or one delayed mark impact canceled on dead target.
- [X] T095 [US4] Implement Elemental Sage/Void Caster policies in `scripts/combat/mage_branch_attacks.gd`; alternate fire splash/frost with fifth burst, or finite damage zones/fifth susceptible-target pull; use active deadlines and no recursive counters/unbounded effects.
- [X] T096 [US4] Create `scenes/combat/damage_zone.tscn`, `scenes/combat/pull_zone.tscn` and original branch effect/identity assets in `assets/effects/`/`assets/sprites/characters/`; register them in `scripts/data/content_catalog.gd` and update `assets/provenance.md`.
- [X] T097 [US4] Implement branch preview/confirmation in `scripts/progression/promotion_service.gd`; validate fresh ownership/level/item/revision, preserve XP/passive and propose one irreversible branch/item mutation through SaveCoordinator; cancellation changes nothing.
- [X] T098 [US4] Create `scenes/ui/roster.tscn` and `scripts/ui/roster.gd` showing owned starters/permanent XP/level/base/current class/passive/items and promotion reason; no recruitment or third-party service required.
- [X] T099 [US4] Create `scenes/ui/promotion.tscn` and `scripts/ui/promotion.gd`; preview both branches from simulation data, state permanence/requirements, support cancel/fresh-edge confirm and wait for durable save before success/continuation.
- [X] T100 [US4] Wire owned-profession/passive factories and UI routing in `scripts/characters/character_factory.gd` and `scripts/core/app_router.gd`; compare base/branches in identical encounter fixtures without altering waves/enemy stats.
- [ ] T101 [US4] Apply V with eligibility/branch/passive/save tests; manually play all six branch identities/fifth effects and 14/15/30/item 0/1/cancel/failure Retry; update `docs/development.md` and `docs/validation/m2-promotions.md`.

### Phase 9 — US5: Follow and fight with companions (M2.2)

**Goal**: One active owned hero and 0–2 distinct companions. **Independent test**: run the same encounter solo, with one and two starters; down followers and active hero, then reopen. **Prerequisite**: T101.

- [X] T102 [P] [US5] Author party/formation/blocked/separated/downing fixtures in `tests/unit/test_companions.gd`; assert distinct owned 0/1/2 companions, reject third/duplicate/unowned, prioritize follow over chase and recover safely after 120 blocked ticks or >128-pixel separation.
- [X] T103 [P] [US5] Author companion damage/shared-upgrade/rewards/fixed-pressure regression in `tests/integration/test_m2_party.gd`; compare solo/full parties level 1/30/promoted against identical scheduled counts/stats/boss strength, test 0.5 outgoing damage after modifiers and full healing/defense.
- [X] T104 [US5] Implement valid owned party and persisted selection in `scripts/characters/roster_service.gd`; include ordered companion/start-level/class/passive snapshots, reject invalid roles and save confirmation before launch.
- [X] T105 [US5] Implement formation/follow movement in `scripts/characters/companion_controller.gd`; distinct slots within 32 pixels, at least active-hero following speed, own-position targeting, no chase/commands/deliberate warning dodge and no party body blocking.
- [X] T106 [US5] Implement safe relocation in `scripts/characters/companion_controller.gd`; after 120 blocked active ticks or >128 pixels use walkable no-enemy-overlap position, preserve health/cooldowns/downed state and retry when no safe position exists.
- [X] T107 [US5] Extend `scripts/characters/character_factory.gd`, `scripts/combat/attack_executor.gd` and `scripts/combat/actor_health.gd` for role-specific 0.5 outgoing damage, separate full health/45-tick immunity and downed inactivity; living companions never prevent active-hero death defeat.
- [X] T108 [US5] Extend shared XP/upgrades in `scripts/progression/run_progression.gd` and `scripts/progression/upgrade_effects.gd`; only active hero collects, apply eligible effects/healing only to living party, stop downed attacks/passives and restore full health next run.
- [X] T109 [US5] Extend participant rewards in `scripts/progression/permanent_progression.gd` and run snapshots in `scripts/core/run_summary.gd`; downed selected companions receive equal earned permanent XP, unselected heroes none; no active control swap.
- [X] T110 [US5] Integrate active/companion roles in `scenes/ui/roster.tscn`/`scripts/ui/roster.gd` and visible companion health/downing in `scenes/ui/combat_hud.tscn`/`scripts/ui/combat_hud.gd`; show invalid-party reasons and next-run-only selection effects.
- [ ] T111 [US5] Apply V with party/strength-invariance/upgrade/replay suites; manually verify 0/1/2 followers, no chase, blocked recovery/downing/active death/next-run restoration; update `docs/development.md` and `docs/validation/m2-companions.md`.

### Milestone 2 acceptance and runnable build

**Prerequisite**: T111. No M3 implementation until T115 passes.

- [X] T112 Execute twenty controlled progression close/reopen cases in `tests/integration/test_persistence_v1.gd`; cover XP/cap/promotion/party/failed Retry/current-corrupt recovery/newer-version boundaries, record SC-005 actual state comparisons in `docs/validation/m2-reopen.md`.
- [ ] T113 Extend `tests/performance/combat_stress.tscn` with two companions, measure the plan's three-seed workload and regress graphical feedback/frame budgets; record measurements/limitations in `docs/benchmarks/m2.md` and rerun affected tests after measured fixes.
- [ ] T114 Export `builds/windows/m2/AbyssExpedition.exe`, launch offline and manually verify roster/levels/six branches/parties/save errors/quit/reopen plus M1 combat paths; record commands and actual release behavior in `docs/validation/m2-release-playtest.md`.
- [ ] T115 Run V/unit/integration_m1/integration_m2/replay/persistence, reconcile FR-015–FR-023/SC-005 and affected prior criteria in `docs/validation/m2-gate.md`, update `docs/development.md` and retain the runnable M2 export; block M3 until evidence passes.

**Build checkpoint**: `builds/windows/m2/AbyssExpedition.exe` supports durable progression/promotions/companions with no collection or corruption dependency. Save failures keep the action pending and prevent further play/spending.

## Milestone 3 — Recruitment and Gacha

**Scope**: US6–US7; FR-024–FR-034; SC-006–SC-007 and previous regressions. **Entry**: explicitly authorized by the user on 2026-10-15 despite the original T115 acceptance prerequisite; earlier acceptance is not marked passed. End build: six-hero guild, guaranteed rescue, tickets, transparent draws/duplicates/exchange and durable reveal history.

### Phase 10 — US6: Guild, Sera rescue and earned tickets (M3.0)

**Goal**: Reliable collection through play and a clear guild hub. **Independent test**: fresh owned starters reach minute 4, accept/fail/decline rescue, settle success even on defeat and reopen without M4 events. **Prerequisite**: T115.

- [X] T116 [P] [US6] Author rescue/ticket fixtures in `tests/unit/test_rescue.gd`; test minute-4 offer independent of seed, centered radius-96 zone/inclusive boundary, 1800 continuous active ticks, paused timers, exit/death/decline failure and next-run offer; tickets at 4:59/5:00/victory/abandon.
- [X] T117 [P] [US6] Author schema-v1→v2/recruit settlement/guild fixtures in `tests/integration/test_m3_rescue.gd`; prove starter ownership retained, no migration-granted recruits, success+defeat grants Sera once, owned repeat grants one ticket and recruits join only next run.
- [X] T118 [US6] Add `data/characters/sera.tres` and `data/skills/guiding_light.tres` using Mage/only story acquisition; implement its lowest-health-percentage living-party heal in `scripts/characters/passive_executor.gd` every 1200 active ticks for 2% target max, tie active then slots, no overheal/revival/downed-Sera healing.
- [X] T119 [US6] Extend schema/profile validation in `scripts/persistence/profile_data.gd`/`scripts/persistence/profile_validator.gd` for tickets/tokens/history/draw receipts and saved independent RNG/index; enforce "64-bit values as decimal strings to avoid JSON numeric precision loss" and nonnegative integral balances; do not deserialize gameplay nodes/state.
- [X] T120 [US6] Implement pure v1→v2 migration in `scripts/persistence/profile_migrations.gd` with golden fixture `tests/fixtures/profiles/v2.json`; initialize zero tickets/tokens/empty history/independent RNG once, preserve source and commit a validated higher generation without rescue/draw hero grants.
- [X] T121 [US6] Define `scripts/data/rescue_definition.gd` and `data/events/sera_rescue.tres`; enforce "Sera, 1800 ticks, initial radius 96 pixels, one repeat ticket. Zone center equals active hero on acceptance."; use no generic EventDefinition/EventDirector.
- [X] T122 [US6] Implement standalone minute-4 RescueState/objective in `scripts/collection/rescue_objective.gd`; enforce "Boundary is inside; leaving once fails; no same-opportunity restart."; pause offer through ChoiceCoordinator, count only active defense time and earn pending reward without changing profile mid-run.
- [X] T123 [US6] Create `scenes/events/rescue_zone.tscn`, `scenes/ui/rescue_prompt.tscn` and `scripts/ui/rescue_prompt.gd`; show exact reward/conditions, marked zone/timer and immediate success/failure, explain reward awaits settlement and retain scheduled enemy difficulty.
- [X] T124 [US6] Extend frozen settlement rewards in `scripts/progression/permanent_progression.gd`; grant one ticket if ticks ≥18000, plus two on victory, plus one per successful owned rescue, or new Sera at level 1 for unowned success on victory/defeat; abandon/repeated result grant nothing.
- [X] T125 [US6] Create `scenes/ui/guild.tscn` and `scripts/ui/guild.gd`; route expedition/roster/promotion/rescue/recruitment/history, show catalog acquisition routes and promotion-item/ticket/token balances, prevent locked selection and keep navigation offline.
- [X] T126 [US6] Compose rescue scheduling/presentation/settlement through `scenes/world/expedition.tscn`, its `scripts/core/run_manager.gd` and `scripts/core/app_router.gd`; M3 offers Sera at minute 4 whether owned or not and retains rescue success through later defeat; register M3 content without M4 services.
- [ ] T127 [US6] Apply V/unit/persistence/integration_m3 rescue checks, manually play decline/fail/succeed/defeat/owned repeat and guild return/reopen; update `docs/development.md` and `docs/validation/m3-guild-rescue.md`.

### Phase 11 — US7: Transparent draws, duplicates and exchange (M3.1)

**Goal**: Spend earned tickets safely and obtain both draw heroes through transparent equal odds or five-token exchange. **Independent test**: injected outcomes at tickets 0/1/9/10, tokens 4/5, none/one/both owned; interrupt original reveal and reopen. **Prerequisite**: T127.

- [X] T128 [P] [US7] Author exact interval/batch/ownership tests in `tests/unit/test_recruitment.gd`; RNG 0/1 selects Brann/Nyra equally, all-Brann/all-Nyra/alternating ten-results convert sequential duplicates, tickets 0/1/9/10 and tokens 4/5/cancel/owned exchange change exact totals once.
- [X] T129 [P] [US7] Author draw transaction/reveal/interruption tests in `tests/integration/test_m3_draws.gd`; include persistence failure stages, repeated input, acknowledgment failure, immutable reopened outcomes/history and expedition seed/retry independence from draw state.
- [X] T130 [US7] Add `data/characters/brann.tres`, `data/characters/nyra.tres`, `data/skills/bastion.tres` and `data/skills/far_sight.tres`; implement first eligible hit per run-clock 1200-tick interval ×0.5 after defense and +20% starting reach in `scripts/characters/passive_executor.gd`; ignored immunity hits do not consume Bastion and promotion retains identity.
- [X] T131 [US7] Extend passive fixtures in `tests/unit/test_profession_abilities.gd` and dedicated `tests/unit/test_m3_passives.gd` for all six identities before/after class promotion, Sera heal ties/full health/downing, Bastion boundary/ignored hit/pause and Nyra range; confirm same-class heroes still have distinct passives.
- [X] T132 [US7] Define `scripts/data/gacha_pool_definition.gd`, `scripts/data/gacha_entry.gd` and `data/gacha/guild_pool.tres`; enforce "Brann/Nyra weight 1 each; costs 1/10 tickets, ten independent draws, duplicate 1 token, exchange 5." and "Positive weights; pool excludes starters/Sera; ownership never changes odds."; derive displayed probability from weights.
- [X] T133 [US7] Implement persistent independent draw RNG provider in `scripts/collection/draw_rng.gd`; integer [0,1] results, seed/state decimal serialization and monotonic index, injectable controlled provider and tentative-only advance before commit; expedition streams cannot reseed/select it.
- [X] T134 [US7] Implement ordered draw candidate/receipt generation in `scripts/collection/recruitment_service.gd`; validate sufficient tickets/count/revision, resolve against tentative ownership in display order, and atomically include cost/outcomes/new owners/tokens/RNG/index/awaiting-reveal/history in one candidate.
- [X] T135 [US7] Implement pool-hero exchange in `scripts/collection/token_exchange_service.gd`; preview/revalidate five tokens/unowned membership and commit cost+ownership once; no partial spending, duplicate records, pity counter or extra sinks.
- [X] T136 [US7] Implement reveal/history query and saved acknowledgment in `scripts/collection/recruitment_history.gd`; reopening returns original committed receipt, never calls RNG/spending again; failure retries only acknowledgment with the same operation.
- [X] T137 [US7] Create `scenes/ui/recruitment.tscn` and `scripts/ui/recruitment.gd`; show Brann/Nyra 50% each/100% total before spending, costs 1/10, cancel/confirm, missing balance, ten ordered results and duplicate tokens plus unowned-only exchange/history.
- [X] T138 [US7] Integrate reveal-before-further-spending routing in `scripts/core/app_router.gd` and six-entry acquisition/balance display in `scripts/ui/guild.gd`; SaveCoordinator commit precedes animation, disable repeated actions and preserve excess tokens after complete collection.
- [X] T139 [US7] Register exactly six hero Resources/pool/skills/screens in `scripts/data/content_catalog.gd` and extend catalog checks in `tests/validate_content.gd`; exactly three initial owners, Sera absent from pool, new recruits use existing base/promoted class policies and remain next-run selections.
- [ ] T140 [US7] Apply V/unit/persistence/integration_m3 and all six passive tests; manually inspect odds/costs/batch history/exchange/save-blocked and interrupted reveal after reopening; update `docs/development.md` and `docs/validation/m3-draws-exchange.md`.

### Milestone 3 acceptance and runnable build (M3.2)

**Prerequisite**: T140. No M4 implementation until T143 passes.

- [X] T141 Verify SC-006–SC-007 with fresh/full rosters, guaranteed Sera rescue, exact 50/50 intervals, controlled duplicates/exchange and reopened committed reveals; record automation and separate graphical observations in `docs/validation/m3-collection-acceptance.md`.
- [ ] T142 Export `builds/windows/m3/AbyssExpedition.exe`, manually complete an offline guild→expedition→rescue→settlement→draw→exchange→reopen session plus prior promotion/party paths; verify original reveals and local writable storage in `docs/validation/m3-release-playtest.md`.
- [ ] T143 Run V/unit/integration_m1/integration_m2/integration_m3/replay/persistence, reconcile FR-024–FR-034/SC-006–SC-007 and previous regressions in `docs/validation/m3-gate.md`, update `docs/development.md` and retain the runnable M3 export; block M4 until all required evidence passes.

**Build checkpoint**: `builds/windows/m3/AbyssExpedition.exe` includes reliable rescue and collection with durable outcomes; generic events/corruption are still absent.

## Milestone 4 — Abyss System

**Scope**: US8–US9; FR-035–FR-042; SC-008–SC-009/SC-012 and earlier criteria affected by full MVP. **Entry**: T143 passed; review these tasks against accepted M3. End build: corruption bargains, three coastal event types, chapter completion and preserved earlier flows.

### Phase 12 — US8: Visible corruption risks and benefits (M4.0)

**Goal**: Exact corruption thresholds and advantages without hidden strength scaling or unavoidable damage. **Independent test**: compare controlled encounters at 0/25/50/75/100, minute ticks/multiple crossings and preview/apply/decline bargain intents; Phase 13 supplies player-facing altar offers. **Prerequisite**: T143.

- [X] T144 [P] [US8] Author corruption/minute/boundary tests in `tests/unit/test_corruption.gd`; start 0, +5/full active minute, clamp to 100, cross each threshold once, recompute totals on multi-jumps, reject full costs without headroom and leave decline unchanged.
- [X] T145 [P] [US8] Author wave/gem/boss-modifier snapshots in `tests/integration/test_corruption_combat.gd`; exact count ceil/weight swap/damage, existing enemies/gems unchanged, immediate new-gem bonus and next newly scheduled ≥45-tick second eruption, including pause and crowded spawn caps.
- [X] T146 [US8] Define `scripts/data/corruption_definition.gd` and `data/encounters/coast_corruption.tres`; enforce "cap 100, +5/full minute, thresholds 25/50/75/100" and encode specification count/weight/damage/gem/environment/second-circle changes as total modifiers, not compounding additions.
- [X] T147 [US8] Implement `scripts/abyss/corruption_service.gd` with CorruptionState "value 0..100" and "Threshold changes are recomputed from total value; no repeated additive reapplication."; full-cost preview, once-only offer application/minute crossing and immediate advantage/environment signals.
- [X] T148 [US8] Integrate next-wave snapshots in `scripts/combat/spawn_director.gd`; total count ×1.10 at 25 or ×1.20 at 100/ceil once, Broodmother +10 points/Thrall −10 at 50, future normal damage ×1.15 at 75, including later broodlings; existing enemy stats remain fixed and no party-strength scaling.
- [X] T149 [US8] Snapshot corruption gem XP at death in `scripts/progression/xp_pickup.gd`/`scripts/core/simulation_coordinator.gd`; +10/20/30/40% at threshold, old gems retain stored values and minute increment precedes same-tick wave snapshot.
- [X] T150 [US8] Extend `scripts/combat/boss_controller.gd` so corruption 100 adds a second circle only to the next newly scheduled eruption with a complete warning and unchanged warned geometry; corruption cap alone never ends the run.
- [X] T151 [US8] Create `scenes/ui/corruption_summary.tscn`, extend `scenes/ui/combat_hud.tscn` and add `scripts/ui/corruption_summary.gd`; show 0–100 meter, exact current XP advantage/future-wave danger and accessible summary, no initial corruption from class identity.
- [X] T152 [US8] Add original tide/violet shoreline feedback in `scenes/world/coast_field.tscn` and `assets/tiles/`, keeping safe ground/hero/warnings readable; update `assets/provenance.md` and reset all corruption/environment state between runs.
- [ ] T153 [US8] Apply V/unit/integration_m4 modifier tests, manually compare threshold visuals/boss warnings/gem gains and pause-free minutes with a fixed seed; update `docs/development.md` and `docs/validation/m4-corruption.md` before events.

### Phase 13 — US9: Coastal events and chapter completion (M4.1)

**Goal**: Seeded merchant/altar/rescue decisions and a persistent repeatable coast chapter. **Independent test**: fixed-seed runs exercise every event choice/collision/boss pattern; win/reopen/replay; compare ten fixed seeds with Sera owned/unowned. **Prerequisite**: T153.

- [X] T154 [P] [US9] Author event schedule/choice/cost tests in `tests/unit/test_events.gd`; 2/4/6 slots, guaranteed unowned minute-4 rescue, equal merchant/altar outside it, owned equal thirds, exact costs/rewards, free decline/leave and one resolved choice per opportunity.
- [X] T155 [P] [US9] Author event/level/manual pause/boss arbitration and chapter/reopen tests in `tests/integration/test_m4_chapter.gd`; terminal cancels choices, level precedes event, event resolves before boss, no clock leakage/held-confirm spending and no events during boss.
- [X] T156 [US9] Define `scripts/data/event_definition.gd`, `scripts/data/event_choice.gd` and `data/events/mysterious_merchant.tres`/`forbidden_altar.tres`/`lost_adventurer.tres`; enforce "M4: merchant/altar/lost adventurer only." and "One choice resolves once."; refer to the existing RescueDefinition rather than duplicating rescue mechanics.
- [X] T157 [US9] Implement event slot/offer state in `scripts/abyss/event_director.gd`; add independently derived `event_offers` stream in `scripts/core/seed_streams.gd`, freeze each offer once, preserve guaranteed unowned rescue and replace M3's always-owned minute-4 offer with specified seeded scheduling.
- [X] T158 [US9] Add one temporary coin per non-boss gem/death and active-hero-only collection in `scripts/progression/xp_pickup.gd`/`scripts/core/run_state.gd`; show balance in `scripts/ui/combat_hud.gd`, never convert coins to permanent tickets and reset on every ending/retry.
- [X] T159 [US9] Implement Merchant choices in `scripts/abyss/event_effects.gd`; 20 coins heals active hero 25% max, 30 coins applies Might to living party, Leave free; preview and revalidate all costs before applying one offer, no corruption change.
- [X] T160 [US9] Implement Altar choices in `scripts/abyss/event_effects.gd`; Blood Tithe charges active-hero 20% max health leaving ≥1 plus 25 corruption for living-party +30% damage; Unbound Assault charges 35 corruption for +40% frequency; full headroom required, Decline free, modifiers expire at run end.
- [X] T161 [US9] Delegate Lost Adventurer to `scripts/collection/rescue_objective.gd`; no duplicate Sera/tokens, each distinct owned opportunity can earn one settled ticket, unowned rescue remains only minute 4 and pause/boundary/failure rules stay unchanged.
- [X] T162 [US9] Extend `scripts/core/choice_coordinator.gd` and `scripts/core/simulation_coordinator.gd` for immutable event queue and terminal > level > event > boss priority; Escape maps only to defined free leave/decline, manual pause remains owned, no world tick between queued modals.
- [X] T163 [US9] Create `scenes/ui/event_choice.tscn` and `scripts/ui/event_choice.gd` with readable exact current costs/benefits, health/headroom/coin-disabled reasons and fresh-edge one-choice intent; reuse rescue presentation and show earned-versus-settled rewards accurately.
- [X] T164 [US9] Extend replay trace/event fixtures in `scripts/core/replay_trace.gd` and `tests/integration/test_replay.gd` to record ordered event offers/resolutions and Sera ownership at start; document the explicit M3→M4 owned-rescue schedule change in `docs/development.md`.
- [X] T165 [US9] Add v3 chapter-completion schema and pure v2→v3 migration in `scripts/persistence/profile_data.gd`/`profile_validator.gd`/`profile_migrations.gd` with `tests/fixtures/profiles/v3.json`; "M4 adds chapter completion flags." and "No health, current XP/upgrades, time, enemies, coins, corruption, active rescue or pending event is serialized as a resumable expedition."; preserve prior data/source and default chapter false.
- [X] T166 [US9] Include Chapter 1 completion in the once-only victory candidate in `scripts/progression/permanent_progression.gd`; display saved completion in `scripts/ui/run_results.gd`/`scripts/ui/guild.gd` only after commit, allow unlimited repeat expeditions and require boss defeat every time.
- [X] T167 [US9] Add Aetheran coast/ocean-cult context outside combat in `scenes/ui/guild.tscn` and original colorful terrain/enemy/boss details in `assets/tiles/`/`assets/sprites/enemies/`; audit amphibious/eldritch silhouettes and placeholder replacement plans against `docs/art-direction.md`/`assets/provenance.md` without expanding content.
- [ ] T168 [US9] Apply V/unit/integration_m4/replay/persistence and manually play every event choice/disabled/leave/decline, rescue scheduling/collision, boss/chapter save/reopen/repeat; update `docs/development.md` and `docs/validation/m4-events-chapter.md`.

### Final phase — Milestone 4 acceptance, polish and runnable full MVP (M4.2)

**Prerequisite**: T168. Polish means resolving acceptance failures within the specified scope, not speculative features.

- [X] T169 Execute the ten frozen quickstart seeds with Sera unowned and owned in `tests/integration/test_m4_chapter.gd`; record all three event types, ≥3 ordered offer sequences and every eligible unowned minute-4 rescue plus chapter reopen evidence in `docs/validation/m4-event-variety.md` (SC-009); never cherry-pick seeds after failure.
- [ ] T170 Run ten-player bargain comprehension tests with exact displayed benefits/costs before choice, requiring ≥8 correct; manually verify low/high-corruption decision value/disabled reasons and record SC-008 in `docs/validation/m4-human-playtest.md`.
- [X] T171 Extend isolated persistence/interruption fixtures in `tests/integration/test_persistence_v3.gd` and run at least twenty representative reopen/settlement cases plus every distinct contract failure class; cover migration, chapter, rewards, draws/reveal acknowledgment, repeated Retry/confirm and complete previous-or-committed state in `docs/validation/m4-integrity.md` (SC-012).
- [ ] T172 Extend `tests/performance/combat_stress.tscn` for two companions/max corruption/extra warnings; run the exact three-seed reference protocol and graphical input/hit/danger checks, long no-pickup/reward preservation, and record raw counts/p95/p99/latency/limitations in `docs/benchmarks/m4.md`/`docs/benchmarks/m4.csv`; optimize only measured bottlenecks and rerun affected traces/rewards.
- [X] T173 Audit export manifest, keyboard focus/text/scale, actor/effect cleanup and original asset provenance in `scripts/data/content_catalog.gd`, `export_presets.cfg`, `assets/provenance.md` and `docs/art-direction.md`; fix observed acceptance defects and exclude all development fixtures while preserving gameplay counts/effects.
- [ ] T174 Export `builds/windows/m4/AbyssExpedition.exe` and manually complete a full offline Windows session covering combat/progression/promotion/party/rescue/draw/exchange/events/chapter/quit/reopen; inspect saves/Resources and record all earlier flows subject to the documented owned-rescue scheduling change in `docs/validation/m4-release-playtest.md`.
- [ ] T175 Execute final V/unit/all four integration suites/replay/persistence and reconcile all FR-001–FR-042/SC-001–SC-012 with actual evidence in `docs/validation/m4-gate.md`; update `docs/development.md` and this feature's `quickstart.md`, preserve the runnable M4 export and leave every unmet/unexecuted criterion open.

**Build checkpoint**: `builds/windows/m4/AbyssExpedition.exe` runs the full offline MVP and passes new plus affected earlier criteria. Tasks producing builds are planned, not executed by this document.

## Dependencies and execution order

### Milestone/phase graph

```text
M1 Setup T001–T005
  → Foundation T006–T018
  → US1 movement/combat T019–T032
  → US1 waves/XP T033–T040 + US2 choices T041–T050
  → US1 complete loop T051–T059
  → US3 readability/replay T060–T066
  → M1 build/acceptance T067–T073 [gate]
  → M2 US4 durability T074–T088
  → M2 US4 passives/promotions T089–T101
  → M2 US5 companions T102–T111
  → M2 build/acceptance T112–T115 [gate]
  → M3 US6 guild/rescue T116–T127
  → M3 US7 draws/exchange T128–T140
  → M3 build/acceptance T141–T143 [gate]
  → M4 US8 corruption T144–T153
  → M4 US9 events/chapter T154–T168
  → M4 acceptance/polish/build T169–T175 [gate]
```

US2 reuses US1's three weapons/damage/XP; US1's complete-loop gate waits for US2. US3 seed primitives are shared foundation, while its independent replay/readability acceptance follows integrated combat. US4 depends on accepted US1–US3; US5 needs US4's stats/ownership/persistence/passives. US6 needs accepted M2, and US7 needs US6's ticket/ownership/migration/guild foundations. US8 needs accepted M3; US9 needs US8's modifiers and US6's rescue, US7's persistence integrity. US8's player-facing bargain acceptance closes with US9 altar integration and the M4 gate. No story requires a later milestone to satisfy its stated independent test.

### Explicit shared-file and gate prerequisites

- T007–T009 share T006's runner prerequisite and may be authored together; T010 waits for all three. Resource references are resolved by catalog composition after schema completion.
- T019/T020 share T018; T033/T034 share T032. T037 waits for schedule/definitions/behaviors; T040 waits for spawn and XP. T050 covers combined M1.2 work, so T051 cannot begin at T040 alone.
- T043–T049 update shared combat/progression/catalog paths in order; T054 waits for T053; T055 waits for boss/controller plus simulation coordinator; results/routing follow terminal logic. T066 waits for all US3 fixtures and integration.
- M1 export T067 follows all gameplay checkpoints; benchmark creation/measurement T068/T069 follows export; release smoke T072 and full gate T073 wait for profiling/human/duration evidence and any fixes/revalidation. Benchmark and human tasks do not claim pass when reference hardware/participants are unavailable.
- T079 waits for validator/lock; T080 waits for generation store; T081 waits for store/coordinator; T082–T087 remain sequential mutations to shared routing/persistence/UI. T091 follows test authoring, and branch implementations T093–T095 are sequential while touching shared combat registrations. T101 validates all branches before companions.
- T112–T115 wait for complete companions, persistence and M1 regression. T119–T120 introduce v2 before new durable collection rewards; T126 waits for rescue/UI/rewards/guild. M3 guild can display unavailable routes before US7 is integrated, but the M3 gate requires every route functional.
- T132/T133 precede T134; exchange/history/UI follow committed draw protocol. T139 follows both rescue and draw content, providing the exact-six roster gate. T141–T143 wait for all M3 behavior and earlier regressions.
- T148–T150 wait for T146/T147; event costs T159/T160 wait for coin state T158 and CorruptionService. T162/T163 follow event/rescue delegates; T165 migrations precede T166 completion settlement. T175 waits for every full-MVP acceptance/export task T169–T174.
- Whenever a validation task identifies a blocker, fix it in the owning task's named files and rerun affected checks before marking the checkpoint complete. No later milestone can unblock an earlier incomplete acceptance criterion.

## Parallel execution examples per story

These are optional scheduling opportunities, not delegation instructions. Finish the common prerequisite first. Integrations/shared-file edits stay sequential; do not start all stories together.

| Story / setup | Common prerequisite | Separate-file work that may run together |
| --- | --- | --- |
| Setup | T002 | T003 art conventions; T004 provenance ledger |
| Foundation | T006 | T007 stats; T008 character/profession/skill schemas; T009 weapon/effect/visual schemas |
| US1 | T018 / T032 / T050 respectively | T019 combat tests + T020 wave tests; T033 schedule/field data + T034 enemy data; T051 boss tests + T052 loop tests |
| US2 | T040 | T041 upgrade tests + T042 pause/choice integration tests |
| US3 | T059 | T060 seed/replay tests + T061 UI-state tests |
| US4 | T073 / T088 respectively | T074 progression tests + T075 persistence fixtures; T089 eligibility tests + T090 branch/passive tests |
| US5 | T101 | T102 companion unit tests + T103 party integration fixtures |
| US6 | T115 | T116 rescue/ticket unit tests + T117 migration/settlement integration fixtures |
| US7 | T127 | T128 controlled draw tests + T129 transaction/reveal tests |
| US8 | T143 | T144 threshold tests + T145 modifier integration fixtures |
| US9 | T153 | T154 schedule/cost tests + T155 chapter/arbitration integration fixtures |

## Requirement and acceptance traceability

| Requirements / criteria | Owning tasks and mandatory exit evidence |
| --- | --- |
| FR-001–FR-003, FR-014 | T012–T018, T019–T032, T052, T058; M1 gate T073 |
| FR-004 | T020, T033–T037, T040, T050; later strength-invariance T103/T148 |
| FR-005–FR-007 | T038–T050; shared living-party extension T108 |
| FR-008 | T019, T024–T029, T045, T050; companion/passive extensions T092/T107/T130 |
| FR-009–FR-010 | T017, T042, T047, T051–T059; full event precedence T155/T162 |
| FR-011–FR-013 | T060–T066, T069/T070; all milestone graphical checkpoints |
| SC-001 / SC-003 / SC-010 | T069/T070, T072/T073; changed workload checks T113/T172 |
| SC-002 / SC-004 / SC-011 | T071 / T051–T059/T072 / T060/T063/T066; M1 gate T073 |
| FR-015–FR-020 | T074, T076, T083/T084, T089–T101; recruited passives T118/T130/T131 |
| FR-021–FR-023 / SC-005 | T075–T088, T102–T115; twenty reopen checks T112 |
| FR-024–FR-028 / SC-006 | T116–T127, T139/T141; M3 gate T143 |
| FR-029–FR-034 / SC-007 | T128–T143; durable draws/history before reveal |
| FR-035–FR-037 / SC-008 | T144–T153, T156/T160/T163, T170; M4 gate T175 |
| FR-038–FR-042 / SC-009 | T154–T169, T174; M4 gate T175 |
| SC-012 | T171/T174/T175 and rerun affected prior acceptance; twenty integrity cases plus all failure classes |

## Implementation strategy

Deliver Milestone 1 first as the complete playable MVP slice, including US1–US3; US1 alone is an intermediate combat checkpoint because required choices/readability/replay belong to US2/US3. Validate each phase and fix blockers before its successor. Retain the M1 executable/evidence before activating M2, then repeat for M2/M3/M4. Every milestone ends in an offline runnable Windows release, automated suites, Godot validation, separate graphical/manual evidence and updated developer instructions.

Create folders/files only when their tasks become active. Keep logic in its service, UI in adapters, immutable content in Resources and mutable run/profile state separate. Shared foundation must serve M1 requirements. Existing numeric spec defaults remain authoritative; balancing hypotheses may be refined and recorded before their gate, and changes to specified values require a specification revision and affected regression checks.

All checklist boxes remain open at generation. Document-format/coverage validation is the only verification performed here; no GDScript, scene, Resource, test runner, export, gameplay test, performance measurement or human playtest has been implemented or run by this step.


## Phase 14: Convergence

**审计日期**：2026-10-15。**结果**：`tasks_appended`，未收敛。此阶段仅追加审计待办，不改变原任务、勾选、规格、技术计划或游戏实现。原 T001–T175 共 175 项，其中 26 项仍开放；实现与证据优先于勾选。

**核对范围**：42 FR、12 SC、38 个用户故事验收场景、20 个边界案例，共 112 个需求/验收条目；全部 175 个原任务；8 项宪法原则。技术计划按 15 组核对：引擎/离线依赖、模块与场景所有权、Resource/校验、效果配置、固定 tick/暂停、攻击与伤害、生成规则、队伍、成长与事务、收集、腐化/事件、随机与回放、视觉/UI、性能、导出与阶段 gate。核对不等于全部验证通过。未确认宪法 MUST 违规；保留已获明确授权的 F9 沙盒及 M2–M4 激活，不将其列为未授权扩展。正式角色立绘/生产精灵不属于本次新增要求，已有原创占位及替换记录仍适用。

**发现统计**：16 项，HIGH 8 / MEDIUM 8；`missing` 1 / `partial` 12 / `contradicts` 3 / `unrequested` 0。F1–F16 对应下列任务，优先列出 HIGH；实际执行须服从依赖，测量/参与者不可用时保留未验证，不阻止先修复独立代码缺口。

- [X] T176 [US8] HIGH / F1：修复 `scripts/data/wave_schedule.gd` 的腐化 50+ 权重替换：各阶段均从 Thrall 转出 10 个百分点给 Broodmother，即使该阶段原始 `ids` 尚无 Broodmother；保留总数量、其他敌人份额、强制引入与安全/cap 规则。当前第 22 行以 `phase.ids.has("reef_broodmother")` 为门槛，导致 8:00 前无此危险；`scripts/ui/corruption_summary.gd` 还显示了规格没有的延后条件。移除此条件，扩展 `tests/integration/test_corruption_combat.gd` 至早期/中期/末期及 49/50/75/100，回归固定种子、暂停、现存敌人快照；更新相关证据与实施文档 per FR-036、US8/AC3、spec: initial spawn defaults、T145/T148/T151 (contradicts)
- [X] T177 [US4] HIGH / F2：修复 `scripts/persistence/profile_store.gd` / `profile_loader.gd` 对存档工件的枚举与恢复：异常 `profile-*` 文件名、非规范/重复 revision、目录读取失败必须产生可见诊断并阻止静默创建/选择；区分真正空目录与无法读取/只有异常存档的目录，保留所有原始证据，恢复仍需确认。当前 `generations()` 跳过异常名，`load_profile()` 将空列表视作新档；本次隔离复现保留 `profile-bad.json` 后直接创建 `profile-1.json`、receipt.kind=creation。为这些分支在 `tests/integration/test_persistence_v1.gd` / `test_persistence_v3.gd` 增加实际文件负例，确保无静默回退、无重复 revision 歧义、无覆写 per FR-023/FR-033、save/load contract、contracts/persistence: invalid filenames/duplicate revisions、T079/T081 (contradicts)
- [X] T178 [US4] HIGH / F3：在 `scripts/progression/permanent_progression.gd` / `scripts/core/app_router.gd` 生成各参与者实际到账 XP、等级变化及 cap 标记，并由 `scripts/ui/run_results.gd` 明确显示已达 Lv30/被丢弃溢出。当前 `settle()` 正确限制 2900 XP，但结果第 17 行统一显示名义 XP，未报告封顶。覆盖已满级、跨入满级、未满级混合队伍及保存失败后同一结果 Retry，保留物品/票券奖励 per US4/AC4、FR-016/FR-017、T083/T085/T087 (partial)
- [X] T179 HIGH / F4：为 `tests/integration/test_m1_loop.gd` 的 App 在入树前注入唯一 `user://tests/<run-id>/` SaveCoordinator，并检查测试运行器/其他 fixture 不会访问默认玩家 profile；在 `tests/run_tests.gd` 与相关测试边界加入可执行的拒绝措施，不能仅依赖外层 APPDATA 重定向。当前该 fixture 直接使用 App 默认 writer；按 quickstart 单独运行会读取/写入默认 profile，既依赖旧状态也可能改变玩家选人/seed/结算。保留 FR-014 的历史 M1 独立构建验证含义，避免将加载当前 M4 App 的断言命名为 M1-only 证据 per plan: testing/storage isolation、contracts/persistence: test roots、quickstart: never live profile、T052/T075/T112 (contradicts)
- [ ] T180 HIGH / F11：待 T189 的采样工具补齐后，依 `plan.md` 的指定 Windows 11 / i5-8400 / GTX 1050 Ti / 16 GB / release / 1920×1080 协议复测三 seed；对实际瓶颈先分析再修复，维持敌人/效果/弹体/宝石工作量和玩法规则，重跑受影响回放、奖励、暂停及可视反馈检查。另行实测 VSync-on 输入/命中显示延迟 ≤100 ms。最近已有 `docs/validation/verification-2026-10-15.md` 三组源码采样 p95 为 18.409/18.757/18.587 ms、p99 为 25.519/26.078/25.729 ms，均超预算；它们不是参考机 release 验收。硬件/测量设备缺失时只记录限制，不勾完成 per plan: performance budgets、SC-010、T069/T113/T172 (partial)
- [ ] T181 HIGH / F12：依 `docs/validation/m1-human-playtest.md` 与 `m4-human-playtest.md` 招募并记录十名初见玩家的启动/操控、三角色差异、乐趣/重试评分、密集场景一秒危险识别与选择前契约收益/成本理解；按既定阈值记录逐人原始结果，反馈导致的修复回到所属模块再验证。当前有协议、无参与者结果，自动截图/测试不替代这些证据；参与者不可用时保持未验证 per SC-001/SC-003/SC-008/SC-010、T070/T170 (partial)
- [ ] T182 HIGH / F13：按 `docs/validation/m1-duration.md` / quickstart 完成二十次普通 baseline 单人胜利，三 starter 分配 7/7/6，记录 build/seed/起始状态/主动时长并检查每个角色均可胜利、至少 16 次处于 9–11 分钟。当前 `tests/integration/test_full_run.gd` 仅提供 seed 101 受控策略胜利，不能替代普通样本；若调参，先遵循规格修订要求再回归 per SC-002、T071 (partial)
- [ ] T183 HIGH / F15：在完成影响玩法/保存的修复后，依 `docs/validation/m1-release-playtest.md`、`m2-release-playtest.md`、`m3-release-playtest.md`、`m4-release-playtest.md` 对保留的各里程碑 Windows 发布版进行普通键鼠离线会话验收；当前完整 MVP 覆盖公会→出征→救援/事件→胜败/放弃→成长→转职/队伍→抽取/兑换/历史→退出重开，补禁选、保存失败 Retry/恢复及三窗口尺寸。M1 独立性通过保留的 M1 构建实际核对；构建存在/受控图形探针不等于完整人工会话。任何重建须保留历史证据并记录新构建身份，先前未执行项继续开放 per FR-014/FR-042、SC-004/SC-005/SC-012、T072/T114/T142/T174 (partial)
- [X] T184 MEDIUM / F5：完善 `scripts/data/content_catalog.gd`、`effect_definition.gd`、`upgrade_definition.gd`、`wave_schedule.gd` 及关联 schema 的启动校验与 `tests/validate_content.gd` 负例。当前 EffectDefinition 不校验 stat_category/stack_policy/target_scope，WaveSchedule 不校验 introduce 与阶段/目录的引用关系，`UpgradeOfferService.eligible()` 不处理 required_capabilities；错误配置可能被忽略、给出无效选择或在执行中出错。对已定义能力明确支持或拒绝，校验类型/范围、各类 ID 唯一性与引用，并以 path/ID/reason 正常失败；无需新增通用效果解释器 per plan: validated immutable Resources、data-model: common rules、T010/T011/T043/T046 (partial)
- [X] T185 [US5] MEDIUM / F6：修复 `scripts/characters/companion_controller.gd` 普通跟随的边界阵位分配，确保两位 living companion 在四边/四角仍以不同位置为目标且不与主角重合、保持两英雄宽度与不追敌约束。当前 `formation(Vector2(8,8),0)` 直接 clamp 到 `(8,8)`，安全重定位检查未覆盖随后每 tick 的常规目标。扩展 `tests/unit/test_companions.gd` 覆盖边角、切换方向、无安全候选及健康/冷却保留，补图形辨识检查 per FR-021、companion defaults、T105/T106 (partial)
- [X] T186 MEDIUM / F7：让 `scripts/progression/upgrade_effects.gd`、`scripts/combat/status_effects.gd` / `attack_executor.gd` 与升级预览从同一明确 Resource 参数取得实际效果，补齐 `data/upgrades/` 中治疗/燃烧/减速/额外攻击需要的配置。当前 Battle Mend 的 20% 治疗写在代码、Resource 仅存 5% 伤害；burn 的 0.1×3/60/180 与 frost 的 0.8/120 也独立硬编码，预览为手写 description。保持 FR-007 现行数值/刷新/快照/次数不变，增加配置到预览及执行的一致性检查 per plan: data-driven effects、data-model: previews use same parameters、T009/T043/T044/T045 (partial)
- [X] T187 [US3] MEDIUM / F8：扩展 `scripts/core/replay_trace.gd` 与 `simulation_coordinator.gd` 的实际输入记录，将阶段 0 消费的移动方向/输入变化按主动 tick 写入 trace，避免暂停/恢复同一阶段重复记入；保留已有升级/事件选择及版本/队伍 metadata。当前 `trace.decisions` 仅由升级选择写入，事件另记，无法从记录恢复影响位置/生成安全的移动。扩展 `tests/integration/test_replay.gd`，至少包含从记录驱动的实际移动、暂停、选择与场地占用，而非仅直接跳 tick 调用波次调度；不新增玩家回放 UI 或跨版本物理一致性承诺 per plan: replay records tick-indexed decisions、T060/T063/T164、SC-011 (partial)
- [X] T188 [US4] MEDIUM / F9：在 `scripts/ui/promotion.gd` 预览两分支的实际视觉身份，复用 ProfessionDefinition.visual_set 与现有程序绘制/原始占位，不要求制作正式精灵；预览继续显示变化后的攻击/自动能力与不可逆选择。当前界面仅有 description 和 HP/damage/reach，没有 UI 合约规定的外观预览。用六分支的图形检查确认外观与实战配置一致、取消无消耗，保持 UI 不拥有战斗规则 per plan: UI contract promotion visual preview、T099 (missing)
- [X] T189 MEDIUM / F10：完善 `tests/performance/benchmark_capture.gd` 与 `tools/run_m4_benchmarks.ps1`（以及相应 M2 入口）的可复核采样路径：支持当前 release 的诊断运行而不将测试夹具变成玩家功能；30 秒预热后按实际主动模拟时间采 120 秒，逐帧统计 living normals/boss/effects/moving projectiles/gems，补 CPU/physics/draw calls/nodes/memory 与 build/engine/硬件/窗口/VSync/电源/调试器元数据。当前 boss 列固定为 1、enemy 列直接减 1，时间按 wall clock 累加，仅有 frame_ms 和静态内存，无法充分核实协议。报告区分采样结束与预算通过，保留原始 CSV/历史结果，增加工作负载/奖励守恒核验，再供 T180 测量 per plan: benchmark protocol、T068/T113/T172 (partial)
- [ ] T190 MEDIUM / F14：补完原阶段检查中的人工部分，逐项记录真实输入、观察结果与未执行原因：M1 focus/边界/攻击/升级/预警/暂停/重试，M2 保存恢复/六分支/同伴，M3 救援/赔率/历史/中断展示，M4 阈值/每个事件/章节重开；使用各原任务命名的 `docs/validation/` 文件，自动图形断言只作辅助证据。已有原生/受控图形结果不能关闭这些普通操作检查 per T018/T032/T050/T059/T066/T088/T101/T111/T127/T140/T153/T168、plan: per-phase playable checks (partial)
- [X] T191 MEDIUM / F16：在本阶段代码修复与可执行验证完成后，重新核对 42 FR/12 SC/全部用户验收/边界及原任务，更新 `docs/validation/m1-gate.md`、`m2-gate.md`、`m3-gate.md`、`m4-gate.md` 和 `specs/001-abyss-expedition-mvp/quickstart.md` 的当前证据索引；按实际结果保留人工/参考机/显示延迟等未关闭项，不将 1723 个既有断言或已勾选任务当作收敛证明。每个后续实现任务同任务更新 `docs/game-development-dashboard.html`、`docs/IMPLEMENTATION_OVERVIEW.md`、README 链接及所需开发/验证记录，检查离线资源相对路径；本次审计不改写这些文件 per T073/T115/T143/T175、SC-012、plan: verification/traceability (partial)

### 本次执行证据与边界

- 执行 prerequisite 检查，定位到本 feature；已存在完整 tasks 与 M1–M4 实现/运行证据，满足 converge 的运行前提。未发现 `.specify/extensions.yml`，无前置/后置 hook。
- 使用固定 `tools/godot-4.5/Godot_v4.5-stable_win64_console.exe`，版本实际为 `4.5.stable.official.876b29033`；执行 `--headless --path . --script res://tests/validate_content.gd`，51 root Resources / 27 scenes / 98 scripts 有效，catalog digest `97664f9f25b1232d331b80728d5cfdd10f637e261e35a1f4e3a79b538a7ea2c9`。
- 执行 `--headless --fixed-fps 60 --path . --script res://tests/run_tests.gd -- --suite <suite>`：unit 182、scene_smoke 130、integration_m1 37、replay 40、full_run 9、progression 13、persistence 304、abilities 107、integration_m2 36、recruitment 293、integration_m3 196、integration_m4 307、debug_panel 69；成功运行合计 13 组 / 1723 断言，0 失败、0 跳过。workspace 隔离运行日志位于 `tools/runtime-converge-20261015/`；unit/scene_smoke/content 首次成功运行的日志在当次 sandbox TEMP。三个受控 starter 胜利 tick 为 33348/32860/32893，不能替代 SC-002 普通胜利样本。
- 保留失败记录：首次使用 sandbox TEMP 作为 APPDATA 时，integration_m1 在 `test_m1_loop.gd:10` 因 app.run 为 Nil 报错（14 断言、1 失败）；切换到已创建的 workspace 隔离 APPDATA 后无代码变更复跑通过 37 断言。未确认首次环境失败根因，不将那次计为通过，也不把它判定为已复现的产品缺陷；F4 的默认路径依赖由源码独立确认。
- F2 运行复现：在唯一 workspace APPDATA `tools/runtime-converge-malformed-20261015/` 的默认 profile 目录复制 `tests/fixtures/profiles/v3.json` 为 `profile-bad.json`，运行源码主场景 `--headless --quit-after 4`，实际 exit 0，原文件保留且新增 `profile-1.json`，新 receipt.kind=creation、revision=1、owners=Aren/Lia/Milo。此为意外新档的证据，不是恢复通过；没有接触真实玩家 APPDATA。
- 其余新代码缺口为源码/Resource/场景接线与现有测试范围的审查发现；本次未为它们新增或执行专门负例，不能将现有通过数称为这些缺口的验证。未执行新的 graphical/export、性能采样、参考机/显示延迟测量或人工研究；性能值引用的是已有原始报告，而非本次新测。

**后续**：运行 `$speckit-implement` 处理新增任务及其前置依赖，再运行 `$speckit-converge`。只有全部要求的行为与验收证据满足时才能报告 converged。


### Phase 14 实施结果 — 2026-10-16

- 完成 T176–T179、T184–T189、T191，共11项；T180/T181/T182/T183/T190继续开放。原T001–T175的26个开放项未改勾选；总计160完成/31开放，不代表全MVP验收或完成率。
- 最终单轮13组原生5,239断言，0失败/跳过；递归加载145脚本/29场景/51Resource通过。源码及实际重新导出的Windows EXE在三尺寸的M2/M3/M4受控图形、发布禁F9通过，多进程锁通过。受控图形不替代自然键鼠会话；先前4551失败日志保留。
- T187同时修复长trace进入永久receipt的体积风险，以及满级队首次救援Sera后回放条件变化提示。T180已根据测量移除无敌期无效hit记录分配，保持45tick与Bastion行为及三个starter的tick/kill/HP；不因局部优化而关闭性能任务。
- T189三组release真实计数/奖励守恒/30+120主动秒捕获有效，p95 27.571/27.670/29.259ms，均超预算。主机非参考机，显示延迟未测。Dummy audio只用于诊断，本轮未宣称真实音频验收。
- [当前逐项证据与限制](../../docs/validation/convergence-2026-10-15.md)、[FR/SC索引](../../docs/validation/convergence-2026-10-15/requirements-status.json)、[AC/边界/宪法/计划核对](../../docs/validation/convergence-2026-10-15/acceptance-review.json)。图鉴、中文概览、README、四阶段gate与Quickstart同任务同步；approved spec/plan原始hash不变。没有extension hooks。

## Phase 15: Q1 战斗品质（2026-10-18，用户授权自主打磨）

范围与验收先记录于[Q1规格/设计](quality-pass-20261018.md)，原FR/SC与所有人工gate保留。

- [X] T192 检查源码与基线实机，保存三初始角色及首领的改前截图，记录体验问题和参考研究。
- [X] T193 实现实际接受命中的独立反馈、击杀碎光、伤害数字；验证48条/36tick、无敌、暂停、随机流与离场释放。
- [X] T194 重做职业姿态、扫斩/弹体、敌人/首领轮廓与原创海岸遗迹；保持判定和数据不变。
- [X] T195 HUD分区与事件倒计时；修正实机发现的首版文字遮挡，保留可见HP/XP/等级/seed/腐化信息。
- [X] T196 14组5,249原生断言、源码与独立新EXE三尺寸图形、F9开发/发布限制通过；前后同输入状态相同。更新Dashboard/概览/README及验证证据，旧构建和截图保留。
- [ ] T197 真人试玩Q1假设：定位/预警辨识、命中力度、数字疲劳、倒计时等待感与重试意愿；未招募参与者，不以自动检查关闭。

[本轮报告和前后截图](../../docs/validation/quality-20261018.md)。本轮没有关闭T180/T181/T182/T183/T190或历史人工/参考机验收；完整性能结果以报告为准。

- [X] T198 基于密集场景实测定位Q1首版性能回退，缓存原创地形与敌人图集（静止诊断总调用2503→723），保留源码/生成资产与失败结果，重跑受影响图形/反馈检查及单seed完整30+120秒压力采样；结果见Q1报告，参考硬件gate保持开放。
