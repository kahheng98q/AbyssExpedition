<!--
Sync Impact Report (temporary review note; remove before committing):
Version change: unratified scaffold -> 1.0.0 (initial adoption).
Modified principles: placeholder principles replaced by the eight project principles below.
Added principles: I. Gameplay First; II. Modular Game Architecture;
III. Original Intellectual Property; IV. Testable Development; V. Consistent Pixel Art;
VI. Performance and Maintainability; VII. Scope Control; VIII. Incremental Delivery.
Added sections: Game Identity and Project Constraints; Spec Kit Workflow and Quality Gates;
concrete Governance rules.
Removed sections: none; unused scaffold examples and placeholders removed.
Compatibility review: specify, plan, tasks, implement, and analyze skills already load this
constitution. The plan template already requires a Constitution Check. Generic template
examples, including optional tests and online infrastructure, yield to this constitution.
Dependent templates and commands: reviewed; no modifications required.
Deferred TODOs: none. Feature-specific numeric art and performance targets belong in plans.
-->

# Abyss Expedition Constitution

## Core Principles

### I. Gameplay First

- Development MUST prioritize responsive controls, enjoyable combat, and clear visual feedback.
  Each gameplay specification MUST define observable acceptance criteria for these qualities.
- A playable vertical slice of the expedition loop MUST be implemented and verified before
  expanding the roster, content catalog, recruitment, promotion, or gacha systems. Its active
  specification MUST define a bounded demonstration of movement, automatic combat, enemy
  encounters, random level-up choices, and a run ending with a restart path.
- Work MUST proceed through prioritized increments. Developers MUST NOT implement all planned
  systems simultaneously or treat the long-term vision as an implementation backlog.

Rationale: a verified core loop establishes whether further content will improve the game.

### II. Modular Game Architecture

- Player controls, combat, enemies, AI, skills, character data, professions, progression,
  recruitment, gacha, saves, and UI MUST have distinct responsibilities and explicit interfaces
  as they are introduced. Their separation does not authorize building unused modules early.
- Scripts MUST NOT combine unrelated responsibilities into a single central implementation.
  Presentation MUST consume gameplay state through defined interfaces rather than owning
  combat, progression, or persistence rules.
- Character, profession/class, enemy, weapon, and skill definitions MUST use data-driven
  structures. Shared mechanics MUST operate on identifiers, capabilities, and configuration,
  never on individual character display names or name-specific conditionals.
- Reusable logic MUST be independently exercisable where feasible. New abstractions MUST
  address an active requirement rather than speculative future needs.

Rationale: stable boundaries allow new characters and mechanics without rewriting the core loop.

### III. Original Intellectual Property

- Characters, names, maps, sprites, and user interfaces MUST be original to Abyss Expedition.
  Developers MUST NOT copy Pokémon or Fire Emblem assets, characters, maps, or interface art.
- Referenced games MAY inform mechanics and readability goals. Their branding and distinctive
  visual content MUST NOT be reproduced.
- Lovecraftian creatures and cosmic-horror themes MAY inspire the world, but their artistic
  interpretations, names, and designs MUST be original to this project.
- Temporary placeholder graphics MAY be used during prototyping. They MUST be identified as
  placeholders, be permissible to use, and have a documented replacement path before release.
  Copied franchise assets MUST NOT be used as placeholders.

### IV. Testable Development

- Every feature MUST have clear acceptance criteria, including relevant boundary conditions
  and failure cases, before implementation begins.
- Automated tests MUST cover logic where feasible, including applicable damage calculations,
  progression, promotion eligibility, recruitment/gacha selection, seeded generation, and save
  round trips. Any omitted automation MUST have a documented limitation and an alternative
  verification procedure; a generic template marking tests optional is not a waiver.
- After each implementation phase, developers MUST execute available Godot validation
  appropriate to the change, such as project import/parsing, headless checks, logic tests, and
  scene/runtime checks. Changed gameplay and visuals MUST also receive a playable check when
  the required runtime is available.
- Test reports MUST state the command or procedure actually executed, its result, and any
  relevant seed or environment. Written tests, static inspection, and planned checks MUST NOT
  be reported as executed tests.
- Unavailable tools, unexecuted checks, failures, and testing limitations MUST be recorded.
  An unverified acceptance criterion MUST remain explicitly unverified.

### V. Consistent Pixel Art

- Before producing reusable art, the active plan MUST establish and document the base sprite
  scale, pixel density, animation timing conventions, and rendering style. Later assets MUST
  follow those conventions or explicitly update the shared art direction through review.
- Pixel-art rendering MUST preserve consistent pixel scale and crisp sampling. Gameplay
  reviews MUST check silhouettes, attack direction and impact, animation responsiveness, and
  readability against backgrounds and dense enemy groups.
- Interfaces MUST remain compact and avoid unnecessary text. Essential choices, status,
  controls, and outcomes MUST remain legible; compactness MUST NOT obscure gameplay information.
- Prototype placeholders MAY simplify art, but MUST preserve the readability needed to verify
  gameplay and MUST NOT silently establish conflicting production conventions.

### VI. Performance and Maintainability

- The game MUST target smooth play with many enemies on screen. Plans for spawning, combat,
  or visual effects MUST define a measurable frame-time/FPS target, representative enemy and
  effect counts, and a reference environment before claiming performance acceptance.
- Spawning, damage handling, AI updates, and effects MUST avoid obvious unnecessary per-frame
  allocations, repeated full scene-tree searches, and uncontrolled node/effect growth.
- Developers MUST measure identified bottlenecks before adding complex optimizations. Pooling,
  caching, or other strategies MUST be justified by the current workload and remain maintainable.
- Procedural generation and random selection MUST support explicit seeds where reproducibility
  is applicable. Validation MUST record seeds and relevant inputs; equivalent inputs under the
  same implementation MUST reproduce the tested random sequence or generated result.

### VII. Scope Control

- Multiplayer, real-money purchases, user accounts, external servers, and unnecessary online
  services MUST NOT be introduced. Gameplay and persistence MUST operate locally and offline.
- Character collecting and gacha, when specified, MUST use in-game resources and local systems;
  their presence in the vision does not authorize monetization or backend infrastructure.
- Developers MUST implement only features within the active specification. New ideas MUST be
  deferred or added through an explicit specification update before implementation.
- New work MUST preserve working features. Changes to existing behavior MUST be identified in
  the specification and verified against the affected acceptance criteria.

### VIII. Incremental Delivery

- Each implementation phase MUST end in a playable or verifiable project state with a defined
  checkpoint and evidence of its outcome. Setup phases MAY deliver a validated project rather
  than playable gameplay.
- Blocking import, parse, runtime, test, or integration errors MUST be fixed before proceeding
  to the next implementation phase. Missing validation tooling MUST be reported as a limitation,
  never as a passing check.
- Project setup, run instructions, test instructions, and developer documentation MUST be
  updated whenever a phase changes them. Required engine versions, dependencies, and relevant
  seeds/configuration MUST be documented sufficiently to reproduce the checks.

## Game Identity and Project Constraints

Abyss Expedition is an original 2D pixel-art fantasy roguelite built in Godot. Its setting is an
original medieval fantasy world invaded by cosmic horror. Its design direction combines
survivor-style real-time combat, automatic attacks, random level-up choices, character recruitment,
branching class promotion inspired by Fire Emblem GBA, and character collecting with local gacha.
These are design inspirations and future capabilities, not a requirement to build them together.

The active feature specification MUST bound each increment. Engine/version requirements, target
platforms, numeric art conventions, and performance budgets MUST be recorded in the relevant plan
and developer documentation as they are selected. This constitution does not authorize changing
project settings, implementing gameplay, or adding dependencies by itself.

## Spec Kit Workflow and Quality Gates

Every later Spec Kit phase MUST read `.specify/memory/constitution.md` and apply its current version.
Generic template examples MUST be replaced with requirements appropriate to this Godot game;
examples involving accounts, web APIs, servers, or optional tests MUST NOT override these rules.

- **Specify and clarify:** define the active scope, prioritized player scenarios, measurable
  acceptance criteria, relevant failure cases, and explicit exclusions. Before the vertical
  slice passes its acceptance checks, feature scope MUST support that slice rather than expand
  secondary systems or content catalogs.
- **Plan:** populate the Constitution Check before research and recheck it after design. Review
  all eight principles; record each as compliant, noncompliant, or not applicable with a reason.
  Document system boundaries, data definitions, verification procedures, relevant art conventions,
  performance targets, and seed handling. Noncompliance MUST be resolved before implementation;
  placing it in Complexity Tracking does not authorize an exception.
- **Tasks:** map implementation and verification tasks to acceptance criteria. Order work by
  dependency and player value, include feasible logic tests, and give every implementation phase
  a Godot validation checkpoint and required documentation updates. Do not create speculative
  infrastructure for systems outside the active specification.
- **Analyze and converge:** check specifications, plans, tasks, and implemented behavior against
  this constitution. Constitution conflicts MUST be treated as blocking findings; missing work
  MUST be recorded within the active feature scope rather than silently broadening it.
- **Implement:** execute the active tasks incrementally. At each checkpoint, perform the planned
  checks, preserve existing functionality through relevant regression checks, record results
  and limitations, and fix blockers before moving on. Completion claims MUST distinguish
  implemented work from verified behavior and identify any outstanding acceptance criteria.

## Governance

This constitution is the authoritative project policy for specifications, planning, tasks,
implementation, and review. Templates and generated artifacts MUST conform to it. Reviewers MUST
check all applicable principles and require evidence for acceptance and test claims.

Amendments MUST state the proposed change, its rationale, impact on active artifacts and working
features, and any migration steps. The project owner MUST authorize changes to established
principles. Amendments MUST update this file, its version and amendment date, and identify affected
specifications, plans, tasks, templates, and documentation for synchronization. Conflicts MUST be
resolved by changing dependent artifacts or by an explicit approved constitutional amendment;
silent exceptions and weakening principles during implementation are prohibited.

Versions follow semantic versioning: MAJOR for incompatible principle removals or redefinitions;
MINOR for new principles or materially expanded guidance; PATCH for clarifications and corrections
without changed obligations. Initial adoption is version 1.0.0. The original ratification date
MUST remain unchanged in subsequent amendments.

**Version**: 1.0.0 | **Ratified**: 2026-10-14 | **Last Amended**: 2026-10-14
