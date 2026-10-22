# Implementation Plan: Run Level Promotion

Date: 2026-10-22 · [Spec](spec.md) · Branch unchanged (feature path selection only).

## Summary
Replace permanent growth with ownership-only schema 4, preserve local collection economy, and make shared run level 15 trigger ordered per-member promotion through existing preview UI. Implement persistence first, then run logic/UI/debug, then regression/evidence. No network or new dependencies.

## Technical Context
Godot 4.5 pinned `4.5.stable.official.876b29033`, GDScript, native scenes/Resources; offline Windows desktop. Existing ProfileStore/SaveCoordinator provide immutable generations, checksum, lock, frozen retry and preserved legacy sources. Tests use native SceneTree runner and isolated user://tests roots with separate APPDATA. Scope: six heroes, three base classes, six unchanged branches, party <=3. Existing curve 100*level retained. Art: 640x360 logical viewport, nearest integer scaling, 32px heroes, existing sword renderer/previews and 360-tick example loop untouched. No performance acceptance claimed: existing 60FPS/p95<=16.67ms target and historical unmet evidence remain; promotion runs only at choice boundaries with <=3 candidates, no growing per-frame searches.

## Constitution Check
| Principle | Before / after design | Reason |
| --- | --- | --- |
| I Gameplay first | Compliant / compliant | Existing combat slice, reachable paused choices and restart preserved; human playability acceptance explicit. |
| II Modular | Compliant / compliant | Profile migration, promotion mutation, choice arbitration and UI remain separate. |
| III Original IP | Compliant / compliant | Existing original assets/renderers; no new artwork. |
| IV Testable | Compliant / compliant | Threshold, all branches, failures, migration, replay, debug and export checks. |
| V Pixel art | Compliant / compliant | Keep existing sword rendering and example lifecycle; inspect actual graphical output. |
| VI Performance | Compliant / compliant | Bounded party, deterministic action trace/version bump, no balance changes or performance claims. |
| VII Scope | Compliant / compliant | User explicitly authorizes replacing growth; only affected source/tests/docs; old specs untouched. |
| VIII Incremental | Compliant / compliant | Persistence checkpoint then integrated run checkpoint, logs and docs each phase; blockers fixed before advancing. |

## Project Structure
- `scripts/persistence/`: schema4 validator/migrations/loader; unchanged publication service.
- `scripts/progression/`: ownership record, settlement economy, run promotion service, unchanged XP curve.
- `scripts/characters/`: base snapshots/stats and run-only profession application.
- `scripts/core/choice_coordinator.gd`, `run_manager.gd`, `app_router.gd`, `replay_trace.gd`: ordered arbitration and guarded routing.
- `scripts/ui/`: promotion live eligibility, gallery-only preview outside runs, HUD reopen and honest roster/guild/selection/results.
- `scripts/debug/`: existing action IDs adapted to shared XP/eligibility; branch testing remains debug-only and no saved branch.
- `tests/unit/`, `tests/integration/`: update obsolete expectations; new focused run_promotion suite and graphical test.
- `docs/validation/run-level-promotion/`: new logs/results, no historical log overwrites.

## Phase 0 Research
Read actual factory/snapshots, profile v1-v3 validators/loader, coordinator/simulation, App modal routing, DEV service/panel, preview lifecycle, tests and historical 001/003 requirements. Decisions in [research.md](research.md). No unknown technical dependencies or network research required.

## Phase 1 Design
[Data model](data-model.md), [UI/logic contracts](contracts/run-promotion.md), [quickstart](quickstart.md). Shared level is authoritative. Fresh snapshots always base/1 even when supplied with obsolete member fields. Actor class switches rebuild immutable starting baseline, then derive upgrades/contracts, preserve HP ratio and identity counters. Run stores branches by character identity so remove/readd cannot re-pick. ChoiceCoordinator owns offer nonce and promotion pause token. Existing choice completes before another; at idle promotion takes priority, then upgrades, then scheduled events. Cancel sets deferred flag until explicit HUD reopen; no RNG used by promotions. Signals routed with generation and nonce. Schema4 records only character_id; reject obsolete live growth keys. Validate legacy before stripping. Migration result retains previous receipt. Loader uses ordered version steps (avoid resetting schema3 chapter flag), same writer retry. Replay simulation version changes to reject old behavior recordings.

## Validation and Checkpoints
1. Setup spec/checklist/design/tasks; verify prerequisites without branch scripts.
2. Write migration assertions, implement schema and settlement/base starts, run focused progression/persistence + protected debug; where debug still expects old behavior, record and resolve in next integrated checkpoint before full green claim.
3. Write run threshold/arbitration tests, implement coordinator/UI/DEV together, run focused run_promotion/abilities/integration_m2/debug/replay.
4. Run `powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_validation.ps1 -M4 -Graphical -Export -DummyAudio -EvidenceDirectory <new path> -BuildDirectory <new path>`. Preserve failed attempts, fix affected tests/logic, rerun only affected gates as appropriate. Add focused graphical promotion check and actual release debug denial.
5. Update dashboard/overview/README/development/debug notes and new results; check local references. Human feel/readability and performance remain pending unless actually executed/measured.

## Complexity Tracking
No exceptions, dependencies or general-purpose framework added. Existing historical fixture APIs may keep ignored XP/branch arguments for source compatibility only; production paths cannot use them to grow a profile.

## Execution outcome

Core implementation, 17 native suites and source/debug/release controlled graphics passed. Full command not green: native real-clock focus/early-exit probe incomplete; tasks T016/T018 remain open. Actual commands, failed attempts, source/build hashes and unexecuted human/performance checks: [results](../../docs/validation/run-level-promotion/results.md).
