# Feature Specification: Run Level Promotion

**Feature directory**: `specs/004-run-level-promotion` (no branch change)
**Created**: 2026-10-22
**Status**: Implemented; core automated checks passed. Full native-focus and human acceptance remain open in tasks.md.
**Input**: Remove permanent levels, XP, class choices and materials; promote each party member once per expedition at shared RUN Lv15.

## User Scenarios & Testing

### User Story 1 - Fresh expedition and safe profile migration (Priority: P1)
As a returning player I keep my collection and earned progress while every expedition starts at BASE / RUN Lv1.
**Why this priority**: Save safety and equal starts are prerequisites for the new loop.
**Independent Test**: Load each supported legacy profile, settle a run, restart and reopen it.
**Acceptance Scenarios**:
1. Given a legacy profile with XP, level, a branch and materials, when loaded, then those obsolete fields disappear while roster, tickets, tokens, recruitment history, draw randomness, chapters, seed and selected party survive.
2. Given a failed migration publication, when retrying, then the exact same pending operation publishes once; the source save remains intact and no partial new profile is exposed.
3. Given victory, defeat or abandonment, when leaving and starting again, then all heroes start BASE / RUN Lv1 without level stat bonuses; run XP, upgrades and branch choices do not persist. Tickets, rescue and chapter rewards retain existing rules; no promotion materials are awarded.

### User Story 2 - Promote the whole party during combat (Priority: P1)
As a player reaching RUN Lv15 I compare two branches for each living party member and use the selected class immediately for this expedition.
**Why this priority**: This is the requested gameplay change.
**Independent Test**: Reach Lv14 then Lv15 with three members; choose branches, cancel, reopen, reject wrong branches, restart.
**Acceptance Scenarios**:
1. Given RUN Lv14, when opening previews, then confirmation is unavailable. At Lv15 each eligible living member receives one offer in party order, before outstanding upgrade cards and newly due events.
2. Given a selected valid branch, when confirmed, then profession, stats, weapon, effects and visuals update immediately while passives, run upgrades, contract bonuses, cooldown and activation identity survive. Preserve current HP ratio, never revive a downed member.
3. Given an offer, when canceling, then combat resumes after other choices, the choice remains available through a visible HUD button, and reopening does not consume randomness. Canceling one queue defers remaining members until reopened. Duplicate or stale confirmation cannot change a second member.
4. Given an existing upgrade, event, rescue, manual pause or focus/debug pause, when promotion becomes eligible, then there is only one choice screen; existing choices finish first. Releasing promotion does not release another owner's pause.
5. Given a late joining companion, when added, then it starts BASE with existing shared run upgrades, shares current RUN level, and receives an offer if level >=15. Removal/readdition does not permit a second promotion for the same character in that run. Downed members have no offer and are never revived.

### User Story 3 - Honest UI and preserved developer tools (Priority: P2)
As a player or developer I see run-only progression and can use F9 / DEV across all screens, including paused promotion.
**Why this priority**: Prevent misleading permanent progression and protect development access.
**Independent Test**: Navigate guild, roster, selection, run, promotion, results and restart; exercise debug XP, eligibility, branch preview, save/retry and release rejection.
**Acceptance Scenarios**:
1. Given any player screen, when reading growth text, then it describes BASE starts, RUN level and temporary branches, with no claim of permanent level rewards or material costs.
2. Given a debug build, when pressing F9 or DEV, then the existing single App-owned panel opens above normal UI, keeps its action IDs and sandbox, and adapted XP/eligibility controls affect only the current run. The legacy material control is retained as a clearly labeled run eligibility alias.
3. Given a release build, when initializing debug UI or invoking any debug action, then all are denied.

### Edge Cases
- Large XP pickup crossing several levels: do not miss Lv15; promotion precedes remaining cards, no extra XP or stat rebalance.
- Invalid/foreign/empty branch, dead/removed member, duplicate clicks, stale generation/offer: reject without side effects.
- Cancel/exit/results/restart during pending choices: no token leak or prior-run callback modifying a new run.
- Legacy v1/v2/v3 validation still rejects damaged/incompatible profiles; migration preserves atomic retry and recovery semantics and archived evidence.
- Permanent operation receipts remain readable; migration preserves the previous receipt in its migration result. Historical receipt contents are evidence, never live class state.

## Requirements
### Functional Requirements
- **FR-001**: Every run MUST start BASE / RUN Lv1 for all members; no permanent XP, level multiplier or saved branch may affect starts (US1).
- **FR-002**: Profiles MUST migrate supported legacy saves without loss of unrelated progress and MUST preserve publication, locking, checksum, recovery and retry guarantees (US1).
- **FR-003**: Settlement MUST award no permanent XP or promotion materials and MUST preserve earned tickets, recruitment and chapter rules (US1).
- **FR-004**: RUN Lv>=15 MUST enable exactly two existing branches and at most one normal confirmation per character per run (US2).
- **FR-005**: An in-combat paused UI MUST reuse existing previews and serialize promotion, upgrade, event and rescue choices deterministically (US2).
- **FR-006**: Confirmation MUST update live class behavior and stats immediately, retain passives/modifiers, preserve living HP ratio and never revive (US2).
- **FR-007**: Cancellation MUST consume nothing and leave a reachable HUD reopen action; late joins follow US2.5 (US2).
- **FR-008**: Matching seed, starting party and ordered actions MUST produce equal promotion offers/decisions and gameplay state; stale/double actions MUST be rejected (US2).
- **FR-009**: All affected visible UI MUST describe run-only progression; original sword preview and combat presentation quality MUST remain (US3).
- **FR-010**: Existing F9/DEV availability, action IDs where practical, sandbox isolation and release denial MUST remain tested (US3).

### Key Entities
- Owned character: permanent ownership identity only.
- Run party: shared level/XP/upgrades, per-character temporary branch, current actors.
- Promotion offer: run identity, ordered member and two branches, cancellation/reopen state.
- Profile generation: versioned permanent data and bounded operation receipt; no resumable expedition state.

## Success Criteria
### Measurable Outcomes
- **SC-001**: Supported old profiles retain all unrelated values after migration and reopen; injected save failures expose only complete old or new state.
- **SC-002**: Boundary tests at Lv14/15 pass for all six heroes and both branches; a three-member party can promote each exactly once.
- **SC-003**: Cancel, reopen, multiple level gains, event/manual/debug pause and restart tests show no missed offers, double confirmation or pause leaks.
- **SC-004**: Repeated seeded runs with the same choices yield identical traces and final profession/HP/stats; invalid/stale actions leave state unchanged.
- **SC-005**: Automated runtime and available graphical/export checks pass; unexecuted human enjoyment/readability/performance acceptance remains explicitly pending.

## Assumptions and Boundaries
The existing shared run XP curve, two branches per base class, skill balance, ticket economy, art scale and automatic combat remain. Promotion HP uses ratio to avoid unintended full heal. Normal recruitment adds ownership after settlement; only DEV can currently join mid-run. Existing in-flight effects retain their committed damage/visual metadata; subsequent attacks use the new profession. This specification supersedes permanent-growth requirements in 001 and 003 only for current gameplay; historical files/evidence remain untouched. No new content, dependencies, network, branch changes, commits or unrelated cleanup.
