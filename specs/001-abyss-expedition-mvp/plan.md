# Implementation Plan: Abyss Expedition

**Feature identifier**: `001-abyss-expedition-mvp` | **Date**: 2026-10-14  
**Branch**: None; the workspace has no Git repository. Setup returned the feature identifier as its branch fallback; no branch was created.  
**Specification**: [spec.md](spec.md) | **Constitution**: [version 1.0.0](../../.specify/memory/constitution.md)

## Summary

Build an offline Windows desktop survivor-like game using Godot 4, typed GDScript, native scenes, immutable content Resources, small gameplay services, and typed signals. Deliver a complete combat loop before permanent progression, collection, and corruption.

This plan covers **all four MVP milestones**. Per the 2026-10-14 task-generation request, `tasks.md` covers all four as a dependency-ordered roadmap; active implementation starts with **Milestone 1 only** and later milestones remain blocked by the preceding acceptance gate. Recheck later tasks against accepted gameplay before activating them. Task generation changes planning documents only; no application code, assets, scenes, dependencies, or project settings.

## Technical Context

| Topic | Decision |
| --- | --- |
| Engine/language | Pin standard Godot **4.5.stable.official.876b29033**, typed GDScript and matching 4.5 export templates. This is the locally verified connector version, not a claim to be the latest release. |
| Existing project | `project.godot` declares 4.7, Forward Plus/D3D12, expand stretching, and no main scene. M1 setup must reconcile the configuration with the pinned engine and validate import. Use Compatibility rendering. No settings mutation during planning. Engine changes require a recorded pin and replay/validation rerun. |
| Platform | Windows 10/11 x86_64, keyboard, offline single-player. Windows 11 is the reference performance OS. |
| Dependencies | Godot built-ins only for shipping; no C#, GDExtension, backend, database server, external API, or third-party test/runtime plugin. Matching export templates are development tooling. |
| Storage | M1: in-memory only. M2+: one versioned local JSON profile with validated recovery generations under `user://`. No expedition resume. |
| Testing | Native GDScript logic runner with explicit exit codes; import/parse and scene-instantiation checks; headless integration fixtures; separate graphical playtests, exported build smoke and profiling. |
| Scope | M1: 3 starters/base professions, 12 upgrades, 5 enemy behaviors plus broodlings, one field/boss. Full MVP: exactly 6 heroes, 6 promotion branches, 0–2 companions, 3 event types, one chapter/profile. |
| Time | 60 fixed simulation ticks per active second; all gameplay timers share active time. No paused wall-clock catch-up. |
| Performance | Target 60 FPS; measured p95 frame time ≤16.67 ms and p99 ≤25 ms; input/hit feedback ≤100 ms under conditions below. |
| Art | 640×360 logical viewport; integer viewport scaling, nearest sampling, 16-pixel tiles, 32×32 hero frames; readable original placeholders first. |

## Constitution Check

These are design compliance checks, not completed gameplay tests. Pre-research review found no proposed exception; the post-design review retains the same gates.

| Principle | Before research | After design |
| --- | --- | --- |
| I. Gameplay First | Compliant: M1 is the active slice. | Compliant: independent victory/defeat/retry gate precedes later work. |
| II. Modular Architecture | Compliant: eight responsibilities have boundaries. | Compliant: scene ownership, Resource/state separation and explicit interfaces; no speculative framework. |
| III. Original IP | Compliant: original/permissible placeholders only. | Compliant: asset provenance and replacement records; no franchise assets or copied interfaces. |
| IV. Testable Development | Compliant: FR/SC and edge cases govern acceptance. | Compliant: automated/manual coverage, failure injection and actual evidence reporting in quickstart. |
| V. Pixel Art | Compliant: numeric conventions required before assets. | Compliant: scale, animation, sampling and dense-scene readability checks defined. |
| VI. Performance/Maintainability | Compliant: measurable workload and seeds required. | Compliant: reference hardware/budgets, bounded spawns and measured optimization; no preemptive pooling. |
| VII. Scope Control | Compliant: full roadmap, only M1 active. | Compliant: all 42 requirements covered, no networking/monetization/extra content or later infrastructure in M1. |
| VIII. Incremental Delivery | Compliant: sequential checkpoints. | Compliant: every phase requires validation, evidence and docs; missing checks remain unverified. |

**Gate result**: compliant for planning; implementation still requires phase/milestone evidence. No constitutional amendment or exception is requested.

## Project Structure

### Documentation

```text
specs/001-abyss-expedition-mvp/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/systems.md
  contracts/persistence.md
  contracts/ui.md
  checklists/requirements.md
```

`tasks.md` is the task-generation workflow output, grouped by the four milestones with story labels and acceptance gates.

### Proposed Godot architecture

```text
project.godot
export_presets.cfg                    # M1 implementation
scenes/
  app/app.tscn
  world/expedition.tscn, coast_field.tscn
  actors/hero.tscn, enemy.tscn, boss.tscn
  combat/projectile.tscn, melee_arc.tscn, telegraph.tscn
  pickups/xp_gem.tscn
  ui/main_menu.tscn, character_selection.tscn, combat_hud.tscn
  ui/level_up.tscn, pause_menu.tscn, run_results.tscn
  ui/roster.tscn, promotion.tscn, save_error.tscn       # M2
  ui/guild.tscn, recruitment.tscn, rescue_prompt.tscn # M3
  events/rescue_zone.tscn                           # M3
  ui/event_choice.tscn, corruption_summary.tscn      # M4
scripts/
  core/          # App routing, RunManager, RunClock, PauseCoordinator, SeedStreams
  combat/        # Controllers, targeting, attacks, damage, statuses, spawning, enemy/boss AI
  characters/    # Character/profession/skill schemas; passives/companions added M2+
  progression/   # Run XP/upgrades M1; permanent progression/promotion M2
  collection/    # Recruitment, gacha, duplicate rewards M3
  abyss/         # Corruption/event policies M4
  ui/            # Input/presentation adapters only
  persistence/   # Profile validation, migration, transactions M2+
  data/          # ContentCatalog and remaining Resource schemas
data/
  characters/, professions/, skills/, weapons/, enemies/, upgrades/
  encounters/    # Wave schedule, boss patterns, field configuration
  balance/       # Explicit numeric combat/visual defaults
  gacha/         # M3
  events/        # M4; standalone rescue definition in M3
assets/
  sprites/placeholders/, sprites/characters/, sprites/enemies/, tiles/, effects/, ui/
  provenance.md
tests/
  run_tests.gd, validate_content.gd
  unit/, integration/, fixtures/, scenes/, performance/
docs/
  development.md, art-direction.md, validation/, benchmarks/
builds/windows/  # Generated artifacts, excluded from source control
```

Create folders only when needed. Definitions vary by stable ID/capability, never hero display-name conditionals.

## Scene hierarchy and ownership

```text
App (Node: always processes routing)
  ContentCatalog (validated read-only Resources)
  ScreenHost (Control: menu/selection/results; later guild)
  ExpeditionHost (Node: owns at most one Expedition)
    Expedition (Node2D: run composition root)
      RunManager / RunClock / PauseCoordinator / SeedStreams
      CombatWorld (Node2D: pausable)
        CoastField (terrain, boundaries, spawn regions)
        Actors (active Hero, enemies, boss; M2 companions)
        Projectiles / Pickups / Telegraphs / Effects
      CombatSystems (registry, targeting, damage, spawning, XP/upgrades)
      HUD (CanvasLayer: consumes state)
  ModalHost (CanvasLayer: always processes input, one active choice)
  ProfileServices (M2 only: progression/promotion/persistence)
  CollectionServices (M3 only)
```

No global event-bus/autoload is required. App owns services and connects run-local signals on mount, then disconnects and frees Expedition completely on exit. Persistent services receive snapshots/results, never hero node references. M1 supplies fixed starters directly and has no save-service stub dependency. Scene ownership is runtime parentage; editor `owner` is set appropriately when authoring packed subscenes.

Hero is a `CharacterBody2D` containing body collision, hurtbox, health/stats, an injected player or later companion controller, attack executor, and presentation (`AnimatedSprite2D`/`AnimationPlayer`). Enemy uses shared health/attack primitives and a small Resource-selected behavior policy. Boss owns a warning/attack/recovery state machine. Sprite frames never define collision or damage timing.

Projectiles belong to Expedition, so attacker deletion cannot orphan them. Hit messages carry stable run actor IDs. Spawn warnings reserve capacity: active plus reserved non-boss slots cannot exceed 100. Remove dead actors from the targeting registry immediately, defer node deletion safely, and cancel stale callbacks using run generation IDs.

Gameplay descendants inherit pausable processing. App/modal UI may process while paused, but must not tick gameplay. One fixed-tick coordinator orders gameplay updates and checks newly acquired pause reasons between systems; level-up stops further gameplay updates immediately. Signals can still invoke callbacks on paused nodes, so handlers also validate run state. UI animation remains separate from gameplay timers.

## Reusable systems and event flow

See [systems contract](contracts/systems.md), [UI contract](contracts/ui.md), [persistence contract](contracts/persistence.md), and [data model](data-model.md) for typed boundaries, signals, schemas and failures.

Select hero/seed → validate start snapshot → instantiate run → movement/automatic targeting/attacks → damage/deaths → gems/XP → queue levels → pause → stable three-choice offer → apply exactly once → next choice or resume → terminal arbitration → results → Retry same seed or New Expedition. M2+ requires durable settlement before continuation from any permanent mutation.

Separate RNG streams handle waves, positions, upgrades and later events. Derive them using documented SHA-256 labels and stable sorted IDs; tie targets by spawn sequence. Cosmetic randomness never consumes gameplay streams. Replay records engine/game/content version, start progression/party and tick-indexed decisions. This guarantees repeatable random outcomes with matching conditions, not cross-platform bit-identical physics. Draw RNG is persistent and independent of expedition seeds.

Damage, every-fifth-attack counters and delays belong to simulation, not animation callbacks. Resolve eligible same-tick hits before terminal arbitration, with active-hero death taking precedence over boss death. Terminal state cancels choices. Drop/reward events and each UI confirmation have idempotence guards.

## Art and animation conventions

- 640×360 viewport; `viewport` stretch, keep aspect, integer scale and letterboxing; 1280×720 default window and 1920×1080 reference display. Nearest texture filtering, no sprite mipmaps. Keep physics positions continuous and snap presentation consistently; visually inspect camera jitter and unusual window sizes.
- Tiles: 16×16. Heroes/ordinary enemies: 32×32 canvas; boss: 64×64. **Hero width means a 16-world-pixel gameplay footprint**, not the art canvas: spawn separation 96, companion formation radius 32, relocation separation 128. Hero body silhouette about 16×24 pixels.
- Initial visual timing: idle 4 frames/6 FPS, move 6/10 FPS, attack 4/12 FPS, hurt 2/12 FPS, death 6/8 FPS then final pose/removal. Priority death > hurt > attack > move > idle. Movement remains usable during attacks; visuals never gate hit timing or cooldowns.
- Show arc/arrow/star shapes, brief hit flash/impact marker, blink plus outline for 0.75-second invulnerability, clear death silhouette. No global hit-stop initially. Boss cone/circle warnings last at least 45 active ticks and differ from impacts; resistant enemies show shield/ring feedback.
- UI ordinary labels start at 12 logical pixels, with high-contrast values, keyboard focus, short descriptions and shapes as well as color. Test readability at 2×/3× scale. Placeholder silhouettes must distinguish the five enemy behaviors.
- `assets/provenance.md` records creator/source/license, placeholder status and replacement target. Original replacement art follows the same scale; franchise assets are prohibited.

## Performance and benchmarks

**Reference target, not observed hardware**: Windows 11, Intel Core i5-8400, GeForce GTX 1050 Ti 4 GB, 16 GB RAM, SSD, 1920×1080/60 Hz, Compatibility renderer, release export. Alternate hardware must be recorded and does not automatically establish this baseline.

After a 30-second warm-up, capture 120 active seconds for each of seeds 101, 202, 303: 100 living non-boss enemies plus boss, 30 attack effects, 100 moving projectiles and 500 gem nodes. Benchmark-only fixtures replenish these counts. M2 adds two companions; M4 adds maximum corruption and warnings. Record build/engine, CPU/GPU/RAM, OS/driver, renderer, resolution, VSync, power mode, debugger/profiler, actual counts, sample duration, frame p50/p95/p99/max, CPU/physics, draw calls, nodes and memory. Run uncapped profiling and VSync-on graphical acceptance separately.

Target 60 FPS with p95 ≤16.67 ms and p99 ≤25 ms, and SC-010 input/hit feedback ≤100 ms. Correlate input/hit timestamps with displayed frames and recording/high-frame-rate observation; headless throughput cannot establish visual latency. Human recognition remains an 8-of-10 test. All benchmarks are currently **unmeasured**.

Start with registered actor lists, squared-distance checks on ready attacks, collision layers, reusable query buffers, preloaded definitions/scenes, and finite projectile/effect lifetimes. Stagger noncritical AI decisions at 10 Hz, but move/collide at 60 Hz. Ready weapons may scan each tick to acquire a new target promptly. Avoid hot-loop scene-tree searches and allocations. No arbitrary projectile cap may discard promised attack effects.

Profile a long no-pickup run as well as the normal fixture. Preserve every gem's reward; if pickup nodes dominate, merge nearby stationary gems by exact summed XP/coins without expiry. Pooling, spatial indexing and batched visuals require recorded bottleneck evidence followed by behavior/replay checks. Never optimize by silently changing specified waves or upgrade effects.

## Dependency and implementation order

Every phase ends with import/parse, relevant logic tests, scene/runtime smoke, graphical play of changed behavior when available, and updated developer/evidence docs. Blocking failures stop progression; missing tooling leaves affected checks unverified.

| Phase | Work/dependencies | Exit checkpoint |
| --- | --- | --- |
| M1.0 Foundation | Reconcile engine/config; renderer/input/viewport; App/selection/field; catalog validation and native test runner. | Clean import/parse/scene startup/exit; focus and scale checked. |
| M1.1 Movement/combat | M1.0; boundaries, three weapons, target/hit rules, simple enemy and feedback. | All starters controllable; damage/targeting tests and graphical boundaries/no-target/homing/death checks. |
| M1.2 Waves/growth | M1.1; five behaviors/broodlings, fixed schedule, spawn safety/cap, XP, 12 upgrades, choice/pause and seeds. | Schedule, catalog, overflow/fallback, active timers and replay tests; playable escalating combat. |
| M1.3 Complete loop | M1.2; boss at 9:00, cone/eruption warnings, outcome arbitration, HUD/results/retry. | Independently win/lose/retry without any M2–M4 Resource/service; terminal collision and cleanup pass. |
| M1.4 Acceptance/export | M1.3; Windows export, profiling, ten-player tests, twenty baseline victories, ten replay pairs. | Stories 1–3, FR-001–FR-014, SC-001–SC-004 and SC-010–SC-011 documented before activating M2 implementation. |
| M2.0 Durable progression | Accepted M1; profile validation/recovery/transactions, owned starters, permanent XP/rewards, saved selection. | Save failure blocks; same-action Retry, corrupt/newer saves, rewards/caps and reopen checks pass. |
| M2.1 Promotions/passives | M2.0; starter passives, six branch attacks/effects/visual identities, preview/confirm/item spend. | 14/15/30 and item 0/1; independent fifth counters and passive continuity; idempotent promotion. |
| M2.2 Companions/gate | M2.1; follow/formation/recovery, downing, shared upgrades and participant rewards. | Stories 4–5, FR-015–FR-023, SC-005, twenty close/reopen checks; unchanged enemy schedule across party strength; M1 regression. |
| M3.0 Guild/rescue | Accepted M2; hub, Sera/passive, standalone minute-4 rescue and tickets. | Rescue success/failure/retry/defeat settlement without generic M4 events. |
| M3.1 Draws/exchange | M3.0; Brann/Nyra/passives, pool, one/ten draws, duplicates, exchange, history/reveal. | Controlled RNG boundaries, ordered results, exact cost/reward commit, interrupted reveals and independent draw sequence. |
| M3.2 Collection gate | M3.1; exact six heroes, odds/routes/balances, offline/export regression. | Stories 6–7, FR-024–FR-034, SC-006–SC-007; prior checks remain valid. |
| M4.0 Corruption | Accepted M3; meter/ticks/thresholds, next-wave modifiers and immediate gem/environment effects. | 0/25/50/75/100, multiple crossings/headroom, warnings and fixed-strength schedule tested. |
| M4.1 Events/chapter | M4.0; 2/4/6-minute seeded events, merchant/coins/altar, reused rescue, coast presentation and completion. | Exact costs, choice serialization, guaranteed unowned rescue and documented owned-rescue scheduling change. |
| M4.2 Full acceptance | M4.1; all regressions, bargain usability, sequence variety, interruption matrix and benchmark. | Stories 8–9, FR-035–FR-042, SC-008–SC-009 and SC-012; twenty integrity cases and full offline Windows session. |

M2 introduces permanent starting stats, independent passives and branch activations. Each attack that fires advances counters once, never per projectile/arc/tick. Companions follow without chasing, deal 0.5 outgoing damage after their modifiers, and retain full defensive/healing effects. Promotions are outside-run profile transactions.

M3 rescue is a small timed objective, not a generic quest framework. Draws evaluate ownership sequentially against a tentative profile; cost, RNG sequence, ten outcomes, duplicate conversion and unrevealed history commit together before animation. Retry persists the same candidate.

M4 takes over rescue scheduling with the specification's explicit owned/unowned change. Wave modifiers snapshot at the next wave, without mutating existing enemies. XP/environment change immediately; at corruption 100, the extra boss circle applies to the next newly scheduled eruption and receives the full warning. Blood Tithe charges active-hero health; its run buff applies to the living party. Chapter completion joins terminal settlement.

## Verification and traceability

[quickstart.md](quickstart.md) supplies commands and automated/manual acceptance matrices. All 42 FRs and all 12 SCs map to the phase gates above. Specification numeric defaults are authoritative; changing them requires specification revision and affected regression checks. New balance numbers absent from the specification are explicit initial hypotheses in the data model.

Planning checks cover links, schemas/contracts, milestone coverage and unresolved markers. No import, gameplay test, graphical test, build, performance measurement or human test has been run in this planning step.

## Complexity Tracking

No constitutional violations or exceptions. Native scenes/Resources/signals and small services suffice; no ECS, dependency-injection framework, global bus, speculative backend or preemptive pooling.

