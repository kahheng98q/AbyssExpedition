# 005 · Tidewatch Guild presentation

Authorized 2026-10-22 by the supplied creative brief. Presentation-only extension of
001 UI and 004 run progression; no new gameplay systems or permanent levels.

## Acceptance

- Full-screen guild at the existing 640×360 logical viewport: guild identity,
  chapter state, balances, primary expedition action, party and six visual hero cards.
- Heroes, Collection, Recruitment and expedition preparation support mouse and
  keyboard, visible focus, owned/locked/party states and on-demand details.
- Party editing preserves one active hero and at most two companions, validates
  before saving, and supports cancellation. Locked heroes cannot be assigned.
- Recruitment preserves confirmation, exact odds, costs, duplicate conversion,
  exchange eligibility, ordered committed receipts, acknowledgement and history.
  Reveal animation is cosmetic, interruptible and never rerolls or spends.
- Existing save format, deterministic simulation, base/Lv1 starts, in-run Lv15
  promotions and App-owned F9/DEV sandbox/release restrictions remain intact.
- Original procedural character presentation and existing coast artwork only;
  temporary art limitations are explicit in design documentation.
- Validate real rendering at 1280×720, 1371×813 and 1920×1080, capture before/after,
  run affected suites and debug graphics/export checks; report human checks separately.

## Boundaries and plan

Shared native Control components and a scoped Theme belong in scripts/ui/.
UI reads catalog/profile snapshots and emits the existing routing/service signals.
No changes to recruitment, persistence, combat, progression or save schemas.
Keep integer viewport scaling and nearest filtering. Static scene ornament, short
opacity transitions and bounded decorative animation must not touch gameplay RNG.
Use built-in fonts; no dependencies or downloaded franchise assets.
Constitution I–VIII: compliant: bounded playable UI, explicit service boundaries,
original art, affected tests, existing pixel conventions, bounded decoration,
offline scope and incremental verified delivery. Combat performance acceptance
remains outside this UI change.
