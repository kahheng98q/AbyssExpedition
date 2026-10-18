# Feature Specification: Abyss Expedition — 2D Visual Art Direction

**Feature Branch**: Not created; no branch-creation hook is configured.

**Feature Directory**: `specs/002-2d-art-direction`

**Created**: 2026-10-16

**Status**: VD-01-P2 eight-item slice integrated; latest executed evidence remains [2026-10-17 completion](../../docs/validation/visual-vd01/completion-r1.md). Autonomous workflow effective 2026-10-18; manual/reference-machine/performance acceptance remains open. This update changes documentation/configuration only.

## Current workflow — 2026-10-18

**Autonomous Implementation with Continuous Documentation** follows [AGENTS.md](../../AGENTS.md)
and [constitution v1.1.0](../../.specify/memory/constitution.md). Continue all authorized in-scope
tasks without routine task/phase sign-off or visual approval stops; automatically test/fix and
update documentation after every phase. G0/G1/G2 record design/evidence, not execution permission.
Record unavailable manual checks as pending and continue unrelated work. Reviewer-owned
checklists remain read-only. Request intervention only for genuine blockers, high-risk actions
or required platform permissions. No gameplay implementation is authorized by this configuration
update; the eight-item scope, budgets, exclusions, historical decisions and acceptance targets remain.
Earlier dated planning/execution notes below are historical; this section and the revised
requirements/checkpoints govern future work. G3 remains outside the current scope.

## Planning scope addendum — 2026-10-16

The owner explicitly requested a redesigned level-up UI in the first visual vertical slice during speckit-plan. Add that existing screen to FR-011 and the G1/SC-001 first-batch review package; preserve FR-017/020 behavior. The package now contains eight individual deliverables: one hero, two enemies, one environment, two effects, battle HUD and level-up UI. Include the seed disclosure in the existing pause screen if removing seed from HUD, without a pause-screen redesign. Other scope, the 58-frame ceiling, G0–G3 evidence records and all gameplay invariants remain unchanged; routine approval stops are superseded by the current workflow. Planning documents and a clearly labeled offline preview scaffold are now delivered; the then-future pixel mockups, production assets and runtime work are tracked by later execution evidence. Earlier references below to the specification step describe that historical step, not a prohibition on this requested plan. See [plan.md](plan.md) and [visual documentation](../../docs/visual-design/ART_DIRECTION.md).

**Input**: Establish the first cohesive, production-friendly visual identity for the existing playable game: dark gothic ruins and purple eldritch atmosphere inspired by the described Concept Image 3; cute, expressive pixel characters and distinctive enemies inspired by the described Concept Image 2. Pure 2D, near top-down, low production cost, readable survivor combat, compact UI, and a versioned representative visual slice before any separately authorized broader replacement. No gameplay, balance or code changes in this step.

This is a **new visual feature**, separate from the [M1–M4 gameplay specification](../001-abyss-expedition-mvp/spec.md), its [plan](../001-abyss-expedition-mvp/plan.md) and tasks. It preserves their acceptance criteria and introduces no M5 gameplay milestone. This workflow update itself does not execute implementation. The [constitution](../../.specify/memory/constitution.md) remains authoritative. The existing [art-direction note](../../docs/art-direction.md) is a historical placeholder convention, not an approved production art bible. This specification establishes the first formal visual design baseline without assuming earlier design approval.

## Review correction R1 — 2026-10-16

This authorized documentation correction is not G0/G1 approval or implementation. The first batch is **eight** deliveries (1+2+1+2+2); shared Theme/icons/portrait crops and pause seed disclosure are supporting work. Historic reports retain their wording; this corrects their nine-item arithmetic. Task IDs remain stable.

Historical R1 G1 decisions (subsequently recorded on 2026-10-16): **P01** edge-cropping/HUD avoidance; **P02** supplemental new-effect workload (candidate: 30 new sword arcs and 100 new homing stars); **P03** mirror-safe actor shading. The plan/approval register define candidates, required evidence and blocked tasks. Their versioned treatment must be recorded before dependent work; routine owner sign-off is no longer a prerequisite. No camera, collision, simulation or target relaxation is authorized.

## Clarifications

### Session 2026-10-16

- Q: Should production art retain the current 640×360 logical viewport and 1× camera zoom? → A: Yes. Retain 640×360, fixed 1× zoom, pure 2D near top-down perspective and no player zoom control; 1280×720 and 1920×1080 present at integer 2× and 3×.
- Q: Which hero canvas and actor scale should the first production batch use at 640×360 and 1× camera zoom? → A: Use a 32×48 hero canvas with an approximately 24×32 body, 32×32 terrain tiles at 1:1 world scale, 32×32 or 32×48 ordinary-enemy canvases and a retained 64×64 boss canvas. Ordinary-enemy body height (Thrall) or body width (Brinejaw) starts at 0.75–1.0× the hero's 32-pixel body height. Validate visible bodies and crowd occlusion in G1 mockups; canvas padding never changes collisions or reach.
- Q: Should the slice start with one authored actor facing plus horizontal mirroring, adding four-direction animation only if readability fails? → A: Yes. Do not rotate actor bodies. Test all four movement/attack directions using mirrored bodies and directional VFX first. Minimum state sequences (idle/move/attack-or-warning/hurt/death) are 2/4/3/1/4 for the hero and 1/2/1/1/3 per enemy; sword and magic each need at least two effective frames. Hurt may reuse a pose with flash; contact-only enemies need no invented attack. Keep the 58-unique-authored-cell ceiling; additional facings require a revised estimate; exceeding scope or budgets requires explicit scope authorization.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Judge one coherent visual slice (Priority: P1)

As the project owner, I can inspect a versioned, representative visual proposal and the resulting implementation/evidence while in-scope work continues autonomously.

**Why this priority**: A bounded sample tests the combination of cute characters and threatening ruins before repeating an unsuitable style across the whole game.

**Independent Test**: Review the offline slice package against the asset audit, selected direction and evidence checkpoints; no game modification is required.

**Acceptance Scenarios**:

1. **Given** the current procedural prototype, **When** the slice is proposed, **Then** its boards show exactly one playable swordsman identity, two distinct existing enemy identities, one corrupted shrine setting, one sword attack sequence, one magic effect sequence, one redesigned battle HUD and one redesigned level-up UI (eight individual deliverables), clearly marked as proposed artwork.
2. **Given** Concept Images 2 and 3 have not been supplied in this session, **When** direction is reviewed, **Then** their missing status is visible; the written direction is explicitly labeled as the working reference substitute; actual owner acceptance is recorded only if received. Missing images do not stop independent in-scope work. No invented image likeness is claimed.
3. **Given** versioned mockups meet the scoped design/evidence prerequisites, **When** implementation is considered, **Then** authorized scene/UI/resource work proceeds without routine owner approval. Actual quality failures block dependent work; missing manual checks remain pending.
4. **Given** the owner rejects one part, **When** it is revised, **Then** the rejected revision remains traceable and the agent records and addresses the feedback within scope without a routine resubmission approval stop; material scope conflicts require user input.

---

### User Story 2 - Read combat in a dark environment (Priority: P1)

As a player, I can locate my hero, understand attack direction and avoid danger while many enemies and purple corruption effects share the screen.

**Why this priority**: Atmospheric art must preserve movement, automatic combat and danger recognition.

**Independent Test**: Review normal and dense-combat boards or clips at target display sizes, then perform the same recognition checks in the scoped playable slice.

**Acceptance Scenarios**:

1. **Given** the hero, both slice enemies, allied magic and corruption appear together, **When** a reviewer sees a two-second combat excerpt, **Then** the hero, enemy types, attack direction and dangerous area can be identified without relying on color alone.
2. **Given** maximum corruption, overlapping warnings and a shrine light, **When** effects peak, **Then** warning boundaries remain visible above decoration, match the existing danger geometry and retain their existing warning duration.
3. **Given** presentation effects are reduced for cost, **When** combat continues, **Then** damage, healing, targeting, cooldowns, enemy counts, spawn order, projectile paths and movement behave identically to the unmodified gameplay baseline.

---

### User Story 3 - Make clear choices across existing screens (Priority: P2)

As a player, I can choose a hero, compare a level-up or promotion, manage my party and understand rewards or save problems through a compact, consistent interface.

**Why this priority**: A common visual language reduces confusion without changing established screen contracts.

**Independent Test**: Compare proposed screen layouts with the [existing UI contracts](../001-abyss-expedition-mvp/contracts/ui.md); test focus, legibility and state coverage using static boards or clickable mockups before runtime integration.

**Acceptance Scenarios**:

1. **Given** a level-up proposal, **When** the player compares the three choices, **Then** names, accurate effects, stack counts, selected focus and 1/2/3 shortcuts are clear; pause, no-reroll and no-skip behavior are preserved.
2. **Given** a selection or promotion proposal, **When** the player compares identities, **Then** the current class, both eligible branch appearances, retained passive, cost, permanence, disabled reason and cancel path are visible without confusing preview with a committed choice.
3. **Given** a long list, insufficient currency, pending save or restored draw, **When** the relevant screen is reviewed, **Then** it retains all required information and reachable actions, including keyboard focus and scrolling, without text crossing panel edges.

---

### User Story 4 - Produce reusable original art economically (Priority: P2)

As an artist or developer, I can distinguish reusable placeholders from missing finished assets and build consistent replacements without creating unnecessary animation sets or copying existing games.

**Why this priority**: A small team needs clear replacement priorities, shared components and explicit production limits.

**Independent Test**: Audit the asset register, style rules and slice budget without changing the game; verify each planned delivery has an identity, state coverage, reuse decision, provenance and acceptance target.

**Acceptance Scenarios**:

1. **Given** the existing asset inventory, **When** production is estimated, **Then** procedural drawings, historical screenshots, missing production assets and planned replacements occupy separate status columns.
2. **Given** a promoted class or second hero of the same class, **When** a design is proposed, **Then** it reuses the approved body/animation family where possible but retains a readable class silhouette and a distinct character identifier.
3. **Given** a new asset delivery, **When** it is reviewed, **Then** authorship, permitted source, placeholder status, intended replacement and applicable style revision are recorded; unlicensed or copied franchise artwork cannot be accepted.

### Edge Cases

- Purple allied magic, a void-class ally and corrupted enemies coexist: ownership uses silhouette, outline and shape, not purple hue alone.
- A light, foreground arch, fog layer or particle crosses a warning: decoration yields; no hidden attack boundary or obscured hero feet.
- Enemies overlap the hero, companions are downed, or hurt/death interrupts an attack: ownership and state priority remain legible; animation completion cannot delay gameplay.
- Corruption is 0 or 100: both versions preserve walkable-ground readability and identical collisions. A shrine is decorative unless an existing event explicitly supplies an interaction.
- Window is 1280×720, 1920×1080 or the existing irregular 1371×779 case: crisp scaling, letterboxing and keyboard-reachable content remain intact.
- Long names, large HP/XP values, all six heroes, ten ordered draw results and long save paths: critical values and actions remain visible or reachable by scroll; decorative copy yields first.
- Default, hover, keyboard focus, pressed, disabled, error and pending states coexist: focus and disabled reasons are distinguishable without color-only cues.
- Directional mirroring would reverse a unique weapon emblem or semantic mark: correct that mark rather than creating an entire additional animation family.
- Baseline performance already fails its target: a visually attractive proposal or a small relative improvement cannot be labelled performance-accepted.
- A required image, original source file or license is missing: keep the dependent item pending with the reason recorded and continue unrelated tasks; never fabricate a screenshot or owner approval.

## Requirements *(mandatory)*

### Functional Requirements

#### Scope, evidence and autonomous execution

- **FR-001**: The visual feature MUST preserve the existing offline survivor loop and all gameplay/balance values, saves, deterministic random streams, promotion/recruitment rules and developer-only F9 restrictions. Cosmetic animation and randomness MUST NOT determine simulation results.
- **FR-002**: The feature MUST maintain a path-backed visual/UI audit separating existing runtime presentation, missing production assets and proposed replacements. Its initial baseline is [visual-audit.md](visual-audit.md); screenshots MUST be labeled historical evidence rather than new captures or approved targets.
- **FR-003**: The feature MUST use the written Concept Image 3 atmosphere and Concept Image 2 character appeal as its working brief. Actual image comparison MUST remain pending until references are available. Label the written substitute and record any actual owner decision without inventing image likeness or ownership; missing references alone MUST NOT stop independent in-scope work.
- **FR-004**: The feature MUST follow Autonomous Implementation with Continuous Documentation: proceed through all authorized in-scope tasks and phases without routine human approval or visual design sign-off; automatically test, fix implementation errors and update documentation after each phase. Versioned G0/G1/G2 evidence MUST identify revision, scope, checks, outcomes and pending manual verification. Reviewer-owned checklist markers MUST remain unchanged. Continue unrelated tasks when manual checks are unavailable; request intervention only for genuine blockers, high-risk actions or platform permissions. G3 expansion remains outside scope. Actual owner feedback/decisions MUST be recorded only when received.

#### Coherent visual language

- **FR-005**: The world MUST combine broken gothic masonry, ruined arches, muted cold stone and restrained purple eldritch growth. Depth MUST come from layered 2D ground, midground ruins and sparse foreground/atmospheric accents, with a quiet walkable combat plane. Decoration MUST preserve the existing field silhouette, boundaries and traversable area. New environment rendering and the old procedural background MUST be mutually exclusive, with complete procedural fallback when required visual resources are unavailable. Preserve the four physical walls and define final world-layer Z values before wiring.
- **FR-006**: Characters MUST have cute, expressive proportions, readable faces and oversized identifying equipment at native gameplay size. Threats MUST use memorable original silhouettes and strange anatomical motifs; horror comes from asymmetry, voids, eyes and unnatural growth rather than noisy detail or realistic gore.
- **FR-007**: All assets MUST share near top-down perspective, pixel density, outline/shading treatment, palette roles, light direction, grounding and animation-state conventions. The future plan/art bible MUST carry forward the clarified resolution, camera, dimensions and animation rules below before reusable art is authored. Any changed design baseline requires a versioned G1 evidence package and documented rationale, without routine owner sign-off. It MUST NOT hide failed acceptance checks. G1 MUST document P03: mirrored shading and semantic marks; world lighting remains upper-left. Symmetric actor lighting must follow the documented P03 decision, not an undocumented exception.
- **FR-008**: Class identity MUST survive desaturation and partial crowd overlap. Sword, bow and staff families MUST differ in equipment/body contour; all six promotion branches MUST add a shape/equipment cue beyond a palette swap. Recruits sharing a class MUST have distinct hair, clothing, face or emblem cues while reusing animation families.
- **FR-009**: Palette roles MUST keep pale/cyan ownership and pickup cues, orange outlined warnings, red impacts and purple ambient corruption semantically distinct. Friendly purple attacks MUST have an allied shape/outline. Decoration MUST remain less prominent than actors and warnings, including in grayscale reviews.
- **FR-010**: Lighting MUST provide a dramatic focal shrine and depth using affordable 2D treatment with a readable unlit fallback. The low-cost slice default is painted light/emissive-looking sprite art, zero new runtime lights, zero dynamic shadows and zero new full-screen post-processing or decorative particle layers. A later measured plan may propose at most one shared shrine light, without shadows, and explicit optional-effect caps; it requires G1 review and SC-006 evidence before broader rollout. Dense combat MUST NOT depend on per-actor/projectile lights. Optional fog, distortion, glow and particles must yield before ownership, warnings, collision cues or HUD; existing attacks and their workload cannot be removed for cost.

#### First visual vertical slice

- **FR-011**: The first slice MUST be limited to Aren's existing base Swordsman appearance, Saltbound Thrall and Skittering Brinejaw, a single corrupted shrine environment kit, one existing sword-arc animation, one existing homing-star magic effect and one battle HUD skin/layout and one level-up UI (eight individual deliverables). These reuse current identities and behaviors; they introduce no enemy type, class ability, collectible, map rule or balance change.
- **FR-012**: The shrine MUST be a visual treatment of the existing coastal field, retaining its tidal/cult context. The magic MUST be demonstrated separately as an existing allied effect preview or existing caster attack; Aren MUST NOT gain a magic ability. Isolating two enemy types on design boards MUST NOT remove other waves or the boss from the shipping run.
- **FR-013**: Slice mockups MUST include an exact 640×360 native composition, integer 2×/3× views and the 1371×779 letterboxed layout, normal combat, dense combat with overlapping warnings, corruption 0/100 treatments, actor silhouettes, animation strips and the HUD's normal/boss/two-companion/rescue states, including their simultaneous nonmodal combination. Show selected canvases versus visible body bounds, ground anchors, all four movement/attack directions and minimum-frame playback. A grayscale or color-independent overlay review and painted/unlit comparison MUST accompany them. These are future deliverables, not produced in this specification step. Include all four field edges and four corners with the combined HUD, hero anchors and nearby warning boundaries. Freeze normal/dense/maximum-corruption fixture populations, screen distribution, overlaps and answer keys before composing review clips; G1 records that versioned protocol before sampling; routine owner approval is not required.
- **FR-014**: Slice animation MUST cover idle, movement, attack/warning, hurt and death where the actor exposes them, reusing frames, mirroring and tint/pose effects where clear. Sword direction/impact, the Brinejaw rush warning and magic ownership MUST remain readable. Death > hurt > attack > movement > idle priority and responsive existing hit timing MUST be retained. Event animation phase MUST derive from original simulation event time, not first render observation or re-entry after interruption. Late observation/skipped ticks sample the current valid frame without replaying expired impact cues or extending state/removal windows; see the presentation contract.
- **FR-015**: The slice production estimate MUST use the bounded starting budget below; additional directions, bespoke per-hero rigs, cinematics and full-roster polished assets MUST wait for review after the slice. Shared tiles, portrait crops, panel borders, icons and effect families MUST be preferred over duplicated artwork.

#### UI and remaining screen coverage

- **FR-016**: Battle HUD information order MUST be: (1) hero current/max HP and immediate boss/danger or rescue alerts, (2) run XP/threshold, Run Lv and active time, (3) compact hero identity/permanent Hero Lv, corruption 0–100 and coins, plus up to two companions' HP/downed status whenever present. Boss HP and rescue progress/outcome appear only in their relevant states and cannot cover the hero or warning boundaries; critical cues MUST NOT depend on color or tiny body text. Seed and exact corruption modifiers MAY move to existing discoverable paused/details views; exact information MUST not be lost. At least 75% of the viewport MUST remain unobstructed by nonmodal HUD panels, text, icons and bars combined, not merely decorative chrome, including simultaneous boss/two-companion/rescue/maximum-corruption state. Test the union of their occupied rectangles; open space between widgets does not count as occupied. HUD area and gameplay occlusion MUST pass independently. G1 must document P01 edge/corner avoidance and body-clipping treatment. Actual occlusion/readability checks remain required; hero ground anchor/location cue and relevant danger boundary must remain readable. Do not move physics roots, alter camera constraints or shrink walkable space to pass.
- **FR-017**: Level-up, selection, roster and promotion MUST follow Story 3 and the existing UI contracts. Iconography MAY shorten repeated prose but MUST NOT replace exact upgrade effects, ownership, costs, irreversible-choice warnings, saved/unsaved state or disabled reasons.
- **FR-018**: Main menu and every existing game screen MUST receive a documented visual treatment/state inventory: guild, recruitment/pull confirmation/ordered reveal/history/exchange, rescue prompt, event choices, corruption summary, pause/abandon, results/chapter completion and save error/recovery. The current guild remains the entry hub; designing a main-menu skin does not authorize adding a new startup step. F9 receives only shared styling and clear sandbox labeling, retaining developer-only availability and profile isolation.
- **FR-019**: UI MUST share restrained pixel borders, common spacing, type hierarchy, icon meanings and selected/focus/disabled states. Body text SHOULD start at the existing 12 logical pixels; smaller text MUST be nonessential and explicitly pass legibility review. Essential text MUST achieve at least 4.5:1 foreground/background contrast; focus and essential icon/boundary cues at least 3:1 against adjacent colors. No localization system or translation expansion is included.
- **FR-020**: All existing keyboard/mouse routes, modal pause behavior, fresh-input protection, scrolling and explicit confirmations MUST remain usable. Visual transitions MUST NOT delay input, auto-confirm a choice, skip save gating or misrepresent earned rewards as saved before settlement.

#### Delivery and verification

- **FR-021**: Assets MUST be original project artwork or clearly permissible supporting resources with recorded creator/source/license and replacement status in the asset provenance register. Do not copy copyrighted game sprites, UI, maps, characters, compositions or branding. Inspiration references are not importable asset licenses; no new paid or runtime dependency is authorized.
- **FR-022**: Future visual delivery MUST include editable masters, game-ready exports, shared palette/style revision, animation/state manifest and a replacement map linking each asset to its current presentation. Replace only the exact actor/effect/UI family identified by the authorized scope and versioned G1 evidence, after all applicable states, anchors, provenance and directional cues pass review. G3 remains outside this batch. Keep other placeholders operational; partial art cannot erase hurt, death, warning, class identity or ownership feedback. The register MUST distinguish placeholder, proposed, approved and integrated/verified states. Preserve original procedural source and before-captures until replacement acceptance so the batch can be reverted; never overwrite historical evidence. Slice acceptance does not authorize replacing other heroes, enemies, boss or screens, and a wider canvas does not enlarge a hitbox. Three data-driven selectors cover Aren+swordsman and the two approved enemy IDs. Expected-resource wiring checks must fail if a planned sprite is missing; separate fault-injection checks verify full fallback. A fallback pass cannot establish art integration.
- **FR-023**: Runtime acceptance MUST include source and Windows release visual checks at the three existing sizes, affected functional regressions and normal/dense play. It MUST preserve existing warning timing/geometry and ≤100 ms displayed input/hit feedback target. Tests not executed, missing hardware and human acceptance MUST remain explicitly pending. New contract/UI/integration fixtures MUST execute in existing unit/scene_smoke/integration_m1 suites respectively, with fixture execution evidence. Cover interrupted/re-entered events, late render observation, skipped ticks, background switching and field-edge HUD occlusion.
  - Visual regression MUST use paired before/after captures of the same saved run-start snapshot, seed (101 for the primary visual set), input/choice sequence, simulation tick, camera position, party/progression, enemy placement/state and corruption. Seeds 101/202/303 remain mandatory for performance. Record build/revision, renderer, display size/scale, fixture state and effect settings; an older unmatched screenshot is context only.
  - Capture native 640×360 output and source/release presentations at 1280×720, 1920×1080 and 1371×779. Cover normal/dense combat, corruption 0/100, overlapping boss warnings, both companions including downed, active/completed/failed rescue and all applicable animation states; the approved combined HUD stress state is mandatory. Use clips for four-direction motion, frame timing, hit responsiveness and warning duration; a still image cannot establish timing.
  - Review aligned overlays/difference images with the intended replacement regions recorded. Require zero unreviewed changed regions, missing essential cues, unexpected gameplay geometry changes or clipped critical UI; changed artwork is expected and cannot be judged by whole-image pixel equality. Check integer pixel blocks, shimmer during movement, anchors/feet, grayscale silhouettes, HUD occupancy and contrast against G1, then retain verified candidate captures with revision, evidence, intended-change regions and rationale separately from any owner-accepted reference. Document baseline revisions within scope without routine sign-off; never automatically rebaseline failures or claim owner acceptance. Human readability and latency remain separate checks.
- **FR-024**: Performance acceptance MUST retain the existing representative maximum-corruption workload and smooth-play targets; effects may be simplified without removing promised attacks or reducing the workload. The slice MUST be measured before broad art rollout, using matched before/after runs. Existing performance failures MUST be reported independently of visual quality and relative improvement.
- **FR-025**: A specification/workflow-configuration step MUST modify documentation/configuration only. It MUST NOT produce runtime changes, assets or gameplay implementation, or mark existing acceptance complete. Later explicitly authorized implementation MUST follow the active tasks and FR-004 without obsolete routine approval stops.

### Explicit Technical Constraints

These constraints are supplied by the user or inherited from the existing project; they bound later planning rather than prescribe implementation code.

- Godot **4.5**, pure **2D**, near top-down view with an orthogonal ground grid; depth is painted/layered, not an isometric diamond grid or camera tilt. No 3D models, 3D scenes, 3D environments, 3D rendering or engine/renderer migration.
- `Sprite2D`, `AnimatedSprite2D`, `TileMapLayer`, 2D lights, shaders and particles are allowed where appropriate. Their use is not mandatory for each asset; preserve the current Compatibility-renderer support and offline operation.
- The production baseline MUST retain the actual 640×360 logical render resolution, fixed Camera2D zoom (1,1), pure 2D near top-down perspective and no player zoom control. The 1280×720 default window and 1920×1080 display are integer 2×/3× presentations, not different render resolutions. Preserve the existing 960×540 world, rounded camera presentation, disabled camera smoothing, nearest sampling and integer scaling. Camera/art changes cannot alter physics, the existing hero footprint or attack reach. Tile and sprite production dimensions are clarified separately below; historical 16×16/32×32 placeholders do not freeze finished-art sizes.
- Pixel-art exports MUST use nearest filtering, no mipmaps and no lossy compression; no fractional actor/tile scaling or mixed pixel density. Preserve continuous simulation coordinates and snap presentation only. At 1371×779 the 1280×720 content remains 2× with letterboxing (opposing margins may differ by one display pixel); do not stretch to fill. Inspect moving sprites, flipped sprites, rotated attack effects and atlas edges for blur, shimmer and bleeding. Font rendering need not become a new bitmap-font production task; essential existing text must meet FR-019.
- Exact atlas layout, node hierarchy, shader algorithms and measured budgets for optional effects belong to the future plan within these constraints. No production implementation is specified here.

### Art Consistency and Production Starting Budget

Resolution, camera, dimensions, direction strategy and minimum frames below are clarified production constraints. Remaining low-cost defaults guide the plan and G1 review; none represents artwork already available or G0/G1 approval.

| Area | Initial production rule | Review evidence |
| --- | --- | --- |
| Perspective and pixels | Consistent shallow top view; aligned ground contacts; one native pixel grid; no mixed smooth/vector character art | Grounding/perspective sheet at native, 2× and 3× scale |
| Terrain and world scale | 32×32 production tile unit; one source pixel equals one logical/world pixel at 1× camera; 20×11.25 tile units across 640×360; partial edge tiles are allowed | Preserve the 960×540 field and its existing boundaries; clip decoration instead of extending collisions to a tile multiple |
| Actor canvases and scale | Hero 32×48 canvas, approximately 24×32 visible body excluding equipment/VFX; ordinary enemies 32×32 or 32×48; Thrall body height / Brinejaw body width 24–32 pixels; boss 64×64 canvas retained | Shared ground-contact anchor at the existing actor origin; hero footprint remains 16 pixels in diameter. At 2×, the hero body is approximately 48×64 display pixels. G1 lineup and crowded-board evidence required before drawing reusable sheets; do not fill the canvas or enlarge collision geometry to match artwork |
| Shading and palette | Dark outline, 2–3 value steps per material, common upper-left painted light; broad quiet surfaces | Shared swatches and grayscale composition |
| Cute hero / strange enemies | Hero head about one-third of body height; face plus sword cue; tall broken humanoid Thrall versus wide low crab-like Brinejaw | Three black silhouettes plus native-size colored lineup |
| Class families | Swordmaster twin blades; Abyss Swordsman spectral mantle; Sharpshooter long bow; Star Hunter star-tipped bow; Elemental Sage split elemental mantle; Void Caster ringed staff | Later branch contact sheet; preserve current identity motifs |
| Hero animation | Minimum effective sequence frames: idle 2, move 4, attack 3, hurt 1, death 4. Per-state authoring ceilings remain 4/6/4/2/6, at most 22 authored cells | Idle/move/attack/death must show distinct meaningful poses; hurt may reuse a pose plus flash. Duplicating the same image does not satisfy a multi-frame minimum |
| Two enemy animations | Per enemy minimum effective sequence frames: idle 1, move 2, attack/warning 1, hurt 1, death 3. Per-state ceilings remain 2/4/2/2/4, at most 14 authored cells | Idle/hurt/warning may reuse poses with clear tint or warning treatment. No invented attack for contact-only Thrall; record that state as not applicable and retain its existing contact/hit cue |
| Sword and magic | Each has 2–4 effective frames; distinct motion/impact poses; reuse by rotation, tint and replay where readable | Sword direction/impact and allied ownership; rotation applies to VFX, never actor bodies or an inaccurate warning boundary |
| Direction and total | One authored actor facing per state plus horizontal mirroring; no mandatory four-direction sheets. At most **58 unique authored animation frame cells** across three actors and two effects; mirrored copies and reused hurt poses count once | G1 must show up/down/left/right movement and attacks in normal/dense scenes. Failed recognition requires scoped corrections and a revised estimate; changes beyond the authorized budget/scope require user authorization; never rotate bodies to avoid drawing a facing |
| Timing | Existing starting targets: hero idle 6 FPS, move 10, attack/hurt 12, death 8; enemy/effect timing documented in plan against current cues | Visual playback never controls attack, damage, warning or removal timing |
| Shrine kit | At most 16 base tile designs and 6 modular props, plus one shared corruption overlay family | Ground, wall/arch fragments, shrine focal piece and reusable debris; no newly colliding props |
| UI reuse | One shared panel/button/border family; portraits initially crop gameplay art; static key art before bespoke menu animation | Shared components and state sheet; no per-screen decorative asset set |
| Lighting cost | Painted gradients and sprite-based shrine focus first; zero new dynamic lights/shadows/full-screen post effects/decorative particle layers by default. At most one optional shared shadowless light only through a measured reviewed plan | Readable painted/unlit comparison and matched SC-006 workload; no per-enemy lighting dependency or implied new effects settings menu |

Minimums describe effective frames in each applicable state sequence; ceilings count unique authored cells. Reuse/flash exceptions above are explicit, not missing feedback. The 58-cell total is a ceiling, not a promise of 58 new drawings. All five states require a manifest entry, with an evidence-backed not-applicable entry for states absent from gameplay. Art-production timing differences from historical placeholder targets must be reviewed in the future plan; gameplay timing cannot change, and interrupted animations need not finish every frame before gameplay proceeds.

### Design, Evidence and Scope Checkpoints

| Checkpoint | Required package | Execution rule |
| --- | --- | --- |
| G0 — Direction | Source audit, written direction/reference availability, style and cost rules | Record the working direction and actual decisions; continue in scope without routine sign-off. Missing-image comparison stays pending. |
| G1 — Slice mockups | FR-013 boards/strips, lineup, state/anchor/mirror/edge evidence, versioned protocol, exact eight-item list and budget | Check completeness and fix genuine dependent errors; proceed to scoped runtime work without owner/plan/tasks approval prompts. Preserve historical decisions. |
| G2 — Playable slice | Source/release captures, regressions, matched measurements, recognition/UI/latency results or explicit pending reasons | Keep automated, manual, performance and owner-feedback statuses separate. Continue unrelated in-scope tasks; no routine review STOP. Never waive unmet targets or reset failed baselines. |
| G3 — Remaining screens/assets | Separate scope, estimate and per-family design/evidence | Outside this eight-item task list; requires explicit scope authorization, not a routine phase sign-off. |

G0/G1 decisions recorded on 2026-10-16 and later owner feedback remain historical evidence.
Unavailable manual checks remain pending; measured budget failures remain failed.
Neither status blocks unrelated work or authorizes gameplay optimization, target relaxation or G3.

### Key Entities *(include if feature involves data)*

- **Visual Asset Record**: Asset/character/class ID, current source path, current evidence, placeholder/proposed/approved/integrated/verified status, planned replacement and retained fallback, reuse family, author/license, revision, canvas/visible-body bounds, ground anchor, state/direction/frame coverage and approval status.
- **Style Baseline**: Perspective, pixel scale, palette roles, outline/shading, type/spacing, animation conventions and effect hierarchy; associated revision shared by art and UI proposals.
- **Mockup Package**: Scope/revision, reference availability, boards/strips, target display sizes, cost estimate and corresponding requirements; never mislabeled as runtime evidence.
- **Approval Record**: Gate, package revision, named owner/reviewer, date, approve/revise/reject decision, permitted scope and outstanding conditions.
- **Acceptance Evidence**: Requirement IDs, build/version, fixture/seed/party, display and hardware conditions, actual checks, artifacts, results and pending human/performance criteria. Existing gameplay outcomes remain separate.

## Success Criteria *(mandatory)*

### Measurable Outcomes

The outcomes below define acceptance targets, not claims of completed tests. Current executed/failed/pending portions are recorded in the linked completion report and tasks.

- **SC-001**: Before dependent runtime work, all eight slice deliverables have versioned reviewable mockups, an exact scoped replacement list and documented style/protocol/budget decisions; there are zero runtime changes outside that scope. G0/G1 are evidence checkpoints, not owner-sign-off prerequisites. Actual owner decisions remain distinct from automated evidence. Covers FR-003/004/011–015/025; Story 1; G0/G1.
- **SC-002**: In a ten-person recognition review, at least eight participants correctly identify the hero, both enemy silhouettes, sword direction, friendly magic and dangerous area in each of normal, dense and maximum-corruption two-second excerpts at 2× and 3× viewing sizes. Record each answer; no aggregate pass may hide a failed condition. Covers FR-005–010/013/014; Story 2; G2. Score each item separately per condition and size, including each enemy identity: each cell requires 8/10. Direction excerpts use explicit up/down/left/right answers. Archive the predeclared fixture/answer key/raw responses; rerun affected conditions after sample revisions.
- **SC-003**: In ten-person screen review, at least eight can locate HP, distinguish permanent versus run level, identify the focused upgrade and state the cost/permanence of a promotion within five seconds per task without coaching. Exact costs/rewards and pending-versus-saved status have zero omissions against the existing contracts. Covers FR-016–020; Story 3; G1/G3.
- **SC-004**: Every scoped screen/state passes a three-size layout review with zero clipped essential labels, unreachable actions, color-only critical cues or missing disabled/focus states. The maximum nonmodal HUD occupies no more than 25% of the visible play area; text/icon contrast satisfies FR-019. Covers FR-016–020/023; Story 3; G1/G2/G3. Correct rectangle union does not waive field-edge/corner hero or warning occlusion; compare captures with the G1-approved P01 treatment, keeping unresolved choices pending.
- **SC-005**: Every planned production asset has source/status/provenance/reuse/state/approval records, selected native dimensions and anchor bounds. Every applicable animation meets the minimum effective-frame rules with documented reuse/not-applicable exceptions; the slice fits the 58-unique-authored-frame, 16-base-tile and 6-prop ceilings or receives an explicit revised estimate before production. No copied game artwork is delivered. Covers FR-002/007/008/014/015/021/022; Story 4; G1/G3.
- **SC-006**: In the unchanged representative workload of 100 ordinary enemies, one boss, two companions, at least 30 attack effects, 100 moving projectiles and 500 gems at maximum corruption, all three existing seeds meet p95 frame time ≤16.67 ms and p99 ≤25 ms after 30 active seconds of warm-up and 120 active seconds of capture each. Displayed input/hit feedback remains ≤100 ms. Use the inherited reference conditions; alternate hardware is supplemental evidence only. Covers FR-010/023/024; Story 2; G2. Existing results do not yet meet this target. Retain the inherited benchmark unchanged and separately test a workload deliberately exercising new sprites. Exact population P02 follows its versioned G1 record; record new/fallback counts for actors/arcs/stars, not just nodes. Approved supplemental runs use the same reference environment/seeds/durations/frame-time limits. Never substitute them for the inherited benchmark or infer new-effect coverage from procedural fillers.
- **SC-007**: Affected combat/progression/save/debug regressions show zero gameplay differences attributable to visual replacement for matching start snapshots, seeds and decisions; warnings retain existing geometry and minimum duration. The paired visual capture matrix and motion clips in FR-023 have zero unreviewed changed regions, missing critical cues or clipped essential UI, with all intended art changes traceable to the approved revision. Every unexecuted test or unmet target is explicitly pending. Covers FR-001/012/014/020/023/024; Stories 2–3; G2/G3.

## Assumptions

- Desktop keyboard/mouse and the existing Windows source/release validation path remain the initial audience. New platform support, localization, audio, controls and accessibility settings are not added by this visual feature.
- The user's descriptions of Concept Images 2/3 are sufficient to draft this specification. The actual images were not attached or identified by a readable local file path; their exact composition/palette is unknown. Resolving reference fidelity is a G0 dependency, not grounds to invent details or halt document preparation.
- Existing source and resources establish playable behavior; existing screenshots are historical audit evidence. This session does not establish fresh gameplay or performance results. See the [latest gameplay validation](../../docs/validation/convergence-2026-10-15.md) and [benchmark limitations](../../docs/benchmarks/m4.md).
- The existing art-direction note and provenance register may inform compatibility and asset reuse only. Neither substitutes for the first production direction review requested here; no prior visual approval is inferred.
- The owner remains the authority for genuine scope expansion and constitutional amendments. The plan records budgets, measurement conditions and production conventions; reviewers/decisions are named only when actually received. Routine task/phase/visual sign-off is not required.
- All existing screens receive design coverage, but only the representative slice is the first proposed production batch. Bosses, other enemies, all six character identities and six promotion branches remain planned later replacements; no full content expansion is authorized.
- Reference performance conditions are inherited from the gameplay plan: Windows 11, i5-8400, GTX 1050 Ti 4 GB, 16 GB RAM, SSD, 1920×1080/60 Hz, Compatibility release; measure uncapped workload and displayed feedback separately. The current host's historical measurements do not establish reference-machine acceptance.
- Exclusions: new mechanics, balance changes, added classes/enemies/maps, 3D, engine migrations, backend/paid gacha, new dependencies, code implementation and wholesale scene replacement in this step.


当前审批 / Approval update · 2026-10-16：owner `approve` 已登记为VD-01-M1的G0/G1及列明设计范围接受；历史pending不再是当前审批状态。[决定](../../docs/visual-design/APPROVALS.md)。Godot集成与G2/G3未完成。
