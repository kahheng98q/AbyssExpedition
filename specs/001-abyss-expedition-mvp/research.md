# Research: Abyss Expedition

**Date**: 2026-10-14. Research resolves technology/design decisions for the full MVP; only M1 is the next implementation scope. Sources are official Godot documentation. No gameplay was executed.

## 1. Stable engine and renderer

**Decision**: Pin the locally reported `4.5.stable.official.876b29033`, standard build, matching export templates, and Compatibility rendering. This satisfies Godot 4 stable without requiring the newest release. Existing project configuration says 4.7/Forward Plus/D3D12; reconcile it during M1 setup, validate import, and record the executable/version before proceeding.

**Rationale**: The Godot connector's `get_godot_version` returned the installed build. A project feature tag does not prove installed tooling. Compatibility is sufficient for this 2D workload and broadens hardware support, but does not prove performance.

**Alternatives**: Upgrade immediately to the current stable release; retain Forward Plus. Neither is necessary for the requested features. A later engine upgrade must update the pin, templates and replay evidence together.

**Source**: [Godot 4.5 renderer comparison](https://docs.godotengine.org/en/4.5/tutorials/rendering/renderers.html).

## 2. Content Resources and runtime ownership

**Decision**: Use typed custom Resource definitions and `.tres` content. Treat the catalog as immutable; keep health, counters, upgrades and owned progress in distinct runtime/profile models. Use explicit App/Expedition composition roots and native signals, with no autoload event bus.

**Rationale**: Godot caches loaded Resources and returns shared references. Mutating a definition could alter every instance. A small native composition boundary meets the active game requirements without a framework.

**Alternatives**: Hardcoded character-name branches; runtime JSON content; deep-duplicating every definition. These obscure validation or add unnecessary copying. `resource_local_to_scene` is available for deliberately local resources but does not replace state separation.

**Source**: [Resource caching and scene-local behavior](https://docs.godotengine.org/en/4.5/classes/class_resource.html).

## 3. Random generation and replay

**Decision**: Dedicated `RandomNumberGenerator` instances for wave types, spawn candidates, upgrade offers and M4 events; derive stream seeds with a versioned SHA-256 procedure. Stable catalog ordering and spawn-ID tie breaks. Tests inject integer random inputs for draw boundaries. Permanent draw state is separate from expedition streams and persisted with outcomes.

**Rationale**: Godot supports reproducible seeded sequences, but its algorithm is an implementation detail. Record engine/game/content version, seed, initial conditions and tick decisions. Validate random traces, not unsupported cross-version or cross-hardware physics lockstep.

**Alternatives**: Global random calls, reseeding per attack, or using the expedition seed for gacha. They couple unrelated systems or permit resetting permanent draws by changing run seed.

**Source**: [Godot RNG seed/state behavior](https://docs.godotengine.org/en/4.5/classes/class_randomnumbergenerator.html).

## 4. Simulation and pause

**Decision**: Fixed active ticks drive all gameplay deadlines. One coordinator owns pause-reason tokens and `SceneTree.paused`; modal UI continues processing. Gameplay signal handlers reject stale run IDs/invalid phases and defer otherwise valid world events while paused.

**Rationale**: Tree pause stops physics, but signals may still call methods on paused nodes. Tree flags alone cannot protect damage/pickups from stale callbacks. A small ordered update coordinator gives terminal/level/event/boss precedence without wall-clock leakage.

**Alternatives**: Each dialog toggles pause independently; visual animations drive damage; always-processing timers. These can resume through another modal, skip warnings, or advance cooldowns during choices.

**Source**: [Pausing games and process modes](https://docs.godotengine.org/en/4.5/tutorials/scripting/pausing_games.html).

## 5. Pixel scale and animation separation

**Decision**: 640×360 logical viewport, `viewport` stretch, keep aspect, integer scale, nearest textures. Art convention: 16-pixel terrain tiles, 32×32 hero frames, 64×64 boss; animations are presentation only.

**Rationale**: Godot supports integer viewport scaling for crisp pixel art. Numeric frame sizes are project choices. Keep continuous collision coordinates; inspect rendering and camera motion graphically at 2×, 3× and non-integer window dimensions.

**Alternatives**: Existing expand/canvas-items setup or arbitrary sprite scales. These complicate consistent logical pixel density and visual acceptance.

**Source**: [Multiple resolutions and pixel-art guidance](https://docs.godotengine.org/en/4.5/tutorials/rendering/multiple_resolutions.html).

## 6. Tests and command-line validation

**Decision**: Native GDScript test runner and fixtures, no plugin dependency initially. Import, parse all scripts, validate all content and instantiate scenes; run integration fixtures headlessly and real-window gameplay separately. Use an exported Windows release for performance acceptance.

**Rationale**: CLI supports `--import`, `--script`, `--check-only` with `--script`, and `--export-release`. Import alone does not instantiate every scene or establish graphical correctness. Runner must report failure with a nonzero exit and preserve engine error logs. Engine `--test` is not the project's gameplay suite.

**Alternatives**: Add a third-party test framework immediately, or call import a gameplay test. Neither is needed for the initial logic coverage. Reconsider a framework only for a demonstrated maintenance benefit.

**Source**: [Command-line tutorial](https://docs.godotengine.org/en/4.5/tutorials/editor/command_line_tutorial.html). Verify flags with pinned `--help`; Godot may ignore unknown flags.

## 7. Durable local state

**Decision**: Versioned JSON plus checksum, validated immutable save generations, retained prior recovery state and a single mutation writer. Prepare a complete candidate, write/read back/validate, then publish it by same-directory rename; only then acknowledge success. Preserve corrupt evidence and explicitly offer recovery.

**Rationale**: The specification needs all-or-nothing costs/results and retryable failures. Native `FileAccess`, `DirAccess`, JSON and hashing are sufficient. Generation selection avoids overwriting the sole valid profile and lets a crash resolve to the old or new complete state. Checksums detect accidental corruption, not cheating. Filesystem/OS power-loss durability is not assumed from an API name; verify process-interruption behavior and retain recovery generations.

**Alternatives**: Rewrite one JSON file, save only on exit, store draws separately from ticket spending, or use SQLite/cloud storage. These lose the required transaction boundary or add infrastructure. See [persistence contract](contracts/persistence.md) for exact commit/recovery semantics.

**Sources**: [FileAccess](https://docs.godotengine.org/en/4.5/classes/class_fileaccess.html), [DirAccess](https://docs.godotengine.org/en/4.5/classes/class_diraccess.html), [JSON](https://docs.godotengine.org/en/4.5/classes/class_json.html).

## 8. Performance and milestone boundaries

**Decision**: Use simple bounded registered lists and native collision first. Profile representative release workloads before pooling or spatial indexing. M1 has no persistent profile, companion, guild, event or corruption service; implement these at their own gates.

**Rationale**: The specified cap of 100 non-bosses makes an initial simple design reasonable, not proven fast. Complexity must be justified by measured conditions. Planning later schemas does not justify building them early.

**Alternatives**: ECS, universal effects interpreter, preallocated pools for every entity, or an all-milestone scaffold. These increase early verification scope without helping the independent slice.

## Resolution status

Engine, renderer, persistence strategy, replay boundary, native test approach, art scale and benchmark target are resolved. Balance values absent from the specification are declared initial tuning proposals in the data model. Hardware performance, graphical behavior and human success criteria remain unmeasured implementation acceptance work, not unresolved planning questions.
