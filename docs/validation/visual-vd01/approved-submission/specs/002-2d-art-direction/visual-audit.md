# Visual/UI Baseline Audit — 2D Art Direction

**Date**: 2026-10-16 · **Feature**: [spec.md](spec.md) · **Method**: read-only source/resource/scene refresh for VD-01-M1. Original baseline below is retained; the final section records the new concept-only delivery. No new engine/gameplay/performance run or owner visual approval.

## Evidence and precedence

This is the baseline audit for the first formal production visual specification. Existing [placeholder conventions](../../docs/art-direction.md), [asset provenance](../../assets/provenance.md) and [effect notes](../../assets/effects/m2-branches.md) are historical evidence, not previous production design approval. The [gameplay UI contracts](../001-abyss-expedition-mvp/contracts/ui.md) define behavior to preserve. Current source wiring outranks old screenshot labels.

The `assets/` inventory contains provenance and placeholder/effect Markdown notes, not finished character/enemy animation sheets, tilesets or UI artwork. Root `icon.svg` is the application icon; it is not a production gameplay asset set. Images under `screenshots/` are evidence, not reusable sprite art. Concept Image 2 and Concept Image 3 are missing reference inputs; no matching artwork is claimed.

## Existing, missing and planned assets

Status is per column: “existing” means located in source, not production art accepted. Every proposed replacement below is **planned / unimplemented**, with owner approval pending. No asset is marked finished based on a screenshot or historical checklist.

| Family | Existing runtime/source evidence | Missing production art | Planned replacement / reuse |
| --- | --- | --- | --- |
| Six heroes | [character Resources](../../data/characters/aren.tres), six entries in `data/characters/`; [ActorPresentation](../../scripts/combat/actor_presentation.gd) draws sword/bow/star shapes | Individual expressive character sheets and portraits | Slice: Aren; later Lia/Milo/Sera/Brann/Nyra; shared class motion, unique hair/clothing/emblems; portraits crop approved sprites first |
| Three base classes / six promoted classes | `data/professions/` has nine Resources; [branch motifs](../../assets/effects/m2-branches.md); [promotion UI](../../scripts/ui/promotion.gd) instantiates actual actor/VisualSet previews | Finished state sheets and consistent native-scale branch identity art | Retain sword/bow/staff families and all six existing branch silhouette cues; shared body/motion instead of bespoke per-hero animation |
| Six ordinary enemy identities | `data/enemies/`: Thrall, Brinejaw, Cantor, Husk, Broodmother and Broodling; actor presentation draws diamond/crab/lantern/shell/tentacle/triangle | Original expressive sprite sheets with consistent poses and threat cues | Slice: Thrall and Brinejaw; later remaining identities; corrupted overlay variants reuse their base silhouette |
| Boss | [Tidebound Hierophant definition](../../data/encounters/tidebound_hierophant.tres); crowned, eyed/tentacled procedural actor | Finished 64×64 boss state sheet and supporting VFX art | Later original cult/abyss silhouette; retain existing warning patterns and size/footprint relationship |
| Terrain / shrine | [CoastField](../../scripts/world/coast_field.gd) draws 960×540 ground, tidal shelves, cult stones and border; [scene](../../scenes/world/coast_field.tscn) is Node2D with script | Gothic modular tiles, shrine focal prop and depth layers | Slice: one coastal corrupted shrine kit; reused ground/wall/arch fragments and overlay; preserve walkability and boundaries |
| Animation | Procedural bob, aim line, hurt flash, death pose and invulnerability ring in ActorPresentation; [placeholder README](../../assets/sprites/placeholders/README.md) | Authored animation sheets, state/direction manifests and editable masters | Preserve five-state priority; small shared/mirrored sets within spec budget; animation consumes state only |
| Sword and magic | [melee arc](../../scripts/combat/melee_arc.gd), [projectiles](../../scripts/combat/projectile.gd), [homing weapon](../../data/weapons/homing.tres) | Pixel strips for sword direction/impact and friendly magic | Slice: existing sword arc and homing-star effect; magic preview does not grant Aren a new skill |
| Remaining VFX / pickups | [telegraphs](../../scripts/combat/telegraph.gd), [damage zones](../../scripts/combat/damage_zone.gd), [XP pickup](../../scripts/progression/xp_pickup.gd), [rescue zone](../../scripts/collection/rescue_zone.gd) | Unified effect atlas, impact/zone/icon art | Later reuse warning outlines and effect families; preserve orange danger, cyan diamond XP and exact visible danger geometry |
| Lighting / depth | Flat colored procedural ground and corruption tint; source/scene search found no wired Sprite2D, AnimatedSprite2D, TileMapLayer, 2D-light, particle or ShaderMaterial presentation | Production layered art and approved lighting/effect treatment | Painted depth and one affordable shrine focal treatment first; optional measured 2D lights/shaders/particles later |
| UI / font | [shared Screen](../../scripts/ui/screen.gd), [app theme](../../scripts/core/app_router.gd), `scripts/ui/`; Godot built-in font per provenance | Shared production panel/icon/portrait style and reviewed layouts | Reuse one theme/component family; preserve contracts, exact values, focus and save gating; no external font dependency assumed |

Character identities are six data entries, not six existing unique sprite sets: Aren/Brann share Swordsman, Lia/Nyra share Archer, Milo/Sera share Mage. The six ordinary enemy definitions include the summoned Broodling; historical “five enemy behaviors” summaries describe a different count and do not mean a sixth independent behavior was added.

## UI inventory and design gaps

Scene files in `scenes/ui/` are largely Control shells; scripts construct the visible layout at runtime. “Approve before modifying scenes” therefore also protects the runtime layout/theme scripts and linked resources. A script-only redesign cannot bypass G1.

| Screen / existing source | Current presentation and gap | Required proposed treatment / protected states |
| --- | --- | --- |
| [Combat HUD](../../scripts/ui/combat_hud.gd) | Flat top strip with long text; separate corruption, party and rescue labels; prototype bars | Compact grouped status, Hero Lv versus Run Lv, HP/XP/time, boss, two companions/downed, rescue, corruption/coins, discoverable seed/details; slice priority |
| [Level-up](../../scripts/ui/level_up.gd) | Text buttons with accurate Resource-derived effects and counts | Three consistent choice cards, short hierarchy and optional shared icons; focus/1–3 keys, no skip/reroll, pause and queued choices preserved |
| [Character selection](../../scripts/ui/character_selection.gd) | Owned-hero text grid and scrolling, seed input and errors; no individual portraits | Sprite-crop identities, selected/current class, owned-only selection, clear seed/preview/start; fresh and six-owned states |
| [Roster](../../scripts/ui/roster.gd) | Scrollable stats/party/promotion actions | Compact reusable hero rows/cards; active/companion/downed concepts distinct; 0–2 companions, validation and save/cancel states |
| [Promotion](../../scripts/ui/promotion.gd) | Two genuine procedural branch previews and text actions | Clear two-branch comparison with actual identities, current stats/effects, retained passive, permanence/cost, locked/selected/confirm/cancel states |
| [Guild](../../scripts/ui/guild.gd) | Current entry hub: chapter, balances, collection routes and links | Restrained shrine/guild framing, shared hero icons and compact balances; fresh/collected/completed states; no new navigation step |
| [Main menu](../../scripts/ui/main_menu.gd) | Legacy menu scene/script remains; current `show_menu()` routes to guild | Shared key-art/title/button treatment documented for legacy surface; do not make historical menu screenshot the current startup claim |
| [Recruitment](../../scripts/ui/recruitment.gd) | Shared text panels for pool, confirmation, reveal, exchange and history | Same shared frame/icon system; all ten ordered outcomes, duplicate labels, probability/cost details, insufficient/all-owned/empty and interrupted reveal states |
| [Rescue prompt](../../scripts/ui/rescue_prompt.gd) | Paused text offer; existing zone and HUD show progress | Compact offer/reward framing; accept/decline, active/failure/success, Sera versus repeat ticket, earned versus settled |
| [Event choice](../../scripts/ui/event_choice.gd) | Exact costs and disabled reasons on merchant/altar/rescue-related choices | Shared choice-card treatment with cost/risk hierarchy; no hidden deductions, free leave, affordability and corruption/health limits |
| [Corruption summary](../../scripts/ui/corruption_summary.gd) | Text threshold summary accessible with C | Compact exact threshold rows and consistent purple motif, distinct from orange danger; preserve full details |
| [Pause](../../scripts/ui/pause_menu.gd) | Shared modal controls and abandon confirmation | Consistent paused/confirm/destructive states; no release of other pause reasons or automatic confirmation |
| [Results](../../scripts/ui/run_results.gd) | Outcome, participant gains/caps, saved rewards and replay-condition disclosure | Compact result hierarchy, saved/chapter/replay-change cues; victory/defeat/cap/party and same-seed paths |
| [Save/recovery](../../scripts/ui/save_error.gd) | Storage error, long path, retry/recovery/new profile or lock messages | High-legibility shared modal; wrapping/scroll, loss warning and explicit confirmation, newer-save/locked/pending states; never decorative dismissal |
| [F9 developer panel](../../scripts/debug/debug_panel.gd) | Four tabs, scrolling, sandbox banner and isolated actions | Shared theme only after approval; no new debug functionality, normal-profile writes or release visibility |

## Screenshot evidence actually viewed in this task

These are existing files, **not new test captures, target mockups or Concept Images 2/3**. The image contents were visually inspected; their filename/build claims are historical evidence, not a fresh executable verification.

| Existing image | Observation / limitation |
| --- | --- |
| [M4 release boss / corruption 100](../../screenshots/m4-release-boss-double-eruption-1280.png) | Flat dark field, geometric hero/enemies, orange sector/circle warnings, dense HUD text and green rescue boundary; useful baseline for clutter and cue priority |
| [Aren promotion](../../screenshots/convergence-exe-m2-promotion-aren-1280.png) | Two real procedural branch previews, outlined buttons, cost/permanence and disabled confirmation; keep functionality while improving art |
| [Character selection](../../screenshots/convergence-exe-m2-selection-1280.png) | Text-only three-starter selection, seed and scroll container; no distinct character portraits |
| [Current guild](../../screenshots/convergence-exe-m4-guild-1280.png) | Flat text-led hub with collection and routes; source confirms this is the normal entry |
| [Historical M1 menu](../../screenshots/menu.png) | Older prototype title/help screen says no permanent progress; obsolete as a statement of current gameplay, retained only to audit the legacy menu's presentation |

Level-up, recruitment, recovery and remaining surfaces were inspected in source, not newly played or visually accepted in this task. No synthetic contact sheet or replacement screenshot was generated.

## Acceptance dependencies and current status

| Item | Actual status at specification creation | Next evidence required |
| --- | --- | --- |
| Visual feature specification | Draft written; requirements checklist reviewed separately | Owner review, then planning as requested |
| Asset/UI baseline | Source and five existing images inspected | Refresh audit when proposed art is delivered |
| Concept Images 2/3 | Missing; written descriptions available | Provide references or record explicit written-direction substitution at G0 |
| Production style / mockups | Not produced or approved | G0 direction and G1 package with revisioned owner decision |
| Visual slice / new sprites / UI skin | Unimplemented | Approved plan/tasks and G1 before any live replacement |
| Remaining roster/enemies/boss/screens | Planned design coverage; production deferred | G2 slice review then per-family G3 approvals |
| Gameplay automated checks | Historical evidence only in this task | Future affected regressions; do not inherit a visual acceptance pass |
| Performance | Historical latest release p95 27.571 / 27.670 / 29.259 ms exceeds 16.67 ms | Matched measurements and reference-machine acceptance; [current evidence](../../docs/validation/convergence-2026-10-15.md), [protocol](../../docs/benchmarks/m4.md) |
| Human readability, displayed latency and visual taste | Pending, not established by static inspection | Ten-person tests, observed feedback and explicit owner visual decision |

No gameplay spec/task checkbox, old art convention or historical validation log is modified to imply acceptance of this feature.

## Phase 1 refresh / VD-01-M1

Protected source manifest: [audit-baseline.json](../../docs/validation/visual-vd01/audit-baseline.json), 234 runtime/data/scene/asset/test/config files hashed before documentation work. `assets/` contains exactly four Markdown notes. `data/visuals/` does **not** currently exist: `VisualSet` definitions are embedded in profession/enemy Resources. It is a proposed integration directory, not an existing source. A Git checkout is present now, but verification uses explicit file hashes, not Git metadata.

Current source checked: ActorPresentation retains ownership rings, corrupted crests, resistant/invulnerability/hurt states, enemy HP and procedural death; actor display rounding never writes physics position. MeleeArc draws reach/angle exactly; `run_manager.gd` expires sword effects only when tick>expires. Projectile homing is an existing friendly star, not a proposed Aren skill. CoastField creates four actual walls and draws 960×540 coastal ground. Expedition has Y-sorted Actors and a separate HUD CanvasLayer. No production sprites/TileMapLayer/light assets were found in these presentation paths.

| Priority / requirements | Inconsistency or risk | Current / fallback source | Review evidence / acceptance boundary |
| --- | --- | --- | --- |
| P0 · FR-008/009/012/022 | Class-only replacement would also change Brann/promoted identities; bigger artwork could misstate collision/reach | actor_presentation.gd; profession/enemy `.tres`; melee_arc.gd | Exact selectors Aren+swordsman / Thrall / Brinejaw; base sword only; [lineup](../../docs/visual-design/mockups/vd01/actor-lineup.png), [manifest](../../docs/visual-design/mockups/vd01/animation-manifest.json); runtime still pending |
| P0 · FR-009/013/016 | HUD/décor could cover hero and overlapping warnings at edges | combat_hud.gd; telegraph.gd; coast_field.gd | Combined [HUD/edge rectangles](../../docs/visual-design/mockups/vd01/hud-layout.json); 24.52% is proposal area only; P01 decision and real captures pending |
| P0 · FR-014/023 | Animation replay on late observation could delay or duplicate perceived hits | attack_executor.gd; actor_health.gd; core/run_manager.gd; brinejaw_behavior.gd | [event sampling concept](../../docs/visual-design/mockups/vd01/event-sampling.webm); 12/8/24/45tick authoritative windows; no runtime assertion claimed |
| P1 · FR-016–020 | Mixed local Theme overrides, 10/11px labels and long top line | screen.gd; combat_hud.gd; core/app_router.gd | [UI audit/state contract](../../docs/visual-design/UI_DESIGN.md); 12px / 16px / 20px proposal; guild is current entry, F9 remains debug-only |
| P1 · FR-005/010/023 | Dense purple décor competes with friendly purple magic | projectile.gd; coast_field.gd | Cyan closed/star core vs branching abyss; low-contrast tiles, gray/unlit boards; [readability review](../../docs/validation/visual-vd01/mockup-readability.md); human results pending |
| P2 · FR-002/021 | Historical screenshots could be mistaken for new gameplay or source sprites | screenshots/; assets/provenance.md | REAL historical files unchanged/hash retained; new PNG/ORA/WebM exclusively PROPOSED under docs; production paths remain missing |

Excluded production: other five heroes, six promotions, four ordinary enemy identities, boss and non-slice screens. Their cue/state design remains documented, not new work required to approve this batch. Save/seed, exact costs, permanent choices, warning geometry and developer-profile isolation remain protected.

Phase 1 evidence: [phase-1.md](../../docs/validation/visual-vd01/phase-1.md). New original concept art is a separate proposed package, not a change to this runtime baseline. Existing 27.571/27.670/29.259ms historical p95 failures and human gates remain open.
