# System and signal contracts

These are planned GDScript interfaces, not implementation code or network APIs. Commands return typed success/failure records with stable reason codes; UI derives readable messages. Runtime services receive explicit dependencies at composition time. Definitions live in [data-model.md](../data-model.md).

## Responsibilities and interfaces

| System / owner | Commands / queries | Signals and guarantees |
| --- | --- | --- |
| ContentCatalog / App | `validate_all()`, `character(id)`, `profession(id)`, `upgrade(id)` | Fails startup with content path/ID/reason if required data is invalid. Returns shared read-only definitions. Explicit Resource manifest works after export. |
| AppRouter / App | `show_menu()`, `select_start(selection)`, `mount_run(snapshot)`, `leave_run()` | Owns screen lifecycle, not combat rules; frees previous run and connections before mounting another. M1 has only fixed starter access. |
| RunManager / Expedition | `start(snapshot)`, `request_abandon()`, `summary()` | `phase_changed(phase)`, `run_finished(summary)` once; phase preparation → active → resolving → results → disposed. Pause is an independent reason set, not competing state machines. M2 resolving waits for durable settlement. |
| RunClock / Expedition | `active_tick()`, ordered `advance_one_tick()` | `minute_reached(index)`, `wave_due(index)`, `boss_due()` produced once at due active ticks. Runs from zero; stops during pause/resolution. Initial wave is scheduled on activation at tick 0. |
| PauseCoordinator / Expedition and modal adapter | `acquire(reason, owner_id) -> token`, `release(token)`, `is_blocked()` | Derives tree pause from tokens; cannot release another owner's pause. Terminal cleanup invalidates all outstanding choice tokens. UI/routing alone process during pause. |
| ChoiceCoordinator / Expedition | `enqueue_level(level)`, `enqueue_event(offer)`, `confirm(offer_id, option_id)` | `choice_presented(offer)`, `choice_resolved(id)`; one active choice, immutable offered options, no confirmation leakage to next screen. |
| SeedStreams / Expedition | `stream(label)`, `trace_snapshot()` | Wave type/position/upgrade/event streams; no global RNG consumption. Tests inject known RNG providers; gameplay uses native RNG. |
| PlayerController / hero | `read_movement_actions() -> Vector2`, `simulate(tick)` | WASD/arrows normalized, opposing inputs cancel; `move_and_slide` against boundaries; no aiming or attack action. |
| TargetingService / run | `nearest(origin, range, faction) -> actor_id?` | Living/damageable valid registry entries only, distance between centers, equal squared distance selects earliest spawn order. Boss no priority. |
| AttackExecutor / each actor | `try_activate(tick)`, `effective_attack()` | `attack_fired(actor_id, activation_id, snapshot)`; no target means remain ready, no counter/cooldown consumption or backlog. Emits projectiles/arcs via expedition factory. |
| DamageService / run | `enqueue_hit(request)`, `resolve_tick_hits()` | `damage_applied(result)`, `actor_died(actor_id, source)`; validates generation/target, deduplicates hit IDs, rejects invulnerable hits without refreshing immunity. Central formula and deterministic request order. |
| StatusService / actor | `apply(effect, source_snapshot)`, `tick(active_tick)` | Burn/slow refresh policy and finite expiration; death clears effects; secondary damage cannot recurse into on-hit effect generation. |
| SpawnDirector / run | `schedule_wave(index)`, `reserve_slot(candidate)`, `activate_warning(id)` | `spawn_warned(id, geometry, deadline)`, `enemy_spawned(id)`; safe seeded candidates, cap/reservation checks, no delayed catch-up burst. No party power input. |
| EnemyController / enemy | `decide(tick, active_hero)`, `move_tick()` | Behavior policy pursuit/rush/ranged/armored/summoner; no full-tree lookup. AI reads active hero position; no companion-dependent scaling. |
| BossController / boss | `begin_encounter()`, `start_pattern(id)`, `tick()` | `attack_warned(pattern_id, geometry, deadline)`, `attack_resolved(id)`; fixed warning geometry before damage; resistant feedback; normal spawn and broodling creation stop at boss boundary. |
| RunProgression / run | `collect_xp(pickup_id, value)`, `apply_upgrade(offer_id, id)` | `xp_changed(xp, required, level)`, `level_earned(level)`, `upgrade_applied(id, stacks)`; shared party XP; pickup and choice each consumed once. |
| CharacterFactory / run | `create(character_definition, start_state, role)` | Combines profession weapon/skills, independent passive and later permanent stats. Runtime has no display-name branches. |
| PermanentProgression / App M2 | `preview_settlement(summary)`, `preview_promotion(hero, branch)`, `confirm_promotion(operation_id)` | Proposes a complete profile mutation; persistence alone acknowledges commit. Ownership/level/item eligibility returned with reason. |
| CompanionController / hero M2 | `set_formation_slot(index)`, `follow_tick()` | Distinct positions within two widths, attacks from own position, no chase. Blocked 2s/separation >8 widths initiates safe relocation preserving health/cooldowns. No safe point means retry. |
| RosterService / App M2 | `validate_party(active, companions)`, `confirm_selection(selection)` | One owned active, 0–2 distinct owned others; confirmation persisted. New recruits selectable next run only. |
| RecruitmentService / App M3 | `pool_preview()`, `prepare_draw(count, operation_id)`, `prepare_exchange(hero, operation_id)`, `acknowledge_reveal(receipt_id)` | Ordered tentative ownership/duplicate conversion; all cost/results committed before reveal; no expedition RNG dependency. |
| RescueObjective / run M3 | `offer(opportunity_id)`, `accept()`, `decline()`, `tick()` | `rescue_changed(state, elapsed)`, `rescue_earned(reward_route)`; earns a pending result, never writes the profile during the run. |
| CorruptionService / run M4 | `preview_cost(amount)`, `apply_cost(offer_id, amount)`, `on_minute(index)`, `wave_modifiers()` | `corruption_changed(value)`, `threshold_crossed(value)` once; recomputes total modifiers, immediate advantage/visual update. |
| EventDirector / run M4 | `on_slot(tick)`, `preview_choice(id)`, `confirm(event_id, choice_id)` | Uses event stream, owns event queue and delegates rescue; checks all costs first, changes in-memory run state once; no permanent cost during event. |
| SaveCoordinator / App M2 | `load_profile()`, `commit(candidate, operation_id, expected_revision)`, `retry(operation_id)`, `recover(revision)` | `save_committed(operation_id, revision)`, `save_failed(operation_id, reason)`, `recovery_required(options)`; see persistence contract. |

## Tick ordering and arbitration

Use a single small simulation coordinator, not a generic ECS. Actor scripts expose simulation methods and do not independently advance gameplay in unspecified `_process` order. Godot input/physics provide movement/collision support; callbacks enqueue IDs and validated intents rather than performing immediate cross-system mutations.

For each active tick:

1. Apply tick-indexed movement/input and already due gameplay timers. Step actors/projectiles; gather contacts and elapsed status/weapon effects. A manual pause received before the tick prevents it entirely.
2. Resolve the deterministic hit batch, ordered by stable activation/source/target IDs; mark deaths and remove targetability immediately. Finish eligible lethal hits in that tick so simultaneous active-hero/boss death becomes defeat.
3. Arbitrate terminal outcome. If terminal, cancel choices/spawns, stop time and emit one summary. Otherwise emit once-only non-boss gem drops, kill counts and pending pickup changes.
4. Consume pickups and run XP. Determine all earned levels with overflow, queue them and freeze before any subsequent gameplay update. Each choice applies once while world remains frozen. Do not recursively tick combat from signals.
5. Queue due event opportunities (M3/M4) after levels; resolve existing/queued choice before boss entry. Manual pause remains a separate token. Boss due at 9:00 blocks further normal/broodling creation even if its entrance must wait for choices.
6. If no blocking reason remains, perform due wave/AI/attack scheduling under the current tick. At minute/wave coincidence, apply the minute's corruption tick before snapshotting that wave. Advance active tick only once for the completed simulation step; a suspended step resumes at its saved stage, never repeats hits/XP or catches up wall time.

Implementation must test this ordering directly, including pausing midway through the coordinator's stages. Terminal > earned level choices > pending event > boss entry; manual pause is never implicitly removed. No world update occurs between multiple queued levels. Presentation signals may update UI while paused but cannot mutate simulation except an authorized choice command.

## Targeting, hits and spawning

Melee faces the selected nearest target; all enemies in its arc can receive one hit per arc. Straight projectiles retain firing direction. Homing retains a living target within range measured from the projectile, otherwise reacquires by nearest/spawn-order tie, and expires immediately if none. All projectiles expire after their original lifetime (default 180 ticks). Pierce hits ≤3 distinct enemies; ricochet requires a different nearby living second target.

After a valid hero/companion hit, invulnerability expires 45 active ticks later. Invalid hits neither change health nor extend it. Immunity and knockback follow simulation time. Downed companions stop all attacks/passives; active-hero death ends the run even if others live.

Every ten seconds through 8:50 use exactly the specification's schedule. Randomly fill composition with integer weights, replace Thrall slots to guarantee newly introduced types in a phase's first wave, then generate positions. For each slot try at most 16 seeded field-edge candidates, inside walkable bounds and ≥96 pixels from every living party member; skip if none valid. Reservations count toward 100; skipped slots never accumulate. Warn 45 ticks. Revalidate safety at activation: cancel an unsafe normal slot without instant relocation/damage. Broodling warning positions beside the mother require no party overlap and parent-child cap; cancel if parent dies, boss time arrives, or space becomes unsafe.

Boss entrance at 9:00 announces immediately after higher-priority choices. If no safe non-overlapping entry exists, retain one boss-entry request and retry safe placement; once placed give the full warning before damage. Do not discard the only boss, auto-win, clear existing enemies, or create a normal-wave backlog. Test crowded-edge entry explicitly. Existing non-boss enemies stay; no new broodlings after the boundary.

## RNG contract

Input seed accepts decimal integers 0..2147483647; blank chooses a random seed once and displays it. Reject fractional, signed-negative, overflow and nonnumeric input without starting. A versioned stream derivation hashes UTF-8 `abyss-rng-v1|<decimal seed>|<label>` with SHA-256, interprets the first eight bytes in big-endian order, masks the sign bit, and seeds that stream. Record the derivation version; do not rely on implementation-dependent `hash()`.

Labels: `wave_types`, `spawn_positions`, `upgrade_offers`, and `event_offers` in M4. Eligible upgrade IDs are lexicographically sorted; sample three uniformly without replacement using that stream. One offer stays fixed. Candidate spawn attempts consume the documented number of draws even when rejected; trace attempts/skips so equivalent decisions/occupancy can be compared. Random traces record wave index/types/positions, offer IDs and event sequence. Cosmetic particles use an unrelated unrecorded source.

M3 draws use independent saved RNG seed/state and monotonically increasing draw index; each draw chooses an integer in [0,1], 0 Brann/1 Nyra. Ownership does not affect selection, only conversion. Controlled test providers cover both exact intervals. Seed/state encode as decimal strings in JSON. Preparing a draw advances only tentative RNG state until the profile transaction commits.

## Example signal flows

- `attack_fired` → instantiate attack from snapshot → queue collision hit → `damage_applied` → health/HUD/feedback → `actor_died` → drop gem once → `xp_changed` / `level_earned` → pause and `choice_presented`.
- `choice_confirmed(offer, upgrade)` UI intent → validate offered membership/current ID → apply to living party → consume input → generate next queued offer using updated eligibility, or release choice token.
- `run_finished(summary)` → M1 results directly; M2+ preview complete rewards → SaveCoordinator commit → `save_committed` → results with continuation. Failure holds frozen summary and same candidate.
- Draw confirm → eligibility → ordered candidate receipt/cost/RNG → persistence → reveal original receipt; reopening awaiting receipt reveals it without calling draw generation.
- Minute tick → corruption update → queue event if due → once choices complete snapshot wave modifiers → warned spawn. An event cost checks health/coins/headroom atomically before any effect.

All signal subscriptions are owned by the composition root or corresponding instance and cleaned up at run exit. Late signals with another run generation are discarded; callbacks do not keep freed nodes alive.


> 2026-10-19 增量说明：首波场边默认现由[002 FR002近场位置合同](../../002-combat-pacing-audio/contracts/pacing.md)覆盖，仅首波位置；45tick预警、安全/容量、后段规则与历史证据保留。前120秒全Thrall基础默认现由002 FR004/005固定四槽与额外Thrall规则覆盖；7200tick后五主阶段、腐化、幼体与首领合同保留。新规则已接线，不以此说明当作验收。
