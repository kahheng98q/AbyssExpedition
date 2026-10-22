# Tasks: Run Level Promotion

Created 2026-10-22. Requirements checklist: 16 checked / 0 open; quality PASS, not implementation acceptance. User authorizes complete offline implementation without branch/commit or manual approvals. No extensions.yml hooks present. Tasks below remain open until actual completion.

## Phase 1 Setup
- [x] T001 Read AGENTS.md, constitution, four Spec Kit skills, templates, historical specs and affected actual source/tests; establish `specs/004-run-level-promotion/spec.md` and `checklists/requirements.md` (FR-001–010).
- [x] T002 Create design `specs/004-run-level-promotion/plan.md`, research.md, data-model.md, contracts/run-promotion.md, quickstart.md and `.specify/feature.json`; resolve templates without branch change.

## Phase 2 US1 - Safe fresh starts (P1)
Independent test: old-save migration, unchanged unrelated values, fault/retry and BASE starts, no permanent settlement growth.
- [x] T003 [US1] Write migration/settlement/start regressions in `tests/integration/test_run_promotion.gd`, `tests/unit/test_permanent_progression.gd`; register `tests/run_tests.gd`.
- [x] T004 [US1] Implement ownership-only schema4 and ordered migrations in `scripts/persistence/profile_data.gd`, profile_migrations.gd, profile_validator.gd, profile_loader.gd. Preserve prior receipt and atomic publication/retry (FR-002).
- [x] T005 [US1] Remove permanent settlement XP/materials in `scripts/progression/permanent_progression.gd`, owned_hero.gd; base/1 snapshots and unscaled stats in `scripts/characters/roster_service.gd`, character_factory.gd and `scripts/core/run_start_snapshot.gd` (FR-001/003).
- [x] T006 [US1] Adapt obsolete save/economy assertions in `tests/integration/test_persistence_v1.gd`, test_persistence_v3.gd, test_m3_rescue.gd, test_m3_draws.gd; execute pinned Godot import and progression/persistence checkpoint, record `docs/validation/run-level-promotion/results.md` and mandatory docs.

## Phase 3 US2 - Run promotion (P1)
Independent test: Lv14/15 for all heroes/branches, multi-member serialization, cancellation/reopen, stale/invalid, modifiers/HP, late join, seeded trace and reset.
- [x] T007 [US2] Write threshold/arbitration/replay/live HP tests in `tests/integration/test_run_promotion.gd`, `tests/unit/test_promotion.gd` before implementing corresponding behavior.
- [x] T008 [US2] Implement run branches map in `scripts/progression/run_progression.gd`, run-only service in promotion_service.gd, live stat derivation in `scripts/characters/character_factory.gd` (FR-004/006; branches lifetime one run, shared level>=15).
- [x] T009 [US2] Serialize promotion choices and nonce/pause/cancel/reopen in `scripts/core/choice_coordinator.gd`, run_manager.gd, app_router.gd; bump replay version in replay_trace.gd (FR-005/007/008).
- [x] T010 [US2] Bind live eligibility and read-only gallery in `scripts/ui/promotion.gd`; add HUD reopen in combat_hud.gd; retain preview renderer/lifecycle and combat visual rules (FR-005/009).
- [x] T011 [US2] Update affected gameplay fixtures/assertions in `tests/unit/test_profession_abilities.gd`, test_companions.gd, `tests/integration/test_m2_party.gd`, test_m2_app.gd, test_replay.gd, test_promotion_preview.gd; run focused checkpoint and update mandatory docs/evidence.

## Phase 4 US3 - UI and protected DEV (P2)
Independent test: honest growth text; F9/DEV single instance in menus/run/promotion/results/restart, sandbox mutation/retry and actual release denial.
- [x] T012 [US3] Update roster/guild/selection/results/HUD text in `scripts/ui/roster.gd`, guild.gd, character_selection.gd, run_results.gd, combat_hud.gd (FR-009).
- [x] T013 [US3] Adapt existing level/XP/material/eligibility action IDs to run XP and late joins in `scripts/debug/debug_action_service.gd`, debug_panel.gd; preserve single scene, sandbox and guards (FR-010).
- [x] T014 [US3] Adapt explicit protected regressions in `tests/integration/test_debug_panel.gd`, `tests/debug_graphical_check.gd`, `tests/debug_release_probe.gd`, preview/graphical fixtures where growth setup is obsolete; keep all unrelated checks.
- [x] T015 [US3] Add actual paused promotion graphical input/layout check in `tests/run_promotion_graphical_check.gd` and `tools/run_validation.ps1`; execute protected debug and focus/layout checkpoints, update `docs/developer-debug-panel.md`.

## Phase 5 Cross-cutting validation and documentation
- [ ] T016 Execute pinned full M4 regression + graphical/export via `tools/run_validation.ps1` with new `docs/validation/run-level-promotion/` evidence and `builds/windows/run-level-promotion/` outputs; record failures/fixes/actual results, release denial, unexecuted human checks in results.md.
- [x] T017 Update `docs/game-development-dashboard.html`, `docs/IMPLEMENTATION_OVERVIEW.md`, `README.md`, `docs/development.md`, `docs/developer-debug-panel.md` with truthful run-only semantics, quick play and evidence; verify offline asset paths/links; audit `specs/004-run-level-promotion/tasks.md` against actual evidence.
- [ ] T018 Perform human natural run Lv15/playability/readability acceptance per `specs/004-run-level-promotion/quickstart.md`; leave open if not actually executed and record limitations in `docs/validation/run-level-promotion/results.md`.

## Dependencies and execution strategy
T001->T002->US1->US2->US3->T016/T017. T018 is independent human acceptance, never inferred from test counts. MVP is US1+US2; all requested source and regression work remains required. No parallel agents: design unknowns resolved locally. Independent read/search calls may run in parallel; shared source changes sequential. Each source checkpoint updates docs and fixes parse/runtime failures before advancing. Setup script reported a terminal encoding failure; rerun with PYTHONIOENCODING=utf-8, output retained in task-template-resolution.json. No user decision needed.

Checkpoint: run_promotion 128, persistence 343, abilities 682 and integration_m2 97 passed in focused-v2/v3/v4 respectively. Debug adaptations implemented; full-v2 verification pending. Full source logs retain earlier fixture/environment failures. T015/T016 await actual graphical/export results; T018 remains human-only.

Final verification note: all 17 native suites have passing evidence across incremental commands (latest total 10,152); new JSON replay and atomic pause handoff pass. Source ordinary preview ten real cycles passed in graphics-export-v7; DEV1x lost native focus and reached its unchanged 150-second deadline. T016 remains open until final-v8 evidence and focus limitations are audited; no pass is inferred for blocked/unexecuted groups.

Final audit (2026-10-22): 16/18 tasks completed. T015 source36 / exportedDebug36 / actualRelease30 promotion graphics passed, source/exportedDebug DEV116 passed, actualRelease denial41 passed; sword source/debug720 and release699 passed. T017 required documents and offline links audited. T016 remains OPEN: final-v9 full graphical/export command exited1 at the final native realtime probe (exit0 with resource errors, completed=false, six partial cycles); prior source-normal ten cycles passed, DEV1x focus deadline failed, other timed combinations unexecuted. T018 remains OPEN: human/natural-Lv15 acceptance and this feature's performance are unexecuted. See docs/validation/run-level-promotion/results.md and verification-index.json. No partial invalid production code or failing core logic/controlled-graphics test remains; do not call complete acceptance.
