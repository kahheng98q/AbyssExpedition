# M4 corruption implementation — 2026-10-15

The user explicitly activated M4 and approved proceeding with unchecked reviewer checklists and earlier unmet acceptance gates. Those markers remain unchanged.

Corruption starts at zero, gains five per full active minute and caps at 100. Threshold totals: 25 gives +10% gem XP and +10% future wave count; 50 gives +20% XP and swaps ten percentage points from Thrall to Broodmother once that enemy is introduced; 75 gives +30% XP and +15% future normal-enemy damage; 100 gives +40% XP, +20% future count and a second fully warned boss eruption circle. Count rounds up once. Threshold effects are recomputed from totals. Costs requiring more headroom reject the entire offer.

Wave reservations retain their modifier snapshot even if corruption changes during their warning. Existing enemies and gems stay unchanged. Later broodlings receive current damage modifiers. Corrupted enemies retain their behavior silhouette and add a violet ring and forked crest. Corruption cannot itself end a run. New gems snapshot XP at death and contain one temporary coin. Only the active hero collects them, once.

Executed: parse-valid initial corruption stub produced 18 behavioral assertion failures (27 assertions), then passed after implementation. Integration coverage now additionally checks minute-before-wave ordering, full pause freeze, crowded cap, reserved-enemy snapshots, future broodlings, old gem XP and committed boss geometry. Full current counts and commands are in m4-gate.md. Source and exported M4 graphical harnesses passed thresholds 0/25/50/75/100 at 1280x720, 1920x1080 and 1371x813. Screenshot review found oversized ProgressBars; setting size after theme/percentage configuration fixed the overlap.

C opens a paused exact-threshold summary. Violet shallow-water feedback is decorative; no unavoidable environmental damage was introduced. Ordinary manual threshold comparison and measured visual latency remain unverified (T153 stays open).

An added Escape regression found a synchronous-close input bug: the summary detached before marking the key handled. Input is now consumed before emitting close, and both early and armed Escape are exercised in every source/release graphical size. The red log is m4-summary-escape-red.log; final green logs are m4-graphical.log and m4-release-graphical.log.
