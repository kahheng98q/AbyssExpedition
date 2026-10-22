# Data model

- Profile schema 4 / game m4.1 / content m4.0: owned maps known hero IDs to `{character_id}` only. Tickets/tokens/history/draw_rng/chapters/active/companions/seed/receipt unchanged. `promotion_items` and owned `total_xp`, `level`, `progress_to_next`, `promotion_id` forbidden. Receipt is historical evidence, not live progression.
- RunStartSnapshot: immutable party order, each member level=1, profession=base, passive identity; run level/XP/upgrades start fresh.
- RunProgression: existing level>=1, XP, pending cards, stacks, pickup dedup; add branches map keyed by character ID, lifetime one run. Actor runtime profession rebuilt from this map on debug remove/readd; newly joined character otherwise BASE and derives existing upgrades.
- Promotion offer: monotonic nonce, current hero ID, own pause token; candidates living BASE party members at shared level>=15 in party order. A confirmed ID cannot choose again. Deferral lasts until HUD request, cleared on run destruction.
- Trace: deterministic promotion offers/decisions/cancellation/reopen, no RNG sampling; simulation identity run-level-promotion-1.
- Migration: validate original envelope and payload first; v1->2->3->4 only as needed. Preserve old bytes and previous receipt via migration result. All publication goes through unchanged SaveCoordinator pending bytes/retry.
