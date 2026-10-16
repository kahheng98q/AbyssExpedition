# Gameplay and Milestone Requirements Checklist: Abyss Expedition

**Purpose**: Validate requirement completeness, clarity, consistency, observable acceptance, and milestone independence for gameplay, class promotion, recruitment, gacha, persistence, and testing.
**Created**: 2026-10-14
**Feature**: [spec.md](../spec.md)
**Depth / audience / timing**: Standard review with emphasis on state integrity and milestone gates; author/reviewer before task generation and implementation.

**Note**: Generated using `$speckit-checklist` from the feature specification, plan, data model, system/UI/persistence contracts, quickstart, and constitution 1.0.0. The user's request explicitly includes evaluation; the findings below are document-review evidence.
**Review Ownership**: This is a reviewer-owned requirements-quality artifact. Mark `[x]` only when the reviewer determines that the requirement-quality criterion is satisfied.
**Marker Semantics**: `[x]` means requirements quality has been reviewed and satisfied, not that implementation is complete. All generated items remain unchecked; the assessment below does not change checkbox ownership.

## Requirement Completeness

- [ ] CHK001 Are the M1 starter roster, field boundary, keyboard movement, automatic attacks, and offline single-player scope explicitly defined? [Completeness, Spec §FR-001–FR-003; §FR-014]
- [ ] CHK002 Are wave timings, enemy composition, guaranteed behavior introductions, spawn warnings, capacity/safety exceptions, and boss transition fully specified? [Completeness, Spec §FR-004; §Initial spawn defaults]
- [ ] CHK003 Are XP thresholds, overflow, three-choice eligibility, upgrade caps, fallback choices, previews, and temporary-state reset requirements documented? [Completeness, Spec §FR-005–FR-007; §Initial upgrade catalog]
- [ ] CHK004 Are damage, defense, invulnerability, susceptible-target knockback, projectile expiration, and target-loss requirements defined? [Completeness, Spec §FR-003; §FR-008; §Targeting defaults; Data model §Combat math and counters]
- [ ] CHK005 Are permanent XP rewards, level thresholds/cap, starting-stat bonuses, participant eligibility, and victory-item grants explicit and separate from run growth? [Completeness, Spec §FR-016–FR-017; §Progression boundary]
- [ ] CHK006 Are both branches for each base class defined with permanent eligibility/cost, preview, changed attacks/effects/visual identity, and passive continuity? [Completeness, Spec §FR-018–FR-020; §Promotion catalog]
- [ ] CHK007 Are every hero's acquisition route, fresh ownership, guaranteed rescue, failure/repeat rewards, and next-run availability requirements documented? [Completeness, Spec §FR-025–FR-028; §Additional hero catalog; §Rescue/reward defaults]
- [ ] CHK008 Are draw costs, pool/odds, independence, ordered duplicate conversion, exchange, balances, history, and interrupted-reveal requirements complete? [Completeness, Spec §FR-029–FR-034]

## Requirement Clarity

- [ ] CHK009 Is the result's kill-count definition explicit about boss kills and other deaths in the terminal simulation tick, consistent with summary finalization? [Clarity, Ambiguity, Spec §Run outcome contract; Systems §Tick ordering and arbitration, steps 2–3]
- [ ] CHK010 Are matching replay conditions, accepted seed limits, random-stream isolation, and the distinction between repeatable random outcomes and unchanged permanent progress clear? [Clarity, Spec §FR-012; §FR-034; §SC-011; Systems §RNG contract]
- [ ] CHK011 Are pause reasons, queued choices, terminal precedence, boss-entry ordering, and active-time semantics unambiguous? [Clarity, Spec §Level-up pause defaults; §Edge Cases; Systems §Tick ordering and arbitration]
- [ ] CHK012 Are companion following priority, formation/recovery distances, safe relocation, downing, outgoing damage scale, and shared upgrade/reward semantics quantified? [Clarity, Spec §FR-021–FR-022; §Companion defaults; §Progression boundary]
- [ ] CHK013 Are promotion/passive counters defined per fired activation, including no-target, extra arcs/projectiles, fifth-effect overlap, and reset behavior? [Clarity, Spec §Promotion defaults; §Targeting defaults; Data model §Combat math and counters]
- [ ] CHK014 Are rescue-zone placement, inclusive boundary, continuous duration, pause behavior, exit/death failure, and settlement timing explicit? [Clarity, Spec §FR-027; §Rescue/reward defaults]
- [ ] CHK015 Are gacha guarantees stated without implying pity, ownership-dependent odds, paid resources, or an expedition-seed reroll path? [Clarity, Spec §FR-030–FR-034; §Assumptions]
- [ ] CHK016 Are provisional promotion effect strengths/durations distinguished from approved values, with an explicit requirement to finalize them before M2 implementation? [Clarity, Assumption, Spec §Promotion catalog; §Promotion defaults; Data model §Initial tunable combat defaults]

## Requirement Consistency

- [ ] CHK017 Are fixed enemy schedules/stats consistent with permanent progression, promotions, party size, and the explicitly allowed corruption modifiers? [Consistency, Spec §FR-004; §FR-036; Plan §Dependency and implementation order]
- [ ] CHK018 Are hero ownership, passive introduction, branch reuse, and exactly-six-hero scope consistent across milestone catalogs and schemas? [Consistency, Spec §FR-019–FR-020; §FR-025; Data model §Resource definitions]
- [ ] CHK019 Are M3's repeat rescue and M4's owned/unowned event schedules explicitly reconciled with prior acceptance and regression obligations? [Consistency, Spec §Additional hero catalog; §Event contract; §SC-012]
- [ ] CHK020 Are permanent mutation completion, UI continuation, same-candidate Retry, and interrupted reveal consistent across specification and persistence/UI contracts? [Consistency, Spec §Save/load contract; Persistence §Permanent action protocol; UI §Screen contracts]

## Acceptance Criteria Quality

- [ ] CHK021 Does M1 have observable criteria for a complete solo loop, distinct starters, upgrades, danger/feedback, victory/defeat/retry, duration, and reproducibility? [Measurability, Spec §Stories 1–3; §FR-001–FR-014; §SC-001–SC-004; §SC-010–SC-011]
- [ ] CHK022 Does M2 have observable criteria for XP/caps, promotion eligibility/consumption, branch/passive distinctions, companions, and durable reopening? [Measurability, Spec §Stories 4–5; §FR-015–FR-023; §SC-005]
- [ ] CHK023 Does M3 have observable criteria for exact roster/routes, guaranteed rescue, ticket boundaries, odds/costs, duplicates/exchange, and interruption integrity? [Measurability, Spec §Stories 6–7; §FR-024–FR-034; §SC-006–SC-007]
- [ ] CHK024 Does M4 have observable criteria for thresholds/bargains, event timing/variation, chapter completion, offline play, and earlier-flow regression? [Measurability, Spec §Stories 8–9; §FR-035–FR-042; §SC-008–SC-009; §SC-012]
- [ ] CHK025 Are qualitative responsiveness, readability, variety, and enjoyment claims tied to defined thresholds, samples, workloads, and environments? [Measurability, Spec §SC-001–SC-003; §SC-008; §SC-010; Plan §Performance and benchmarks; Quickstart §Human and performance acceptance]

## Scenario and Edge Case Coverage

- [ ] CHK026 Are primary, alternate, exception, and recovery requirements present for outcomes/abandonment, overlapping pauses, exhausted offers, simultaneous death, and invalid seeds? [Coverage, Spec §Edge Cases; §Run outcome contract; §Level-up pause defaults]
- [ ] CHK027 Are promotion cancellation/repeated confirmation, level/item boundaries, companion downing/separation, and active-hero death with surviving companions addressed? [Coverage, Spec §Stories 4–5; §Edge Cases; §Companion defaults]
- [ ] CHK028 Are rescue decline/failure/success-then-defeat, owned/unowned draws, in-batch duplicates, insufficient balances, and repeated spending inputs addressed? [Coverage, Spec §Stories 6–7; §Edge Cases; §FR-028–FR-034]
- [ ] CHK029 Are initial creation, selection saves, failed writes, unchanged Retry, process interruption, corrupt recovery, no valid recovery, incompatible versions, migration, and competing writers specified? [Coverage, Spec §Save/load contract; Persistence §Failure, retry and load state machine; §Required failure-injection matrix]

## Non-Functional Requirements

- [ ] CHK030 Are exact numeric save-size/integer limits and history/generation retention rules specified so oversized input, overflow, and long-lived local storage have measurable boundaries? [Completeness, Gap, Persistence §Files and schema; §Validation and migrations; Data model §Persistent profile]
- [ ] CHK031 Are original/permissible placeholder provenance, pixel scale, animation conventions, shape-based cues, keyboard focus, and deferred platform/accessibility scope documented? [Completeness, Spec §FR-013; §Assumptions; Plan §Art and animation conventions; Constitution §III; §V]
- [ ] CHK032 Are performance requirements tied to enemy/effect/projectile/gem counts, frame-time thresholds, a reference environment, measurement duration, and honest unavailable-tool reporting? [Measurability, Plan §Performance and benchmarks; Quickstart §Human and performance acceptance; Constitution §VI]

## Dependencies and Milestone Independence

- [ ] CHK033 Is M1 explicitly defined as runnable with fixed starters and in-memory state, without M2–M4 saves, passives, promotions, companions, guild, gacha, events, or corruption? [Dependencies, Spec §FR-014; §Starter catalog; Plan §Scene hierarchy and ownership; Persistence §Effective from M2]
- [ ] CHK034 Are M1 data references, startup validation, screen routes, and test suites limited to its own content/services, rather than requiring later schemas/assets or save stubs? [Dependencies, Spec §FR-014; Data model §Scope; Plan §Scene hierarchy and ownership; Quickstart §Automated suites]
- [ ] CHK035 Are coins consistently introduced only with M4 merchant/events rather than being required in M3's runtime model? [Consistency, Conflict, Spec §Event contract; Data model §Runtime records and lifetimes, RunState row; §Corruption/event snapshots]
- [ ] CHK036 Are M2 gated on accepted M1, M3 on accepted M2, and M4 on accepted M3, with verifiable checkpoints and no reverse dependencies? [Dependencies, Spec §Delivery Scope and Dependencies; Plan §Dependency and implementation order]
- [ ] CHK037 Are M2 Abyss-themed classes independent of corruption and M3 rescue independent of M4's generic event framework? [Dependencies, Spec §Promotion catalog; §FR-027; Plan §Dependency and implementation order; Data model §RescueDefinition]

## Testing Requirements and Traceability

- [ ] CHK038 Are all FR-001–FR-042 and SC-001–SC-012 mapped to appropriate automated, graphical, human, or performance evidence, including boundary/failure/recovery coverage? [Traceability, Quickstart §Automated suites; §Human and performance acceptance; §Evidence and gate reporting; Persistence §Required failure-injection matrix]
- [ ] CHK039 Is the subsequent tasks artifact required to map implementation and verification to acceptance criteria, include each phase's validation/docs checkpoint, and keep later tasks gated? [Traceability, Constitution §Spec Kit Workflow and Quality Gates; Plan §Project Structure; §Dependency and implementation order; Gap: tasks.md not yet generated]
- [ ] CHK040 Are isolated save fixtures, reproducible seeds, failure/nonzero-exit reporting, missing-tool limitations, and the distinction between planned/document checks and executed gameplay tests explicit? [Completeness, Quickstart §Import, parsing, content and scene validation; §Automated suites; §Evidence and gate reporting; Constitution §IV; §VIII]

## Notes

- Mark items `[x]` only after reviewer approval of requirements quality. Leave unresolved or unevaluated items unchecked.
- `$speckit-implement` reads checklist state as a gate and must not modify markers.
- `checklists/requirements.md` has a separate built-in lifecycle maintained by `$speckit-specify` and `$speckit-clarify`.
- References use actual document heading names and FR/SC IDs. Supporting links: [plan](../plan.md), [data model](../data-model.md), [systems](../contracts/systems.md), [persistence](../contracts/persistence.md), [UI](../contracts/ui.md), [quickstart](../quickstart.md), [constitution](../../../.specify/memory/constitution.md).

### Requirement review assessment — 2026-10-14

This review assesses written requirements only. No Godot execution, implementation validation, playtest, benchmark, or human acceptance study was performed. The prerequisite script returned exit 0 and valid feature/template JSON despite a Python launcher location warning. No extension-hook configuration was present. No tasks.md exists; that is expected before the tasks phase.

**Milestone acceptance and independence:** All four milestones have observable acceptance criteria, prerequisite checkpoints, and FR/SC traceability. M1's requirements and composition explicitly exclude later services/content; M2 introduces persistence, M3 standalone rescue/collection, and M4 generic events/corruption. No M2–M4 dependency is documented as necessary for M1 to run. This is a documentation conclusion, not proof of runtime independence.

| Milestone | Observable acceptance coverage | Dependency conclusion |
| --- | --- | --- |
| M1 | Stories 1–3, FR-001–FR-014, SC-001–SC-004 and SC-010–SC-011: full solo loop, feedback, replay, measured usability/duration. | Self-contained fixed starters, base classes, in-memory run state and M1 scenes/tests. |
| M2 | Stories 4–5, FR-015–FR-023, SC-005: progression/promotion boundaries, companions and twenty reopen cases. | Accepted M1 only; starter passives/branches do not require recruits or corruption. |
| M3 | Stories 6–7, FR-024–FR-034, SC-006–SC-007: routes/rescue, exact draw intervals/costs/conversion, interrupted reveal. | Accepted M2; standalone rescue needs no generic M4 event system. Coin scope inconsistency below needs correction. |
| M4 | Stories 8–9, FR-035–FR-042, SC-008–SC-009 and SC-012: corruption/event boundaries, ten-seed variety, durable chapter and full regression. | Accepted M3; owned-rescue scheduling change is explicit. |

**Assessment of items:** Written coverage supports CHK001–CHK008, CHK010–CHK015, CHK017–CHK029, CHK031–CHK034, CHK036–CHK038, and CHK040 (35 items). CHK009, CHK030, and CHK035 need clarification/correction; CHK016 and CHK039 have explicit later decision/workflow gates. These assessments leave all 40 generated checkboxes reviewer-owned and unchecked.

| Finding | Evidence and implication | Recommended requirement resolution |
| --- | --- | --- |
| CHK009 — M1 kill summary ambiguity | Spec result contract requires kills. Systems tick-order step 3 emits a terminal summary before the otherwise-only kill-count update. Boss inclusion and non-boss deaths on that same tick are unspecified. | Define what counts as a kill and whether terminal-tick kills enter the frozen summary; align arbitration/accounting without allowing post-terminal gameplay or choices. Resolve before affected M1 tasks. |
| CHK035 — M3/M4 coin scope conflict | Data-model RunState says M3 adds coins/rescue. Spec Event contract and data-model Corruption/event snapshots place coin drops/use in M4. | State M3 adds rescue only and M4 adds coins/events/corruption, or explicitly revise scope. This conflict does not affect M1 independence. |
| CHK030 — Unquantified persistence limits | Contract rejects oversize input and model rejects integer overflow, but exact bounds are absent. At least one recovery generation is required, while maximum history/generation retention is unspecified. | Define maximum accepted save size, exact supported integer ranges, and deliberate history/generation retention or growth policy preserving required recovery and original draw results. Resolve before the relevant M2/M3 implementation. |
| CHK016 — Promotion tuning gate | Spec explicitly defers unspecified strengths/durations until before M2 implementation; data model supplies initial proposals, not approved tuning. | Finalize documented values/previews before M2 tasks implement those effects. This is an acknowledged later decision, not missing M1 scope. |
| CHK039 — Task traceability not yet assessable | Plan correctly identifies tasks.md as a subsequent output; constitution already mandates task-to-acceptance mapping and phase checkpoints. | Evaluate the generated tasks against these obligations when available; do not infer task ordering or implemented readiness from this document review. |

Gameplay, promotion, recruitment, gacha, persistence, and testing have substantial written coverage. The three clarification/correction findings above prevent an unconditional completeness sign-off; the two explicit later gates must remain visible. Source requirements, plans, and implementation files were not changed by this checklist review.
