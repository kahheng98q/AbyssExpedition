# Data model and content schemas

**Scope**: design only. Definitions use typed native Godot Resources; runtime records use typed GDScript objects. JSON contains primitive IDs/values only. M1 implements only the M1 rows. All specification tables are authoritative content; these schemas describe their storage and validation.

## Common rules

- Stable lowercase `StringName` IDs are unique within type; saved IDs serialize as strings. Display names never determine behavior. Catalog references are explicit typed Resources/IDs and validated before play; no arbitrary script paths are loaded from saves.
- Definitions are read-only after validation. Actors own mutable state separately, including nested effects/counters. Definition revision and catalog digest join replay metadata.
- Distances/speeds use world pixels and pixels/active second; timing definitions use seconds converted once to integer ticks at 60 Hz. Percentages are fractional numbers; costs/counts/XP are nonnegative integers. Reject NaN/infinity, negative durations, unknown IDs, invalid ranges, duplicate IDs and cycles in profession branches.
- ContentCatalog explicitly lists shipped Resources/PackedScenes so exported builds do not depend on filesystem enumeration of source `.tres` files. Validate all references and capability-handler registrations.
- Small effect enums map to registered shared handlers, not a general scripting/interpreter language. New handler types must serve specified content. UI previews use the same effect parameters as simulation.

## Resource definitions

| Resource | Fields and relationships | Validation / introduced |
| --- | --- | --- |
| CharacterDefinition | `id`, `display_name`, `base_profession: ProfessionDefinition`, `portrait`, `visual_set`, `passive: SkillDefinition?`, `acquisition_route`, `description` | M1 Aren/Lia/Milo; passives mandatory M2. M3 adds Sera/Brann/Nyra, exactly six. Acquisition starter/story/draw-exchange; Sera excluded from pools. |
| ProfessionDefinition | `id`, `base_id`, `is_promotion`, `starting_stats: StatBlock`, `weapon: WeaponDefinition`, `automatic_skills[]`, `visual_set`, `promotion_ids[]` | Three bases M1; exactly two branches per base M2, no second tier/cycles/respec. A branch must belong to the hero's base class. |
| StatBlock | max health, damage, attack frequency, movement speed, targeting reach, flat defense, knockback strength, pickup radius | Positive health/frequency/ranges, nonnegative defense. Class baselines are immutable; runtime effective stats are derived. |
| SkillDefinition | `id`, `trigger_kind`, `activation_interval`, `period_ticks`, `effect_kind`, `magnitude`, `duration_ticks`, `radius`, `target_policy`, `required_capabilities[]` | M1 reusable burn/slow/attack effects where needed; hero passives/branch abilities M2+. No hero-name checks. Period/count positive for relevant trigger. |
| WeaponDefinition | `id`, `mode` (arc/straight/homing), `damage_scale`, `reach`, `frequency`, `arc_angle`, `projectile_scene`, `speed`, `lifetime_ticks`, `pierce_limit`, `ricochet_limit`, `effects[]`, `telegraph_ticks` | Nonzero reach/frequency; projectile lifetime default 180 ticks; mode-specific required fields. Activation independent of animation. |
| EnemyDefinition | `id`, `behavior_kind`, `stats`, `weapon`, `resistances`, `damage_reduction`, `xp_drop`, `visual_set`, `summon_definition?`, `summon_interval`, `max_living_children` | Five specified behaviors plus frail broodling. All non-boss deaths drop base 10 XP. Broodmother ≤3 living children; total cap includes children/reservations. |
| BossDefinition | enemy-like stats/visuals, `patterns: BossPattern[]`, `knockback_resistant`, `arrival_tick` | Tidebound Hierophant only; arrival 32400 ticks, cone/eruption ≥45-tick warnings; no XP requirement for boss. |
| BossPattern | `id`, `geometry`, `damage`, `windup_ticks`, `recovery_ticks`, `range/radius`, `direction_lock`, `extra_circle_at_corruption` | Damage only after full warning. Warning geometry and damage query share identical parameters. No retargeting an already warned shape. |
| UpgradeDefinition | `id`, `label`, `description`, `effects[]`, `required_capabilities[]`, `max_stacks` (0 means uncapped), `fallback` | Twelve specified IDs. Might/Vitality/Battle Mend always eligible together. Exactly three distinct eligible offers; never ineffective/capped choices. |
| EffectDefinition | `kind`, `stat_category`, `amount`, `duration_ticks`, `stack_policy`, `target_scope` | Small typed set for percent/flat stats, heal, extra shot/arc, burn, slow and later ability/bargain effects. Refresh durations without unintended stacking. |
| WaveSchedule | ordered phases: start/end ticks, wave interval, count, weighted enemy IDs, newly introduced IDs; cap and safe-spawn configuration | Exact specification 10-second waves 0:00–8:50; counts 4/6/8/10/12 and specified weights. No party-strength input. Weights total 100%; required introductions replace Thrall slots before safety/cap skips. |
| FieldDefinition | bounds, collision scene, edge spawn segments, forbidden overlap regions, hero footprint, spawn warning ticks, rescue radius | Initial 960×540 world-pixel rectangle; camera follows bounded hero. Fixed coordinate origin and spawn candidate ordering. Bounds remain visible on approach. |
| GachaPoolDefinition | `id`, `entries: GachaEntry[]`, `single_cost`, `batch_count`, `batch_cost`, `duplicate_tokens`, `exchange_cost` | M3 only. Brann/Nyra weight 1 each; costs 1/10 tickets, ten independent draws, duplicate 1 token, exchange 5. |
| GachaEntry | `character_id`, `integer_weight`, `display_probability` derived from weights | Positive weights; pool excludes starters/Sera; ownership never changes odds. Tests cover intervals exactly, not statistical inference alone. |
| RescueDefinition | `id`, `character_id`, `duration_ticks`, `zone_radius`, `repeat_ticket_reward` | M3: Sera, 1800 ticks, initial radius 96 pixels, one repeat ticket. Zone center equals active hero on acceptance. |
| EventDefinition | `id`, `kind`, `choices: EventChoice[]`, `rescue_definition?`, `presentation` | M4: merchant/altar/lost adventurer only. M3 rescue does not need this type. |
| EventChoice | `id`, `costs[]`, `requirements[]`, `effects[]`, `terminal_choice` | Exact specification costs: merchant 20 coins heal 25% / 30 coins Might / leave; altar 20% active max health +25 corruption for +30% damage, or +35 for +40% frequency, or decline. One choice resolves once. |
| CorruptionDefinition | `max_value`, `minute_increment`, ordered thresholds with count/damage/weight/XP/environment/boss modifiers | M4: cap 100, +5/full minute, thresholds 25/50/75/100; table below. |
| VisualSet | idle/move/attack/hurt/death animations, directional flip rules, palette, impact/telegraph references | Each state present or explicit original placeholder. No damage callbacks or gameplay cooldowns in visual assets. |

## Runtime records and lifetimes

| Record | Fields / invariant |
| --- | --- |
| RunStartSnapshot | run ID, game/engine/content version, seed 0..2147483647, hero ID, ordered companion IDs, start permanent level/class/passive snapshots (M2+). Immutable for the expedition. M1 includes only selected starter/base definition. |
| RunState | phase, active tick, seed streams, next spawn sequence, shared run level/XP, upgrade counts, pending level count, kills, actor registry, outcome. M3 adds coins/rescue state; M4 corruption/events. Never written for continuation. |
| ActorState | run actor ID/spawn order, character/enemy ID, role, position, health, effective stats, next-ready tick, invulnerable-until tick, activation counters, status map and alive/downed state. No cross-run node references. |
| DamageRequest/Result | run ID, request ID, source/target actor IDs, activation ID, base amount/category, effect snapshot, hit direction, accepted amount, resistance/death flags. Each request accepted at most once. |
| ProjectileState | source snapshot, target ID, activation ID, position/direction, created/expiry ticks, hit actor IDs, remaining pierces/bounces. Expiry is immutable; reacquisition cannot extend it. |
| LevelChoice | offer ID, earned level index, three ordered Upgrade IDs, state offered/consumed/canceled. Re-entry cannot resample; confirmed input is consumed once. |
| RunSummary | outcome, seed/start snapshot, active ticks, final run level, kills, participant IDs, rescue results and earned permanent reward preview if introduced. Frozen at terminal arbitration. |
| RunSettlement | operation ID, run ID, outcome, complete reward delta, participant IDs, committed profile revision. Abandonment has no rewards. Result re-entry never re-applies it. |
| RescueState | opportunity ID, pending/declined/defending/failed/succeeded, center/radius, elapsed ticks, owned-at-start reward route. Boundary is inside; leaving once fails; no same-opportunity restart. |
| EventState | opportunity ID, slot tick, definition ID, fixed offer, resolution state. At most one choice active. Distinct owned rescue opportunities can each earn a repeat ticket. |
| CorruptionState | value 0..100, crossed threshold set, current advantage, next-wave modifier state. Threshold changes are recomputed from total value; no repeated additive reapplication. |

## Combat math and counters

Initial precision policy: keep stats/health/damage as finite floats internally; UI displays appropriately rounded values, not authoritative values. Eligible damage is `max(1, (outgoing_damage - flat_defense) × defensive_multipliers)`, after invulnerability rejection. Enemy armor uses the same defensive multiplier stage. Burn damage is based on the attack snapshot and does not recursively trigger on-hit effects. Health clamps to [0, max]; healing cannot revive. Godot script fixtures verify fractional boundaries with an explicit tolerance.

M2 permanent starting damage/max health = current profession baseline × (1 + 0.02 × (permanent level − 1)). Run percentage bonuses add within their stated category against that starting value; attack frequency +10% means frequency ×1.1, not cooldown −10%. Cooldown is ceil(60/frequency) ticks, minimum one tick. Flat Ironhide precedes Resolute/Bastion; eligible minimum damage remains 1. Companion factor 0.5 is applied to outgoing damage after its class/permanent/passive/run modifiers, before target defenses; it never reduces healing.

Vitality adds 10% starting max health per stack and heals precisely the increase. Might adds 10% starting damage; Battle Mend heals 20% current max and adds 5% starting damage. Quick Hands/Reach/Ironhide/Magnet caps 5; Echo cap 2; Boots/Force cap 3; burn/frost once. Echo adds one full-damage projectile for ranged attacks or one 50% follow-up arc per stack. Each activation still advances counters once.

Milo's fifth activation applies ×1.5 to that activation's damage; branch fifth effects trigger independently on the same activation. Burn: 30% triggering attack damage total across three 1-second ticks; later hits refresh duration and update its source snapshot without parallel burns or resetting the next tick deadline. Frost: refresh 120 ticks at 20% slow. Status effects use no wall-clock timers and cannot recursively trigger weapon counters. Dead targets ignore later requests.

## Initial tunable combat defaults

These are design proposals for numeric values **not specified** in the spec; tune and record them before accepting the affected milestone. They do not override the spec's fixed values. The art/field assumptions use 16-pixel hero width.

| Content | Starting proposal |
| --- | --- |
| Base hero stats | Health 100; movement 96 px/s; damage 20; frequency 1/s; flat defense 0; pickup radius 24; knockback impulse 80 px/s decaying over 0.15s. |
| Swordsman | Target reach 48; 100-degree arc; all eligible enemies in arc hit once. |
| Archer / Mage | Reach 160; straight projectile speed 240 / homing speed 180 px/s; lifetime 3s. Homing steering follows target each tick. |
| Thrall | HP 30, contact damage 10, speed 36. |
| Brinejaw | HP 24, damage 12, speed 42; 0.75s warned rush at 150 px/s for 0.5s, then 1.5s recovery. |
| Cantor | HP 30, damage 10, speed 32; preferred distance 112, 0.75s warning, one straight shot every 2s. |
| Husk | HP 70, damage 15, speed 24, 25% damage reduction, knockback/slow/pull resistant with feedback. |
| Broodmother / broodling | Parent HP 50, damage 8, speed 24, summon every 6s while cap permits; child HP 10, damage 5, speed 48, XP 10. |
| Boss | HP 4000, movement 24; alternating 160px/75-degree cone (20 damage) and 40px-radius eruption (25 damage), 1s warning, 2s recovery; no contact overlap spawn. Initial eruption center locks to hero position at warning start. |
| Swordmaster | Two 20-damage baseline arcs per activation; fifth adds 48px full-circle strike at 1× damage. |
| Abyss Swordsman | Arc reach 64; fifth activation heals 2% own max once only if it deals damage. |
| Sharpshooter | Each arrow hits ≤3 distinct enemies; fifth adds three-arrow volley with 15-degree spacing. |
| Star Hunter | One ricochet per arrow; fifth marks one target for 1× impact after 0.5s; no impact if target is dead. |
| Elemental Sage | Alternate 32px fire splash at 0.5× damage and 20%/2s frost; fifth adds 48px elemental burst at 1×. |
| Void Caster | Impact zone radius 24 for 2s, ticks every 0.5s at 0.25×; fifth adds radius-48 pull zone for 2s, 30px/s pull on susceptible enemies. |

Retain every required attack/ability distinction during tuning. Specify each default in a Resource and generate previews from it, not controller literals. Revalidate run duration, every-starter victory and companion/permanent balance without strengthening enemy schedules in response.

## Persistent profile (M2+)

Save envelope: `schema_version`, `game_version`, `content_version`, `profile_id`, `revision`, `saved_at_utc`, `operation_id`, `payload_json`, `payload_sha256`. Hash exact UTF-8 payload bytes to avoid map-order ambiguity. Timestamps are display/recovery information; monotonically increasing revision determines ordering.

M2 payload: owned-hero map, last selected active/companions/seed, promotion-item balance, recent committed operation receipt. OwnedHero fields: `character_id`, total permanent XP capped at 2900, derived level `min(30, 1 + floor(total_xp/100))`, derived progress-to-next, `promotion_id?`. Validate branch ownership, cap and distinct owned party IDs; only initial creation grants all three starters. Selection saves occur on confirmation, not each keystroke.

M3 extends payload with tickets/tokens, recruitment history, persisted draw RNG seed/state (64-bit values as decimal strings to avoid JSON numeric precision loss), draw sequence index, ordered draw histories and acknowledgment state. DrawReceipt includes operation ID, pool/version, cost, ordered hero IDs, each acquisition/token result, sequence range and `awaiting_reveal`. Acknowledgment is itself a saved mutation; failed acknowledgment cannot cause recharge or reroll.

M4 adds chapter completion flags. No health, current XP/upgrades, time, enemies, coins, corruption, active rescue or pending event is serialized as a resumable expedition.

M2 schema v1 → M3 v2 (zero tickets/tokens, empty history, initialize independent draw state once) → M4 v3 (chapter false). Pure, ordered migrations produce a complete validated candidate and preserve the prior generation; never silently grant rescue/draw heroes. Unsupported newer schema or incompatible content/game versions block normal load and preserve files. All numeric JSON balances must be integral, nonnegative and within supported integer precision; reject overflow before spending/rewards.

Rewards: each participating hero (including downed companions) receives `20 × floor(active_ticks/3600) + (100 if victory else 0)` permanent XP; victory grants one shared promotion item. M3 tickets = one if active ticks ≥18000, plus two for victory, plus one per completed already-owned rescue. Successful unowned rescue grants Sera on victory or defeat. Abandonment grants nothing. At level 30 excess XP is discarded without changing other rewards. Transaction rules are in [persistence.md](contracts/persistence.md).

## Corruption/event snapshots (M4)

| Value | Wave snapshot changes | Immediate XP/environment and next boss pattern |
| --- | --- | --- |
| 0–24 | Baseline | Baseline gem value |
| 25–49 | Count ×1.10, ceil once | Gem XP ×1.10, tide marks |
| 50–74 | Same count; Broodmother baseline share +10 percentage points, Thrall −10 | Gem XP ×1.20 |
| 75–99 | Above plus future normal enemy damage ×1.15 | Gem XP ×1.30, violet shoreline |
| 100 | Count ×1.20 replaces ×1.10; other changes retained | Gem XP ×1.40, second fully warned eruption circle |

Snapshot the XP bonus when an enemy dies and creates the gem; old gems keep their stored value. Normal-enemy damage modifier includes broodlings spawned after the next wave snapshot updates. Existing enemies retain their spawn stats. Each full minute adds 5; costs must fit full headroom before applying reward. A multi-threshold jump recomputes the final total, emits each newly crossed threshold once, and does not compound count bonuses.

At minute 2/4/6, while Sera is unowned the middle slot is guaranteed rescue, others are equal merchant/altar; when owned all slots are independently equal thirds. M3 instead offers rescue at minute 4 regardless of ownership. Merchant/altar resolve one choice; active-hero health payment must leave ≥1. Rescue radius is centered at acceptance, boundary included, 30 continuous active seconds; no extra enemy escalation. Coins drop one per non-boss in M4, collect through active hero only and expire on run end.

## Passive configuration (introduced only at the owning milestone)

| Passive | Trigger and exact rule |
| --- | --- |
| Resolute (M2) | Aren receives 10% less eligible incoming damage after flat defense; minimum 1. |
| Fleet Step (M2) | Lia adds 10% starting movement speed independently of class. |
| Arcane Pulse (M2) | Every fifth fired activation has +50% damage; counts independently from branch effects. |
| Guiding Light (M3) | Every 1200 active ticks, living Sera heals the living party member with lowest health percentage for 2% of that target's max health; ties choose active hero then companion slot order. Full-health party produces no overheal; downed Sera produces no heal. |
| Bastion (M3) | First eligible damaging hit on Brann in each run-clock interval [0,1200), [1200,2400), etc. is reduced by 50% after flat defense; ignored invulnerable hits do not consume it. Pauses do not advance the interval. |
| Far Sight (M3) | Nyra adds 20% starting targeting range, independent of profession. |

All passives remain attached to character identity after promotion. Passive tie/interval policies are explicit implementation defaults for otherwise unspecified ties, not additional content.
