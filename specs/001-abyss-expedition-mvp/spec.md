# Feature Specification: Abyss Expedition — Prioritized MVP

**Feature Branch**: None; this workspace has no Git repository and no branch hook is registered.

**Created**: 2026-10-14

**Status**: Draft — quality validated; ready for Milestone 1 planning

**Input**: User brief: Create a complete, prioritized MVP for an original offline, single-player, 2D fantasy survivor-like roguelite in Aetheran, delivered through playable combat, character progression, recruitment/gacha, and Abyss systems with a first coastal chapter. No code implementation in this step.

## Clarifications

### Session 2026-10-14

- Q: Should enemy difficulty depend only on elapsed run time, or also increase with party size and permanent hero strength? → A: Fixed schedule based on active run time; party size and permanent levels do not strengthen enemies. Stated corruption modifiers still apply.
- Q: How independently should companions move and fight? → A: Stay near the player and attack enemies within reach; following takes priority over chasing.
- Q: If permanent progress cannot be saved, should the game require a successful retry before letting the player continue? → A: Require successful saving before continuing; keep the action pending, explain the failure, and offer Retry with the same rewards or draw results and no repeated charge or reroll.

## User Scenarios & Testing *(mandatory)*

The player is the sole user. Aetheran is a medieval fantasy kingdom threatened by Abyss Corruption. Players survive expeditions through movement, automatic attacks, and build choices, then develop and collect adventurers between runs. Familiarity with other games or cosmic-horror fiction is unnecessary.

Priority defines delivery order: **P1 = Milestone 1**, **P2 = Milestone 2**, **P3 = Milestone 3**, **P4 = Milestone 4**. All listed requirements are mandatory for their milestone; lower priority means later delivery, not optional inclusion. Stories can be verified separately on their stated prerequisite checkpoint and never require later milestones.

### User Story 1 - Survive a complete expedition (Priority: P1)

As a player, I want to select a hero, move around a battlefield while attacking automatically, and reach a clear ending so that the core game is enjoyable immediately.

**Why this priority**: A complete playable loop establishes the game's value before progression or collection is added.

**Independent Test**: From a fresh Milestone 1 session, select any starter and play to victory or defeat, then retry with all later systems absent.

**Acceptance Scenarios**:

1. **Given** starter selection, **When** I select Aren, Lia, or Milo and start, **Then** the hero enters a bounded top-down 2D field, moves with WASD or arrow keys, and automatically attacks nearby enemies without aiming or an attack button.
2. **Given** a living hero, **When** waves advance, **Then** all five enemy behaviors can appear, defeated enemies drop experience gems, and the final pre-boss phase has a higher spawn rate and greater enemy variety than the opening phase.
3. **Given** the boss dies while my hero lives, **When** the encounter resolves, **Then** victory ends combat and shows survival time, level, kills, and retry/selection options.
4. **Given** my health reaches zero, **When** death resolves, **Then** defeat shows the same summary and restart options; retry starts a fresh run without temporary upgrades.
5. **Given** a paused run, **When** I wait or open a choice screen, **Then** movement, attacks, enemies, damage, pickups, and elapsed run time remain frozen until resuming.

---

### User Story 2 - Choose a distinct hero and build (Priority: P1)

As a player, I want different attacks and useful random upgrades so that movement and build decisions change between runs.

**Why this priority**: Character and build variety make the basic survivor loop replayable.

**Independent Test**: Using Milestone 1, repeat a controlled encounter with all starters and exercise level-up choices without permanent progression.

**Acceptance Scenarios**:

1. **Given** identical enemy positions, **When** each starter attacks, **Then** Aren damages a close arc, Lia fires a straight ranged projectile, and Milo's projectile changes direction to track its target.
2. **Given** enough experience for a level, **When** the choice screen opens, **Then** exactly three distinct eligible upgrades display their effects while gameplay pauses; selecting one applies it once and resumes unless another level is pending.
3. **Given** the upgrade catalog, **When** choices are reviewed, **Then** at least twelve entries cover damage, attack speed, range, projectiles/attack count, defense, and special effects, with no ineffective class-incompatible choices.
4. **Given** a hit, **When** it resolves, **Then** health changes consistently, impact feedback is visible, susceptible targets are knocked back, and hero invulnerability prevents repeated damage during its stated duration.

---

### User Story 3 - Read danger and replay an expedition (Priority: P1)

As a player, I want readable combat information and a recorded seed so that I can understand deaths and repeat an expedition.

**Why this priority**: Readability supports fair combat; reproducibility supports balancing and verification.

**Independent Test**: Enter a seed and repeat a timed sequence twice from identical starting conditions on Milestone 1.

**Acceptance Scenarios**:

1. **Given** combat, **When** I inspect the HUD, **Then** health, experience to next level, run level, and elapsed active time are visible and distinguishable.
2. **Given** a boss attack, **When** its warning starts, **Then** its threatened area/direction are visible before damage, and leaving that area avoids the attack.
3. **Given** matching seed, game version, hero, starting progression/party, and timed player decisions, **When** I repeat a run, **Then** random waves, upgrade offers, and applicable later events repeat. Different decisions can produce different outcomes.
4. **Given** a result screen, **When** I retry, **Then** the prior seed is reused and displayed; New Expedition generates a new seed. Seed replay never resets permanent rewards or guarantees identical results after progression changes.

---

### User Story 4 - Grow and promote an adventurer (Priority: P2)

As a player, I want permanent levels and a meaningful class branch so that repeated expeditions develop my heroes.

**Why this priority**: Progression adds a reason to return after the combat loop is accepted.

**Independent Test**: On accepted Milestone 1 combat, use starter records and promotion items to exercise levels 1, 14, 15, and 30 without recruitment or corruption.

**Acceptance Scenarios**:

1. **Given** an owned hero, **When** I finish a run and reopen the game, **Then** permanent experience/level remain, while the next expedition starts at run level 1 without prior run upgrades.
2. **Given** an unpromoted level-15 hero and one promotion item, **When** I preview both branches and confirm one, **Then** one item is consumed, class choice is permanent, attack behavior/abilities/visual identity change, and the hero passive remains.
3. **Given** level 14, no item, or an already promoted hero, **When** I attempt promotion, **Then** it is unavailable with a reason and consumes nothing.
4. **Given** level 30, **When** further permanent experience is earned, **Then** level remains 30 and the result reports the cap.

---

### User Story 5 - Travel with companions (Priority: P2)

As a player, I want up to two companions to follow and fight automatically so that parties offer variety without extra controls.

**Why this priority**: Parties extend accepted combat and roster systems while preserving simple play.

**Independent Test**: Start the same encounter with zero, one, and two owned starter companions on Milestone 2.

**Acceptance Scenarios**:

1. **Given** the roster, **When** I choose one active hero and zero to two distinct companions, **Then** roles are shown and duplicate/unowned selections are rejected.
2. **Given** companions, **When** I move and enemies approach, **Then** companions follow and attack with their classes/passives and recover from separation without commands.
3. **Given** a companion reaches zero health, **When** combat continues, **Then** it stops contributing until the next run while the active hero can still win.
4. **Given** the active hero dies while companions live, **When** death resolves, **Then** defeat ends the run without swapping control.

---

### User Story 6 - Rescue and collect heroes at the guild (Priority: P3)

As a player, I want an understandable guild and reliable rescue path so that collecting heroes is achievable through play.

**Why this priority**: Collection builds on functioning combat, ownership, and progression.

**Independent Test**: On Milestone 3, trigger Sera's guaranteed rescue, resolve it, and reopen the guild without the generic Milestone 4 event system.

**Acceptance Scenarios**:

1. **Given** a new profile, **When** I open the guild, **Then** Aren, Lia, and Milo are owned and playable, while Sera, Brann, and Nyra show acquisition routes.
2. **Given** Sera is unowned, **When** I reach four minutes and survive her accepted 30-second rescue, **Then** recruitment is earned and credited on victory or defeat settlement.
3. **Given** a declined or failed rescue, **When** I start another expedition, **Then** the rescue opportunity returns without requiring a random draw.
4. **Given** Sera is owned, **When** I finish another offered rescue, **Then** the stated repeat reward replaces duplicate ownership.

---

### User Story 7 - Spend earned tickets on transparent draws (Priority: P3)

As a player, I want explicit odds, safe spending, and useful duplicates so that recruitment is understandable and fair.

**Why this priority**: Gacha is a later, small collection mechanism using gameplay resources exclusively.

**Independent Test**: Exercise controlled draws with 0/1/9/10 tickets, mixed ownership, repeated results, and interrupted reveals on Milestone 3.

**Acceptance Scenarios**:

1. **Given** recruitment, **When** I inspect the pool, **Then** Brann and Nyra each show 50% per-draw probability, totaling 100%, with costs of one or ten tickets.
2. **Given** ten tickets and neither hero owned, **When** a controlled batch contains repeated Brann/Nyra outcomes, **Then** each hero is acquired once, each later occurrence gives one token, ten tickets are spent once, and all ten results remain reviewable.
3. **Given** insufficient tickets, **When** I attempt a draw, **Then** no resources/ownership change and the missing amount is shown.
4. **Given** a committed draw interrupted before reveal, **When** I reopen, **Then** its original outcomes/rewards remain available without recharging or rerolling.
5. **Given** five tokens and an unowned pool hero, **When** I confirm exchange, **Then** that hero is acquired and five tokens consumed once, providing a finite collection path without a pity counter.

---

### User Story 8 - Make an eldritch bargain (Priority: P4)

As a player, I want visible corruption risks and benefits so that forbidden power creates a meaningful build decision.

**Why this priority**: Corruption varies a proven combat and event experience.

**Independent Test**: Compare known encounters at corruption 0/25/50/75/100, then accept/decline a known bargain on Milestone 4.

**Acceptance Scenarios**:

1. **Given** a fresh expedition, **When** it starts, **Then** corruption is 0 and its 0–100 meter is visible; permanent class does not silently alter it.
2. **Given** an altar, **When** I inspect choices, **Then** exact corruption costs/rewards appear before confirmation; decline changes neither.
3. **Given** a crossed threshold, **When** the next wave begins, **Then** advertised enemy changes apply and the associated advantage is visible; each threshold applies once.
4. **Given** corruption 100, **When** I inspect a corruption-increasing bargain, **Then** it is unavailable with a reason; reaching the cap alone does not cause unexplained death.

---

### User Story 9 - Finish the corrupted coast chapter (Priority: P4)

As a player, I want distinctive coastal events and an ocean-cult boss so that expeditions form a memorable first chapter.

**Why this priority**: Chapter identity and event variety complete the MVP after core systems are stable.

**Independent Test**: Play fixed-seed coast runs exercising all event types/boss patterns, then compare different seeds for variation.

**Acceptance Scenarios**:

1. **Given** a coastal expedition, **When** event opportunities occur, **Then** Mysterious Merchant, Forbidden Altar, and Lost Adventurer can appear with readable choices and stated costs/rewards.
2. **Given** an event, **When** I dismiss or resolve it, **Then** combat resumes without hidden deductions or overlapping choice screens.
3. **Given** I reach the boss, **When** I defeat the Tidebound Hierophant, **Then** victory marks Chapter 1 complete and repeat expeditions remain available.
4. **Given** distinct seeds, **When** I compare ten coast runs, **Then** at least three ordered event-offer sequences occur while Sera's unowned rescue remains guaranteed.

### Edge Cases

| Case | Required behavior |
| --- | --- |
| Opposing/diagonal inputs | Opposing inputs cancel on that axis; diagonal movement is no faster than straight movement. Field edges cannot be crossed. |
| No target; homing target dies | Movement remains usable. Homing shot reacquires an in-range target or expires; it cannot chase indefinitely. |
| Many hits during invulnerability | Only the initial eligible hit reduces health; later hits neither damage nor refresh invulnerability indefinitely. |
| Multiple levels earned together | Preserve overflow; serialize one paused choice screen per earned level. |
| Exhausted or incompatible upgrades | Exclude incompatible/capped entries; three distinct uncapped fallback choices remain eligible. |
| Boss and active hero die together | Defeat takes precedence; settle one terminal result once. Boss-only death with a living hero is victory. |
| Overlapping pause, choice, and ending | Serialize choices; terminal outcomes cancel pending choices. Closing one screen cannot resume while another pause reason remains. |
| Closing or abandoning mid-run | Abandon the expedition; grant no uncommitted run rewards. Preserve previously settled progression/draws. Full mid-run continuation is excluded. |
| Invalid seed or changed party/progression | Reject invalid input with accepted limits; disclose changed replay conditions. Seed replay never rewinds progress. |
| Canceled/repeated promotion | Cancel consumes nothing; repeated confirmation cannot spend twice. Unowned heroes cannot promote; no promotion reversal. |
| Multiple permanent levels; cap | Carry experience through levels up to 30; discard overflow at cap without altering other rewards. |
| Blocked/separated/downed companion | Living companions catch up safely; downed companions return healthy next run and remain owned. |
| Rescue declined, death during defense, or leaving zone | No recruitment; clearly report failure and offer rescue next run. |
| Rescue success followed by defeat; repeated rescue | Completed rescue is earned on defeat settlement; owned Sera gives the stated repeat reward rather than another ownership entry. |
| Repeated hero within one draw batch | Resolve in display order: first unowned occurrence grants ownership; later occurrences give tokens. |
| Repeated spending input; insufficient resources | One action settles once; no negative balances, partial spending, or duplicate ownership. |
| Interruption during permanent settlement | Preserve either the complete prior state or complete settled state; no paid draw without its outcome or duplicated rewards. |
| Unreadable/corrupt progress | Explain recovery and offer last valid saved state where available; never silently replace existing progress with a new profile. |
| Corruption bounds or multi-threshold jump | Clamp to 0–100; apply crossed thresholds once. Reject unaffordable full bargain costs before granting rewards. |
| Unaffordable merchant; event/boss collision | Leave remains available; resolve/dismiss an existing event before boss entry. No event begins during the boss. |

## Requirements *(mandatory)*

### Functional Requirements

Every row specifies mandatory behavior and its observable acceptance check. The content tables are part of their cited requirement, not optional examples.

#### Milestone 1 — Playable Combat (P1; first active planning scope)

| ID | Requirement | Acceptance check |
| --- | --- | --- |
| FR-001 | The game MUST run offline as single-player with a bounded top-down 2D field and starter selection. | Finish an expedition without networking; all three starters are selectable. |
| FR-002 | Movement MUST support WASD/arrows, equal diagonal/straight speed, immediate release response, and visible boundaries. | Hold/combine/release both key sets; movement stops consistently and cannot cross the field edge. |
| FR-003 | Attacks MUST automatically target nearby valid enemies; starters MUST follow the catalog below. | Observe all three distinct attacks in the same encounter without manual targeting. |
| FR-004 | Waves MUST follow a fixed schedule based on active run time, escalate over that time, and contain at least the five enemy behaviors below. Party size, permanent levels, promotions, run upgrades, kills, and player performance MUST NOT increase enemy counts, stats, or boss strength; stated corruption modifiers still apply. | Every two-minute pre-boss phase increases spawn rate or adds harder behavior; all five appear and the final phase's rate exceeds the opening rate. Compare the same schedule/corruption with solo and full parties at different permanent levels: spawn rates, enemy stats, and boss strength remain equal. |
| FR-005 | Every defeated non-boss enemy MUST drop experience gems; collecting MUST advance experience with overflow retained. | Kill/collect and verify visible progress, including multiple levels from one pickup. |
| FR-006 | Runs MUST start at run level 1. Every level-up MUST pause gameplay and offer exactly three distinct eligible random upgrades with effect previews; one selection applies once. | No combat/clock progress during choices; chained levels resolve in order. |
| FR-007 | There MUST be at least twelve upgrades covering damage, attack speed, range, projectiles/attack count, defense, and special effects, using the catalog below. | Count twelve entries; no class receives a choice with no applicable effect. |
| FR-008 | Combat MUST support health, damage, knockback for susceptible enemies and the active hero, 0.75 active seconds of visible hero invulnerability after damage, and death at zero health. | Controlled hits damage once per eligible hit; additional hits within the interval cause no damage. |
| FR-009 | One boss MUST arrive at 9:00 active time; winning MUST require its defeat while the active hero lives. At least two attacks MUST warn for at least 0.75 seconds before damage. | Observe both patterns; moving clear avoids damage; boss knockback resistance is visibly indicated. |
| FR-010 | Victory, defeat, pause/resume, retry, and starter-selection screens/paths MUST be clear and usable. | Exercise each path without restarting the application. |
| FR-011 | HUD MUST show current/max health, experience to next run level, run level, and elapsed active time. | Values match hits, pickups, levels, and pauses. |
| FR-012 | Each run MUST accept/display an explicit seed and generate one if omitted; matching seed/conditions/decisions MUST reproduce random outcomes within one game version. | Repeat controlled runs; display seed before starting and on results. |
| FR-013 | Readable colorful fantasy pixel art and feedback MUST distinguish attacks, impacts, invulnerability, danger warnings, and death through shape/animation as well as color; combat text MUST remain minimal. | Identify hero, health state, incoming danger, and hit direction during a dense encounter; choices/status remain legible. |
| FR-014 | Milestone 1 MUST work with fixed starter access and no persistent progression, companions, guild, gacha, corruption, or events. | Verify Stories 1–3 with Milestones 2–4 absent, including victory and retry. |

**Starter catalog (FR-003; unique passives become mandatory in Milestone 2):**

**Targeting defaults (FR-003):** At each ready attack, choose the nearest living, damageable enemy within the attacker's current targeting range, measured between centers; equal distances use earliest spawn order. Bosses have no targeting priority. Each companion selects from its own position. With no valid target, hold the ready attack without advancing attack counters; fire when a target becomes valid, without accumulating extra attacks. Melee faces that target; straight shots keep their firing direction. Homing shots retain their target while valid and within targeting range of the shot, otherwise reacquire the nearest valid enemy within that range using the same tie rule; expire immediately if none exists. Every projectile also has a finite lifetime that retargeting never refreshes; the initial default is three active seconds.

| Hero | Base class | Attack and positioning | Unique passive |
| --- | --- | --- | --- |
| Aren | Swordsman | Short arc toward the nearest enemy; positioning can hit several enemies in the arc | Resolute: 10% less incoming damage. |
| Lia | Archer | Straight projectile toward the nearest enemy at firing time; align shots against moving targets | Fleet Step: +10% movement speed. |
| Milo | Mage | Homing magic projectile; keep targets in targeting range | Arcane Pulse: every fifth attack deals +50% damage. |

**Initial upgrade catalog (FR-007):** Percentage modifiers use the current class's starting values and add within each category. Flat defense never reduces an eligible hit below 1 damage. Healing never exceeds maximum health.

| Upgrade | Stated effect | Eligibility / limit |
| --- | --- | --- |
| Might | +10% attack damage | Every class; uncapped fallback. |
| Quick Hands | +10% attack frequency | Every class; five selections. |
| Reach | +15% attack reach/targeting range | Every class; five selections. |
| Echo Strike | One extra projectile, or one follow-up melee arc at 50% damage | Every class; two selections. |
| Ironhide | Reduce incoming hit damage by 1 | Every class; five selections. |
| Vitality | +10% starting maximum health; heal that added amount | Every class; uncapped fallback. |
| Swift Boots | +10% movement speed | Every class; three selections. |
| Magnet | +25% gem pickup radius | Every class; five selections. |
| Force | +20% knockback strength on susceptible enemies | Every class; three selections. |
| Ember Touch | First hit burns for 30% attack damage over three seconds; later hits refresh duration without stacking burns | Every class; once. |
| Frost Mark | Hits slow susceptible enemies by 20% for two seconds; later hits refresh duration | Every class; once. |
| Battle Mend | Heal 20% current maximum health immediately; +5% attack damage even at full health | Every class; uncapped fallback. |

Might, Vitality, and Battle Mend remain available together after capped choices are exhausted, preserving three distinct useful offers. All upgrades expire at run end. Applicable choices affect companions once introduced. Initial run experience defaults: normal enemies drop gems worth 10 experience; the next run level requires 100 × current run level experience. Corruption experience bonuses apply to gem value.

**Level-up pause defaults (FR-006, FR-010, FR-039):** Collecting enough experience queues each earned level and freezes the world before the next gameplay update. Movement, projectiles, damage over time, attack cooldowns, invulnerability, enemy AI/spawns, pickups, rescue timers, passive timers, corruption ticks, and active run time all stop. Choice navigation remains usable. Offers are sampled uniformly without replacement from eligible entries for that level, stay unchanged while displayed, and cannot be skipped or rerolled. Apply one confirmed upgrade to the living party, then generate the next queued level's offers using the updated eligibility; capped choices cannot reappear. No gameplay update occurs between queued choices. Priority is terminal result, earned level-up choices, pending event choice, then boss entry; a manual pause remains in force until explicitly resumed. Escape cannot dismiss an unchosen upgrade, and the confirming input cannot select the next screen's choice. Resume from the frozen state without advancing timers to compensate for paused wall-clock time.

**Minimum enemy catalog (FR-004):** Names/designs are original; placeholder art must preserve behavior readability.

| Enemy | Distinct behavior | Readable response |
| --- | --- | --- |
| Saltbound Thrall | Slow continuous pursuit with contact damage | Move out of contact range. |
| Skittering Brinejaw | Visible wind-up, then straight rush | Sidestep the committed rush. |
| Lantern Cantor | Maintains distance and fires a warned straight projectile | Dodge or close the gap. |
| Shellbound Husk | Slow armored advance, taking reduced damage compared with other enemies | Commit more attacks or evade while clearing weaker foes. |
| Reef Broodmother | Pauses periodically to spawn frail pursuing broodlings; at most three living broodlings per mother | Defeat the parent before it rebuilds its group. |

**Initial spawn defaults (FR-004):** Normal waves occur every ten active seconds, starting at 0:00 and ending at 8:50. Counts and baseline type weights follow this fixed schedule; each wave's type selections and positions use the expedition seed. The first wave of each phase MUST include every newly introduced type at least once, replacing a Thrall slot as needed, so all five behaviors are encountered without relying on chance. Health, damage, and movement speed for each enemy type remain fixed throughout the run except for explicit corruption effects; later phases increase pressure through counts and composition.

| Active time | Enemies per wave | Thrall | Brinejaw | Cantor | Husk | Broodmother |
| --- | --- | --- | --- | --- | --- | --- |
| 0:00–1:59 | 4 | 100% | 0% | 0% | 0% | 0% |
| 2:00–3:59 | 6 | 70% | 30% | 0% | 0% | 0% |
| 4:00–5:59 | 8 | 50% | 25% | 25% | 0% | 0% |
| 6:00–7:59 | 10 | 40% | 20% | 20% | 20% | 0% |
| 8:00–8:59 | 12 | 30% | 20% | 20% | 20% | 10% |

Corruption modifies the scheduled count (round up after applying the total bonus) and weights as already stated; its Broodmother share can introduce that type earlier. At most 100 living non-boss enemies, including broodlings, may exist. Unfilled spawn slots at the cap are discarded, never accumulated into a later burst. Normal enemies appear at seeded walkable field-edge positions at least six hero widths from every living party member, with a visible 0.75-active-second warning before becoming active; if no safe position exists, skip that slot. Spawning never pushes a party member or creates contact damage underneath one. Broodlings appear beside their mother with the same warning and no party overlap. At 9:00, stop normal waves and further broodling creation; existing enemies remain, and the boss enters with a warning at a safe non-overlapping position. Acceptance compares the scheduled pressure before capacity/safety skips; these skips depend on battlefield occupancy and do not adapt difficulty to player strength.

**Run outcome contract (FR-009–FR-010):** The initial boss is the Tidebound Hierophant, an original ocean-cult leader; Milestone 4 adds chapter presentation/corruption interactions to the same encounter. Its minimum patterns are a warned cone blast and warned ground-eruption circles. Normal spawning stops at boss arrival; existing enemies remain. Boss defeat with the active hero alive is **victory** regardless of elapsed time. Active-hero death is **defeat**; simultaneous hero/boss death is defeat. Confirmed abandonment or closing mid-run yields **abandonment**, never victory. There is no timed automatic victory or timeout defeat. Boss arrival at 9:00 targets successful runs of 9–11 minutes. Pauses/choices exclude elapsed active time. Results freeze combat, settle rewards once, and show outcome, hero/party, seed, time, run level, kills, and applicable permanent rewards. Milestone 1 grants no permanent rewards. Retry reuses the seed; New Expedition generates a new one.

#### Milestone 2 — Character Progression (P2; gated on accepted Milestone 1)

| ID | Requirement | Acceptance check |
| --- | --- | --- |
| FR-015 | Roster MUST show owned heroes, permanent experience/level, base/current class, unique passive, promotion eligibility, and active/companion selections. | Review starters and launch valid solo/party selections. |
| FR-016 | Owned heroes MUST have permanent levels 1–30, requiring 100 permanent experience per level and gaining +2% starting damage/max health per level above 1. | Verify threshold, overflow, cumulative bonuses, and cap independently of run level. |
| FR-017 | Non-abandoned settled runs MUST give each participating owned hero 20 permanent experience per full active minute plus 100 on victory; victory MUST grant one shared promotion item. | Compare same-duration victory/defeat, including downed companions; grant exact rewards once. |
| FR-018 | Owned unpromoted heroes at permanent level 15+ MUST be able to spend one shared promotion item on either base-class branch after preview/confirmation. | Verify levels 14/15, items 0/1, cancellation, and exact consumption. |
| FR-019 | All six branches below MUST alter attack behavior, an automatic ability/effect, and visual identity, preserving permanent level and hero passive. | Compare base/branches in identical encounters and verify passive continuity. |
| FR-020 | Every available hero MUST have a unique passive independent of class: the three starters in Milestone 2 and all six heroes when Milestone 3 adds recruits. | Verify each passive before/after promotion; unavailable recruits are unnecessary for Milestone 2 acceptance. |
| FR-021 | Party MUST contain one active owned hero and zero to two other distinct owned heroes; companions MUST stay near the active hero and attack enemies within their own reach automatically. Following MUST take priority over pursuing targets; companions MUST NOT leave formation to chase enemies. | Reject duplicates, locked heroes, and a third companion; observe following/attacking without commands. Move away from an enemy: companions follow instead of pursuing it. |
| FR-022 | Companions MUST use class, passive, permanent bonuses, and applicable shared upgrades at 50% corresponding active-hero outgoing damage, with separate health and inactivity at zero until next run. | Compare damage/upgrades; exercise separation recovery, downing, and next-run restoration. |
| FR-023 | Ownership, permanent levels/experience, promotions, and items MUST persist locally between sessions, separate from temporary state. All permanent actions MUST obey the save/load contract below; saving failure MUST block further play and spending until Retry succeeds. | Reopen after settlement/promotion; next run begins full-health at run level 1 without prior upgrades. Fail a save, retry, and verify one unchanged action settles exactly once before continuation is enabled. |

**Promotion catalog (FR-019):** Abilities are automatic. Cooldowns/effect strengths not specified below and art conventions are later balancing decisions subject to these observable behaviors.

| Base → Branch | Changed attack | Automatic ability/effect | Visual identity |
| --- | --- | --- | --- |
| Swordsman → Swordmaster | Two close arcs replace one | Every fifth attack spins to hit surrounding enemies | Twin blades and bright circular slash. |
| Swordsman → Abyss Swordsman | Longer spectral arc through clustered enemies | Every fifth attack heals 2% maximum health if it damages an enemy | Dark blade and violet spectral trail. |
| Archer → Sharpshooter | Straight arrows pierce up to three enemies | Every fifth attack fires a broad three-arrow volley | Longbow and narrow gold trails. |
| Archer → Star Hunter | Arrows ricochet once to a nearby second enemy | Every fifth attack marks a target for one delayed star impact | Star-tipped bow and blue star impacts. |
| Mage → Elemental Sage | Homing shots alternate fire splash and frost slow | Every fifth attack releases a larger elemental burst | Tri-color mantle and distinct flame/ice shapes. |
| Mage → Void Caster | Homing impacts leave brief damaging zones | Every fifth attack creates a short-lived pull zone on susceptible enemies | Ringed staff and violet ring zones. |

Each hero can choose either branch of its base class. There is no further tier or respec. Abyss-themed classes work without Milestone 4 corruption.

**Promotion defaults (FR-019):** Every-fifth-attack effects count attack activations that actually fire, not individual arcs, projectiles, targets hit, or damage ticks. Counters are per hero and reset each expedition. The fifth activation adds its listed effect once alongside the branch's regular attack; Milo's independent fifth-attack passive also applies when due. The two Swordmaster arcs belong to one activation. Piercing hits at most three distinct enemies per arrow; ricochet requires a different living second target within targeting range of the first impact and ends if none exists. Healing requires an actual damaging hit and never revives. Promotion previews state these mechanical differences and the permanent branch choice; remaining numeric strengths/durations are balancing values to define before Milestone 2 implementation.

**Companion defaults (FR-021–FR-022):** Living companions aim for distinct positions within two hero widths of the active hero, move at least as fast as that hero when following, and attack from those positions without pursuing enemies. They do not block party movement or deliberately dodge attack warnings. If blocked for two active seconds or separated by more than eight hero widths, relocate to a nearby walkable position without enemy overlap, preserving health, cooldowns, and downed state; if none is safe, retry rather than teleport into damage. Separate health uses the same class/permanent maximum-health rules and 0.75-second post-hit invulnerability as an active hero. The 50% damage multiplier applies after their own class, permanent, passive, and run damage modifiers; it does not halve healing or defensive benefits. Only the active hero collects gems/coins; those pickups advance the shared run experience/balance. Companions gain all applicable shared upgrade effects, including healing, only while living; downed companions remain inactive for the rest of the run.

**Progression boundary (FR-016–FR-023):** Run level, gem experience, upgrades, health, kills, time, coins, events, and corruption reset each expedition. Ownership, permanent experience/level, promotion, items, tickets, tokens, recruitment history, and chapter completion persist as their milestones introduce them. Participating companions gain the same permanent experience as the active hero, even if downed; unselected heroes gain none. New recruits begin at permanent level 1 and become selectable next run, never join the current party. Defeat grants its defined earned rewards; abandonment grants none of the unfinished run's rewards.

**Save/load contract (FR-023, FR-033; effective from Milestone 2):** Load the one local profile before allowing permanent actions. Persist initial profile creation, party/seed selection changes, run settlements, promotions, exchanges, and committed draws when they occur; quitting is not the only save point. Temporary expedition state is never resumed. A permanent action is complete only when its complete cost and outcome have been saved together. If saving fails, keep the original pending action/results in the current session, freeze continuation and spending, show the error, and offer Retry. Retry saves that same action once, without regenerating draws or rewards. Closing while saving remains unsuccessful warns that pending progress may be lost; reopening recovers either the complete prior saved state or the complete committed action, never a partially applied cost/reward. This is not a promise to recover an action that could not be written.

Keep at least one previously validated recovery state when replacing valid progress. If the current state is corrupt or unreadable, preserve it, explain the problem, and offer the latest valid recovery state with its save time and potential lost recent progress before restoring it. If no valid state exists, offer retry loading or an explicitly confirmed new profile; never reset silently or merge partial balances/ownership. A save from an unsupported newer game version is preserved and reported as incompatible, rather than treated as a fresh profile. A successful load returns to selection/the guild, or to original committed draw results awaiting reveal; opening those results never spends again. Acceptance covers failed saving followed by repeated Retry, closing before/after commitment, corrupt current state with a valid recovery state, no valid recovery state, and incompatible versions.

#### Milestone 3 — Recruitment and Gacha (P3; gated on accepted Milestone 2)

| ID | Requirement | Acceptance check |
| --- | --- | --- |
| FR-024 | Guild hub MUST provide expedition launch, roster/party selection, promotion, rescue status, recruitment draws, and visible permanent balances. | Reach each action and return to hub without hidden navigation or networking. |
| FR-025 | Complete MVP MUST contain exactly six collectible heroes: Aren, Lia, Milo, Sera, Brann, Nyra; starters MUST be owned on a fresh profile. | Compare fresh and fully collected rosters with the catalogs. |
| FR-026 | Sera MUST have a clear repeatable story rescue offered at minute 4 every expedition while unowned, and MUST never be in a draw pool. | Retry failed/declined rescues with different seeds; inspect the pool. |
| FR-027 | Rescue MUST pause for accept/decline, then require a living active hero to remain within a marked zone for 30 continuous active seconds while defending. Success MUST earn Sera on victory/defeat settlement. | Verify success, leaving, death, decline, and later defeat; no generic event system required. |
| FR-028 | Settled runs MUST award one ticket for at least five full active minutes and two additional tickets for victory. Successful already-owned Sera rescue MUST give one additional ticket instead of ownership. | Verify 4:59/5:00, defeat/victory, repeated rescue, abandonment, and no duplicate settlement. |
| FR-029 | Single/ten pulls MUST cost one/ten tickets without discount/bonus and require sufficient balance before any change. | Exercise 0/1/9/10 tickets, cancel, repeated input, and ten ordered results. |
| FR-030 | Pool MUST be Brann 50% / Nyra 50%, independent per draw with unchanged odds displayed before spending. No money, premium currency, paid tickets, or pity system MUST be introduced. | Display totals 100%; ownership does not change odds; only earned tickets can be spent. |
| FR-031 | First unowned occurrence MUST acquire that hero once; every owned occurrence MUST convert to one shared token, including in-batch duplicates. | Verify controlled all-Brann, all-Nyra, and alternating batches. |
| FR-032 | Five tokens MUST exchange for either unowned pool hero after preview/confirmation; owned heroes MUST be unavailable. | Verify exact consumption, four tokens, cancel, and owned selection. |
| FR-033 | Ownership, tickets, tokens, recruitment history, and committed draw outcomes MUST persist; spending/rewards MUST settle together once, surviving interrupted reveal. | Reopen before/after settlement and review the same outcome without recharge/reroll/reward duplication. |
| FR-034 | Draw outcomes MUST be reproducibly verifiable with controlled random inputs, pool boundaries, batch ordering, ownership, and duplicate conversion. Expedition seeds MUST NOT reset/select permanent draw outcomes. | Verify equal-probability boundary and all ownership cases; retry/reopening cannot change a committed result. |

**Additional hero catalog (FR-020, FR-025):**

| Hero | Base class | Original identity and unique passive | Acquisition |
| --- | --- | --- | --- |
| Sera | Mage | Coastal ward-keeper; Guiding Light: every 20 active seconds heal the living party member with lowest health percentage for 2% of their maximum health | Guaranteed repeatable rescue. |
| Brann | Swordsman | Former harbor sentinel; Bastion: first eligible hit on Brann in each 20-second active interval is reduced by 50% | Draw or five-token exchange. |
| Nyra | Archer | Astral chart-maker; Far Sight: +20% targeting range | Draw or five-token exchange. |

Passives combine with class/run effects. Sera cannot revive downed heroes. Resolute/Bastion reduce damage after flat defense, with an eligible-hit minimum of 1. Tickets only buy draws; tokens only exchange for the two pool heroes. Excess tokens remain visible after full collection without expanding the roster or adding spending systems. Until Milestone 4 random events arrive, minute 4 offers Sera's rescue even when already owned, for its repeat ticket reward.

#### Milestone 4 — Abyss System and First Chapter (P4; gated on accepted Milestone 3)

| ID | Requirement | Acceptance check |
| --- | --- | --- |
| FR-035 | Corruption MUST be visible at 0–100, start at 0, rise by 5 each full active minute, and change by stated bargain costs. | Verify pause-free minute ticks, one-time costs, and bounds. |
| FR-036 | Thresholds 25/50/75/100 MUST produce the advertised dangers/advantages below; summaries MUST remain accessible. | Verify exact boundaries, multiple crossings, enemy phase changes, and gem bonuses. |
| FR-037 | Optional bargains MUST preview exact costs/corruption/current-run rewards; decline MUST be free. | Verify each choice and insufficient-health/headroom cases against stated effects. |
| FR-038 | Coast MUST support Mysterious Merchant, Forbidden Altar, and Lost Adventurer choices below. Non-guaranteed offers MUST be seeded and vary across runs. | Exercise every choice and reproduce offers from matching conditions/seeds. |
| FR-039 | Choice screens MUST pause combat, use short readable text, state consequences, and serialize with level-ups/boss entry; only one event resolves at a time. | Verify no time leakage, duplicate spending, or stacked dialogs at collisions. |
| FR-040 | Chapter 1 MUST show Aetheran's corrupted coast with original ocean-cult, amphibious, and eldritch designs in colorful readable fantasy pixel art. | Review coast, five enemy silhouettes, and boss for distinct original identities; brief setting context appears outside combat. |
| FR-041 | Tidebound Hierophant MUST be the ancient ocean cult's chapter boss; victory MUST persist chapter completion and permit unlimited repeats. | Win/reopen/replay; previous completion never bypasses the boss victory requirement. |
| FR-042 | Full MVP MUST preserve earlier flows and provide useful corruption advantages alongside danger. | Repeat earlier scenarios and compare low/high-corruption combat and rewards. |

**Corruption thresholds (FR-035–FR-036):** Effects accumulate. Enemy phase modifiers start with the next scheduled wave; environmental warnings/experience bonuses start immediately. Changes cannot remove movement or create unavoidable damage.

| Corruption | Danger / environment | Advantage |
| --- | --- | --- |
| 0–24 | Baseline coast | Baseline gem experience. |
| 25 | Visible corrupted tide marks; future normal waves spawn 10% more enemies | +10% gem experience. |
| 50 | More Broodmother spawns; safe ground stays visible | Total gem bonus +20%. |
| 75 | Stronger violet shoreline glow; future normal enemy attack damage +15% | Total gem bonus +30%. |
| 100 | Future normal wave spawn bonus becomes +20%; boss eruption adds a second warned circle | Total gem bonus +40%. |

At 50+, Broodmother's share increases ten percentage points from that phase's baseline mix, replacing Thrall spawns within the same total. The boss's added circle retains the minimum 0.75-second warning. Corruption alone never causes defeat.

**Event contract (FR-037–FR-039):** Opportunities occur at active minutes 2, 4, and 6; none starts during the boss. While Sera is unowned, minute 4 is her sole rescue opportunity, and minutes 2 and 6 choose Merchant or Altar with equal probability by seed. After Sera is owned, all three slots independently choose among the three event types with equal probability by seed. Milestone 3 implements rescue alone; Milestone 4 incorporates it into this schedule. This identified scheduling change does not remove Sera's guaranteed unowned rescue or owned-rescue reward.

| Event | Choices and exact initial consequences |
| --- | --- |
| Mysterious Merchant | Normal enemies now drop one temporary coin alongside gems. Spend 20 coins to heal 25% maximum health, spend 30 for one Might upgrade, or Leave. Unaffordable offers are unavailable; purchases add no corruption. |
| Forbidden Altar | Blood Tithe: lose 20% maximum health and gain +25 corruption for +30% attack damage. Unbound Assault: +35 corruption for +40% attack frequency. Or Decline. Bonuses affect the living party for this run. Blood Tithe is unavailable if it would leave the active hero below 1 health; either offer is unavailable if its full corruption cost exceeds 100. |
| Lost Adventurer | If Sera is unowned, accept/decline her 30-second rescue. If owned, accept the same defense conditions for one additional settled ticket, or Leave. Never award duplicate Sera or tokens. |

Rescue displays its zone/timer; leaving fails it, and enemies remain dodgeable within the zone. Success is announced immediately but credited on run settlement. Merchant healing applies to the active hero; Might and altar bonuses apply to the living party. Each merchant/altar resolves at most one chosen offer before closing. Event effects/coins expire at run end except explicit settled recruitment/tickets. Run coins never buy permanent tickets.

**Rescue/reward defaults (FR-026–FR-028):** Center the marked rescue zone on the active hero when accepted so acceptance cannot instantly fail. Count the active hero's center on the boundary as inside; crossing outside fails immediately, with no timer reset or same-run retry for that opportunity. Pauses freeze the defense timer. Rescue adds no separate wave escalation; scheduled enemies remain active. A failure/decline cannot remove the guaranteed minute-4 offer next run. The five-minute survival ticket is awarded once per settled run, not once per five-minute interval; victory therefore yields three base tickets, plus one additional ticket per successful already-owned rescue. Abandonment yields none. Draw probabilities, duplicate tokens, and five-token exchanges remain as specified, independent of expedition seeds and ownership.

#### Delivery Scope and Dependencies

| Checkpoint | Required prerequisites | Exit gate | Next planning scope |
| --- | --- | --- | --- |
| Milestone 1 | Starter attacks, run upgrades, five enemy behaviors, one boss, feedback/results, seeds | Stories 1–3 / FR-001–FR-014 verified; SC-001–SC-004 and SC-010–SC-011 measured | Milestone 2 only after this gate passes. |
| Milestone 2 | Accepted Milestone 1; permanent roster and promotion resources | Stories 4–5 / FR-015–FR-023 verified; SC-005 measured; combat preserved | Milestone 3 only after this gate passes. |
| Milestone 3 | Accepted Milestone 2; settlements, ownership, guild | Stories 6–7 / FR-024–FR-034 verified; SC-006–SC-007 measured; rescue works without generic events | Milestone 4 only after this gate passes. |
| Milestone 4 | Accepted Milestone 3; readable combat and rescue settlement | Stories 8–9 / FR-035–FR-042 verified; SC-008–SC-009 and SC-012 measured; earlier criteria rechecked where changed | Full MVP acceptance; further scope needs a specification update. |

Per the 2026-10-14 task-generation request, the task roadmap covers all four milestones in dependency order. Active implementation MUST begin with Milestone 1; Milestones 2–4 remain blocked by acceptance of the preceding checkpoint. No guild, save progression, companion, gacha, or corruption infrastructure is required to accept Milestone 1. Later milestones preserve earlier acceptance behavior, with the explicit owned-rescue scheduling change above.

**Included scope:** One repeatable coastal chapter/field/boss; three base classes and six promotion branches; six heroes; up to two companions; twelve initial upgrades; three event types; local progression/collection; simple keyboard combat. Permissible original placeholders can replace finished art if identity, feedback, and readability remain and replacement is documented.

**Excluded scope:** Multiplayer, accounts, external servers/services, money/premium currency, open-world exploration, turn-based tactics, more heroes/classes/branches, campaign beyond Chapter 1, production art for every hero, extra bosses/maps, manual skill rotations, companion commands, respec, draw rarity tiers/banners/pity, and full mid-run save/resume. New scope needs explicit specification revision.

### Key Entities *(include if feature involves data)*

- **Player Progress**: One local player's roster, party selection, promotion items, tickets/tokens, recruitment history, and chapter completion, without an online identity.
- **Hero Definition**: Original identity, base class, presentation, unique passive, acquisition route; separate from owned progression.
- **Owned Hero**: One record per hero with permanent experience, level 1–30, base/selected promotion, and availability.
- **Class / Branch**: Attack behavior, automatic effects, and visual identity; two mutually exclusive branches per base class.
- **Party**: One active hero and up to two distinct companions; starting levels/classes/passives matter for replay.
- **Expedition**: Seed, game version, starting party/progression, active time, waves, run levels/upgrades, health, kills, coins, events, corruption, and one outcome.
- **Upgrade**: Temporary effect, eligibility, limit, and preview, lasting only this expedition.
- **Enemy / Boss**: Identity, movement/attack behavior, health/damage, telegraphs, effect resistance, and rewards.
- **Event / Bargain**: Offer timing/type, readable choices, eligibility, costs/rewards, corruption, and resolution; rescue guarantee differs from random offers.
- **Run Settlement**: Final outcome and complete permanent rewards, including participants/rescue; viewing results cannot reclaim it.
- **Recruitment Draw**: Cost, probabilities, ordered committed outcomes, ownership, duplicate conversion, and history; separate from run randomness.
- **Permanent Resources**: Promotion items, tickets, shared duplicate tokens; nonnegative balances with only stated MVP uses.

## Success Criteria *(mandatory)*

### Measurable Outcomes

These are acceptance targets, not implemented/tested gameplay claims. Playtests use at least ten first-time players with only in-game instructions. Duration samples use at least twenty victorious baseline solo runs across all three starters. Planning must declare the reference play environment before performance measurement.

- **SC-001 (M1 usability)**: At least 9 of 10 first-time players start an expedition and move/attack without external help within two minutes of opening the game.
- **SC-002 (M1 duration)**: At least 80% of twenty baseline victories finish in 9–11 active minutes; every starter can independently win. Pause/choice time is excluded.
- **SC-003 (M1 variety/fun)**: At least 8 of 10 players describe a mechanical difference between each starter after trying all three; at least 7 rate combat enjoyment and willingness to retry at 4 or 5 on a five-point scale.
- **SC-004 (M1 outcomes)**: Every exercised victory, defeat, pause, and retry case gives one correct result and usable continuation without frozen controls, duplicate rewards, or leftover upgrades.
- **SC-005 (M2 progression)**: All controlled level/promotion/party boundaries pass, including 14/15/30, items 0/1, companions 0/2, passive continuity, and caps; settled state survives twenty close/reopen checks.
- **SC-006 (M3 collection)**: A fresh profile owns exactly three starters and earns Sera with one successful rescue regardless of draw luck. Each remaining hero is obtainable by draw or five-token exchange, with one ownership record per hero.
- **SC-007 (M3 draws)**: All controlled single/batch results, insufficient balances, repeated input, interrupted reveals, and in-batch duplicates produce exact totals. Displayed odds total 100%; equal selection intervals each represent exactly 50% of possible random selections.
- **SC-008 (M4 decisions)**: At least 8 of 10 players state a bargain's benefit/cost before choosing; all exact-threshold, decline, unavailable-offer, and corruption-cap checks pass.
- **SC-009 (M4 variety)**: Ten different seeds collectively encounter all three event types and at least three ordered offer sequences; unowned Sera appears at minute 4 in every run reaching it. Chapter completion survives reopening.
- **SC-010 (combat feedback)**: On the declared reference environment, movement starts/stops and hit feedback appears within 100 milliseconds of input/hit with 100 enemies and 30 simultaneous attack effects. At least 8 of 10 players identify active hero and boss danger areas within one second in that encounter.
- **SC-011 (replay)**: Ten controlled repeat pairs with matching seed/version/start/decisions reproduce waves, upgrade offers, and applicable events exactly; pause duration does not change the next offer.
- **SC-012 (full integrity)**: Earlier acceptance scenarios pass after Chapter 1 additions, subject to the stated owned-rescue scheduling change. Twenty representative save/reopen and settlement-interruption checks preserve complete outcomes without lost ownership, negative balances, or double claims; a full session works offline.

## Assumptions

- Keyboard desktop play is the MVP target. Controller/mobile/remapping and broader accessibility settings are deferred; shape-based cues/simple controls are included. Operating systems, hardware, art conventions, and smooth-play budgets belong in the plan.
- Numeric upgrades, experience/reward rates, item costs, companion scale, odds, exchange, schedule, and thresholds are explicit initial defaults making the brief testable. Tuning requires documented specification revision and revalidation of affected checks.
- Targeting ties/projectile lifetime, spawn counts/composition/safety/cap, choice ordering, companion formation/recovery, attack counters, rescue boundaries, and save recovery above are proposed initial gameplay defaults for this clarification review, distinct from the three explicitly answered decisions. They apply in their existing milestones and introduce no additional delivery scope.
- Flat 100 permanent experience per level keeps promotion reachable in a demo. Five ten-minute victories yield 1,500 experience/five items, taking a starter past level 15; ordinary defeats contribute experience.
- Shared promotion items and permanent branch choice apply outside combat. New recruits use existing base-class branches without adding classes.
- Each expedition starts at full health; downed companions restore next run. Applicable choices affect the party. Companion kills drop the same gems/coins as active-hero kills; experience collection advances one shared run level, whose upgrades affect the party.
- Invulnerability is checked before damage. Damage boosts/reductions use stated categories; eligible hit damage is at least 1. Slow/pull can be resisted by bosses/armored enemies only with visible resistance feedback.
- Escape pauses/resumes; keyboard navigation/confirmation supports choices. Text concentrates in selection/choice/result screens; attacks/abilities need no extra combat keys.
- A seed is an integer from 0 through 2,147,483,647; blank generates one. Reproducibility is within one version with matching start/decisions, not across balancing/progression changes. Seeds never rewind permanent rewards/draw history.
- One local profile suffices. Run settlements, promotions, exchanges, and committed draws persist; mid-run continuation is excluded. Recovery preserves valid available progress and informs the player of errors.
- Two equal-probability heroes plus token exchange need no pity system. Resources have no expiry, purchase option, or daily online requirement.
- Constitution version 1.0.0 supplies original-content, readability, gameplay-first, reproducibility, and checkpoint governance. Engine/architecture/testing constraints apply in planning rather than becoming implementation instructions here.
- This document covers the full requested MVP and bounds the next plan to Milestone 1. Later plans depend on verified earlier gates; no gameplay, assets, dependencies, or project settings are implemented by this specification step.
